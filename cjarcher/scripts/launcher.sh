#!/bin/bash
# launcher.sh - Optimized CPU Isolation with Forced Migration

set -euo pipefail

############################
# Helper Functions
############################

cpulist_to_mask() {
    local cpulist="$1"
    local mask=0
    IFS=',' read -ra parts <<< "$cpulist"
    for part in "${parts[@]}"; do
        if [[ "$part" == *"-"* ]]; then
            IFS='-' read -r start end <<< "$part"
            for (( i=start; i<=end; i++ )); do
                (( mask |= (1 << i) ))
            done
        else
            (( mask |= (1 << part) ))
        fi
    done
    printf "0x%x" "$mask"
}

get_online_cpus_mask() {
    local all_cpus
    all_cpus=$(cat /sys/devices/system/cpu/online)
    cpulist_to_mask "$all_cpus"
}

compute_fallback_mask() {
    local target_mask="$1"
    local all_mask
    all_mask=$(get_online_cpus_mask)
    local fallback_mask=$(( all_mask & ~target_mask ))
    printf "0x%x" "$fallback_mask"
}

is_cpu_in_target() {
    local cpu="$1"
    (( (TARGET_MASK & (1 << cpu)) != 0 ))
}

force_migration() {
    local pid="$1"
    for tid in $(ps -T -o tid= --pid "$pid"); do
        if [[ "$tid" != "$$" ]]; then
            kill -SIGSTOP "$tid" 2>/dev/null && sleep 0.01 && kill -SIGCONT "$tid" 2>/dev/null
        fi
    done
}

############################
# Main Logic
############################

[ "$#" -ge 2 ] || {
    echo "Usage: sudo $0 [--rescan] <target-cpu-list> <command> [<args>...]"
    exit 1
}

RESCAN_MODE=false
if [[ "$1" == "--rescan" ]]; then
    RESCAN_MODE=true
    shift
fi

TARGET_CPUS="$1"
shift
COMMAND=("$@")

TARGET_MASK=$(cpulist_to_mask "$TARGET_CPUS")
FALLBACK_MASK=$(compute_fallback_mask "$TARGET_MASK")

declare -A TARGET_CPU_ARRAY
IFS=',' read -ra target_ranges <<< "$TARGET_CPUS"
for range in "${target_ranges[@]}"; do
    if [[ "$range" == *"-"* ]]; then
        IFS='-' read -r start end <<< "$range"
        for (( i=start; i<=end; i++ )); do
            TARGET_CPU_ARRAY["$i"]=1
        done
    else
        TARGET_CPU_ARRAY["$range"]=1
    fi
done

[ "$FALLBACK_MASK" != "0x0" ] || { echo "Error: No CPUs remain for migrated tasks!"; exit 1; }

declare -a MIGRATION_ENTRIES

migrate_tasks() {
    local phase="$1"
    echo -e "\n=== Phase: $phase ==="

    while read -r pid tid psr comm; do
        if affinity_line=$(taskset -p "$tid" 2>/dev/null); then
            current_mask=$(echo "$affinity_line" | awk '{print $NF}')
            [[ "$current_mask" != 0x* ]] && current_mask="0x$current_mask"
            current_mask_num=$((current_mask))

            if (( current_mask_num & TARGET_MASK )); then
                new_mask=$(( current_mask_num & ~TARGET_MASK ))
                (( new_mask == 0 )) && new_mask=$FALLBACK_MASK
                new_mask_hex=$(printf "0x%x" "$new_mask")

                original_mask=$(taskset -p "$tid" | awk '{print $NF}')
                [[ "$original_mask" != 0x* ]] && original_mask="0x$original_mask"

                err_msg=""
                if ! taskset -p "$new_mask_hex" "$tid" >/dev/null 2>&1; then
                    err_msg="Invalid argument"
                fi

                actual_mask=$(taskset -p "$tid" 2>/dev/null | awk '{print $NF}' || echo "$original_mask")
                [[ "$actual_mask" != 0x* ]] && actual_mask="0x$actual_mask"

                status="\e[32mYes\e[0m"
                forced=""
                if [[ -n "$err_msg" ]]; then
                    status="\e[31mNo ($err_msg)\e[0m"
                else
                    current_psr=$(ps -o psr= -p "$tid" | tr -d ' ' || echo "")
                    if [[ -n "$current_psr" ]] && is_cpu_in_target "$current_psr"; then
                        force_migration "$pid"
                        new_psr=$(ps -o psr= -p "$tid" | tr -d ' ')
                        forced="(forced from CPU $current_psr→$new_psr)"
                    fi
                fi

                MIGRATION_ENTRIES+=("${psr}|${tid}|${comm}|${original_mask}|${new_mask_hex}|${actual_mask}|${status}|${forced}")
            fi
        fi
    done < <(ps -eLo pid,lwp,psr,comm=)
}

migrate_tasks "Initial Migration"

if $RESCAN_MODE; then
    migrate_tasks "Rescan Migration"
fi

echo -e "\nMigration Verification Report:"
printf "%s\n" "$(printf -- '-%.0s' {1..130})"
current_cpu="-1"
IFS=$'\n' SORTED_ENTRIES=($(printf "%s\n" "${MIGRATION_ENTRIES[@]}" | sort -t'|' -n -k1,1 -k2,2))
for entry in "${SORTED_ENTRIES[@]}"; do
    IFS='|' read -r psr tid comm original_mask requested_mask actual_mask status forced <<< "$entry"
    if [[ "$psr" != "$current_cpu" ]]; then
        [[ "$current_cpu" != "-1" ]] && echo ""
        printf "%s\n" "$(printf -- '-%.0s' {1..130})"
        echo " CPU ${psr}:"
        printf "%s\n" "$(printf -- '-%.0s' {1..130})"
        current_cpu="$psr"
    fi
    printf "%-10s %-10s %-35s %-12s %-12s %-12s %-25b %-25s\n" "$tid" "$psr" "$comm" "$original_mask" "$requested_mask" "$actual_mask" "$status" "$forced"
done

echo -e "\nMigration complete."
echo "Launching program on target CPUs..."
taskset -c "$TARGET_CPUS" "${COMMAND[@]}"
