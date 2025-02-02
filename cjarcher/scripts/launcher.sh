#!/bin/bash
# launcher.sh - Advanced CPU Isolation with Forced Migration

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
                mask=$(( mask | (1 << i) ))
            done
        else
            mask=$(( mask | (1 << part) ))
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
    local tid="$1"
    # Send stop-cont to force rescheduling
    echo $tid $$
    if [[ "$tid" != "$$" ]]; then
        kill -SIGSTOP "$tid" 2>/dev/null && sleep 0.01 && kill -SIGCONT "$tid" 2>/dev/null
    fi
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
COMMAND="$@"

echo "Target CPUs to isolate: $TARGET_CPUS"

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

echo "Target CPU mask: $TARGET_MASK"
echo "Fallback CPU mask: $FALLBACK_MASK"

[ "$FALLBACK_MASK" != "0x0" ] || { echo "Error: No CPUs remain for migrated tasks!"; exit 1; }

declare -a MIGRATION_ENTRIES

migrate_tasks() {
    local phase="$1"
    echo -e "\n=== Phase: $phase ==="

    while read -r tid psr comm; do
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

                # Attempt migration
                err_msg=$(taskset -p "$new_mask_hex" "$tid" 2>&1 >/dev/null) || true
                actual_mask=$(taskset -p "$tid" 2>/dev/null | awk '{print $NF}' || echo "$original_mask")
                [[ "$actual_mask" != 0x* ]] && actual_mask="0x$actual_mask"

                status="Yes"
                reason=""
                forced=""
                if [[ "$actual_mask" != "$new_mask_hex" ]]; then
                    if [[ -n "$err_msg" ]]; then
                        reason=$(printf "%s" "$err_msg" | cut -d':' -f2- | tr -d "'" | head -c 30)
                        status="No (${reason,,})"
                    elif (( (actual_mask & TARGET_MASK) > 0 )); then
                        status="Partial (still in target)"
                    else
                        status="No (unknown)"
                    fi
                else
                    # Check current PSR after successful mask change
                    current_psr=$(ps -o psr= -p "$tid" | tr -d ' ') || current_psr=""
                    if [ "${current_psr}" != "" ] && is_cpu_in_target "$current_psr"; then

                        force_migration "$tid"
                        new_psr=$(ps -o psr= -p "$tid" | tr -d ' ')
                        forced="(forced from CPU $current_psr→$new_psr)"
                    fi
                fi

                MIGRATION_ENTRIES+=("${psr}|${tid}|${comm}|${original_mask}|${new_mask_hex}|${actual_mask}|${status}|${forced}")
            fi
        fi
    done < <(ps -eLo lwp,psr,comm=)
}

# Initial migration
migrate_tasks "Initial Migration"

# Rescan if requested
if $RESCAN_MODE; then
    migrate_tasks "Rescan Migration"
fi

echo -e "\nMigration Verification Report:"

IFS=$'\n' SORTED_ENTRIES=($(printf "%s\n" "${MIGRATION_ENTRIES[@]}" | sort -t'|' -n -k1,1 -k2,2))

COL_TID=10
COL_PSR=10
COL_NAME=35
COL_OLD=12
COL_REQ=12
COL_ACT=12
COL_STATUS=25
COL_FORCE=25
TOTAL_WIDTH=$(( COL_TID + COL_PSR + COL_NAME + COL_OLD + COL_REQ + COL_ACT + COL_STATUS + COL_FORCE + 35 ))

current_cpu="-1"
for entry in "${SORTED_ENTRIES[@]}"; do
    IFS='|' read -r psr tid comm original_mask requested_mask actual_mask status forced <<< "$entry"

    if [[ "$psr" != "$current_cpu" ]]; then
        [[ "$current_cpu" != "-1" ]] && echo ""
        printf "%${TOTAL_WIDTH}s\n" | tr ' ' '-'
        echo " CPU ${psr}:"
        printf "%${TOTAL_WIDTH}s\n" | tr ' ' '-'
        printf "%-${COL_TID}s %-${COL_PSR}s %-${COL_NAME}s %-${COL_OLD}s %-${COL_REQ}s %-${COL_ACT}s %-${COL_STATUS}s %-${COL_FORCE}s\n" \
               "TID" "PSR" "Thread Name" "Original" "Requested" "Actual" "Status" "Migration Force"
        printf "%${TOTAL_WIDTH}s\n" | tr ' ' '-'
        current_cpu="$psr"
    fi

    truncated_comm=$(echo "$comm" | awk '{ if (length($0) > 35) print substr($0,1,32) "..."; else print $0 }')

    # Color coding
    if [[ "$status" == "Yes"* ]]; then
        status_col="\e[32m${status}\e[0m"
    elif [[ "$status" == "No"* ]]; then
        status_col="\e[31m${status}\e[0m"
    else
        status_col="\e[33m${status}\e[0m"
    fi

    printf "%-${COL_TID}s %-${COL_PSR}s %-${COL_NAME}s %-${COL_OLD}s %-${COL_REQ}s %-${COL_ACT}s %-${COL_STATUS}b %-${COL_FORCE}s\n" \
           "$tid" "$psr" "$truncated_comm" "$original_mask" "$requested_mask" "$actual_mask" "$status_col" "$forced"
done

echo -e "\nMigration complete."
echo "Launching program on target CPUs..."
exec taskset "$TARGET_MASK" $COMMAND
