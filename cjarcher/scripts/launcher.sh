#!/bin/bash
# launcher.sh - CPU Isolation Launcher with Migration Diagnostics

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

############################
# Main Logic
############################

[ "$#" -ge 2 ] || { echo "Usage: sudo $0 <target-cpu-list> <command> [<args>...]"; exit 1; }

TARGET_CPUS="$1"
shift
COMMAND="$@"

echo "Target CPUs to isolate: $TARGET_CPUS"

TARGET_MASK=$(cpulist_to_mask "$TARGET_CPUS")
FALLBACK_MASK=$(compute_fallback_mask "$TARGET_MASK")

echo "Target CPU mask: $TARGET_MASK"
echo "Fallback CPU mask: $FALLBACK_MASK"

[ "$FALLBACK_MASK" != "0x0" ] || { echo "Error: No CPUs remain for migrated tasks!"; exit 1; }

declare -a MIGRATION_ENTRIES

echo "Migrating tasks off target CPUs..."

while read -r pid psr comm; do
    if affinity_line=$(taskset -p "$pid" 2>/dev/null); then
        current_mask=$(echo "$affinity_line" | awk '{print $NF}')
        [[ "$current_mask" != 0x* ]] && current_mask="0x$current_mask"
        current_mask_num=$((current_mask))

        if (( current_mask_num & TARGET_MASK )); then
            new_mask=$(( current_mask_num & ~TARGET_MASK ))
            (( new_mask == 0 )) && new_mask=$FALLBACK_MASK
            new_mask_hex=$(printf "0x%x" "$new_mask")

            original_mask=$(taskset -p "$pid" | awk '{print $NF}')
            [[ "$original_mask" != 0x* ]] && original_mask="0x$original_mask"

            # Improved error handling with proper xargs usage
            err_msg=$(taskset -p "$new_mask_hex" "$pid" 2>&1 >/dev/null) || true
            actual_mask=$(taskset -p "$pid" 2>/dev/null | awk '{print $NF}' || echo "$original_mask")
            [[ "$actual_mask" != 0x* ]] && actual_mask="0x$actual_mask"

            status="Yes"
            reason=""

            if [[ "$actual_mask" != "$new_mask_hex" ]]; then
                if [[ -n "$err_msg" ]]; then
                    # Fix: Use printf to avoid xargs quote issues
                    reason=$(printf "%s" "$err_msg" | cut -d':' -f2- | \
                             tr -d "'" | xargs -0 printf "%s" | head -c 30)
                    status="No (${reason,,})"
                elif (( (actual_mask & TARGET_MASK) > 0 )); then
                    status="Partial (still in target)"
                else
                    status="No (unknown)"
                fi
            fi

            MIGRATION_ENTRIES+=("${psr}|${pid}|${comm}|${original_mask}|${new_mask_hex}|${actual_mask}|${status}")
        fi
    fi
done < <(ps -eLo pid,psr,comm=)

echo -e "\nMigration Verification Report (Grouped by CPU):"

IFS=$'\n' SORTED_ENTRIES=($(printf "%s\n" "${MIGRATION_ENTRIES[@]}" | sort -t'|' -n -k1,1 -k2,2))

COL_PID=10
COL_PSR=10
COL_NAME=35
COL_OLD=12
COL_REQ=12
COL_ACT=12
COL_STATUS=25
TOTAL_WIDTH=$(( COL_PID + COL_PSR + COL_NAME + COL_OLD + COL_REQ + COL_ACT + COL_STATUS + 30 ))

current_cpu="-1"
for entry in "${SORTED_ENTRIES[@]}"; do
    IFS='|' read -r psr pid comm original_mask requested_mask actual_mask status <<< "$entry"

    if [[ "$psr" != "$current_cpu" ]]; then
        [[ "$current_cpu" != "-1" ]] && echo ""
        printf "%${TOTAL_WIDTH}s\n" | tr ' ' '-'
        echo " CPU ${psr}:"
        printf "%${TOTAL_WIDTH}s\n" | tr ' ' '-'
        printf "%-${COL_PID}s %-${COL_PSR}s %-${COL_NAME}s %-${COL_OLD}s %-${COL_REQ}s %-${COL_ACT}s %-${COL_STATUS}s\n" \
               "PID" "PSR" "Task Name" "Original" "Requested" "Actual" "Migration Status"
        printf "%${TOTAL_WIDTH}s\n" | tr ' ' '-'
        current_cpu="$psr"
    fi

    truncated_comm=$(echo "$comm" | awk '{ if (length($0) > 35) print substr($0,1,32) "..."; else print $0 }')

    if [[ "$status" == "Yes" ]]; then
        status_col="\e[32m${status}\e[0m"
    elif [[ "$status" == "No"* ]]; then
        status_col="\e[31m${status}\e[0m"
    else
        status_col="\e[33m${status}\e[0m"
    fi

    printf "%-${COL_PID}s %-${COL_PSR}s %-${COL_NAME}s %-${COL_OLD}s %-${COL_REQ}s %-${COL_ACT}s %-${COL_STATUS}b\n" \
           "$pid" "$psr" "$truncated_comm" "$original_mask" "$requested_mask" "$actual_mask" "$status_col"
done

echo -e "\nMigration complete."
echo "Launching program on target CPUs..."
exec taskset "$TARGET_MASK" $COMMAND
