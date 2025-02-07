#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <cpu-range> <command> [args...]"
    echo "Example: $0 0-3 firefox"
    exit 1
fi

echo "[+] Checking root privileges..."
[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"

# Get the CPU range and command
CPU_RANGE="$1"
shift
COMMAND="$*"

echo "[+] Running as root, getting user info..."
# Get current user if running with sudo
REAL_USER="${SUDO_USER:-$USER}"
REAL_UID=$(id -u "$REAL_USER")
echo "[+] Will execute as user: $REAL_USER (UID: $REAL_UID)"

# Calculate CPU ranges
ALL_CORES="0-31"
SYSTEM_CORES="$CPU_RANGE"
USER_CORES="$CPU_RANGE"
BACKGROUND_CORES="$CPU_RANGE"
GAMING_CORES="$CPU_RANGE"

echo "[+] Isolating CPUs to range: $CPU_RANGE"
# Isolate CPUs
echo "[+] Setting system.slice CPUs to ${SYSTEM_CORES}"
systemctl set-property --runtime -- system.slice AllowedCPUs=${SYSTEM_CORES}
ACTUAL=$(systemctl show system.slice -p AllowedCPUs | cut -d= -f2)
echo "    Requested: ${SYSTEM_CORES} -> Actual: ${ACTUAL}"

echo "[+] Setting init.scope CPUs to ${SYSTEM_CORES}"
systemctl set-property --runtime -- init.scope AllowedCPUs=${SYSTEM_CORES}
ACTUAL=$(systemctl show init.scope -p AllowedCPUs | cut -d= -f2)
echo "    Requested: ${SYSTEM_CORES} -> Actual: ${ACTUAL}"

echo "[+] Setting user.slice CPUs to ${USER_CORES}"
systemctl set-property --runtime -- user.slice AllowedCPUs=${USER_CORES}
ACTUAL=$(systemctl show user.slice -p AllowedCPUs | cut -d= -f2)
echo "    Requested: ${USER_CORES} -> Actual: ${ACTUAL}"

echo "[+] Setting user@${REAL_UID}.service CPUs to ${BACKGROUND_CORES}"
systemctl set-property --runtime -- user@${REAL_UID}.service AllowedCPUs=${BACKGROUND_CORES}
ACTUAL=$(systemctl show user@${REAL_UID}.service -p AllowedCPUs | cut -d= -f2)
echo "    Requested: ${BACKGROUND_CORES} -> Actual: ${ACTUAL}"

echo "[+] Setting user-${REAL_UID}-gaming.slice CPUs to ${GAMING_CORES}"
systemctl set-property --runtime -- user-${REAL_UID}-gaming.slice AllowedCPUs=${GAMING_CORES}
ACTUAL=$(systemctl show user-${REAL_UID}-gaming.slice -p AllowedCPUs | cut -d= -f2)
echo "    Requested: ${GAMING_CORES} -> Actual: ${ACTUAL}"

# Function to convert CPU list to sorted, unique list
normalize_cpu_list() {
    local cpulist="$1"
    local -a cpus=()
    
    # Split ranges and individual numbers
    for part in ${cpulist//,/ }; do
        if [[ "$part" == *-* ]]; then
            IFS=- read -r start end <<< "$part"
            for ((i=start; i<=end; i++)); do
                cpus+=("$i")
            done
        else
            cpus+=("$part")
        fi
    done
    
    # Sort uniquely and reconstruct ranges
    printf "%s\n" "${cpus[@]}" | sort -nu | tr '\n' ',' | sed 's/,$//'
}

# Function to check if a CPU is in our target range
is_cpu_in_target() {
    local cpu="$1"
    local normalized_range
    normalized_range=$(normalize_cpu_list "$CPU_RANGE")
    for range in ${normalized_range//,/ }; do
        if [[ $range == *-* ]]; then
            IFS=- read -r start end <<< "$range"
            if (( cpu >= start && cpu <= end )); then
                return 0
            fi
        elif [[ $cpu -eq $range ]]; then
            return 0
        fi
    done
    return 1
}

# Function to check if PID is in current process tree
is_pid_in_process_tree() {
    local target_pid=$1
    local current_pid=$$
    
    while [ "$current_pid" -ne 1 ]; do
        if [ "$current_pid" -eq "$target_pid" ]; then
            return 0
        fi
        current_pid=$(ps -o ppid= -p "$current_pid" | tr -d ' ')
    done
    return 1
}

# Function to force migrate a process
force_migrate() {
    local tid="$1"
    local pid="$2"
    
    # Don't migrate our own process tree
    if is_pid_in_process_tree "$pid"; then
        return 1
    fi
    
    if ! sudo kill -SIGSTOP "$tid" 2>/dev/null; then
        echo "    \e[33mWarning: Failed to SIGSTOP $tid\e[0m"
        return 1
    fi
    
    sleep 0.1  # Give the kernel a moment to migrate
    
    if ! sudo kill -SIGCONT "$tid" 2>/dev/null; then
        echo "    \e[33mWarning: Failed to SIGCONT $tid\e[0m"
        return 1
    fi
    
    return 0
}

echo "[+] Checking for processes still running on isolated CPUs..."
declare -A seen_cpus
# Sort processes by CPU first
while read -r pid tid psr comm; do
    if is_cpu_in_target "$psr"; then
        # First time seeing this CPU, print header
        if [[ -z "${seen_cpus[$psr]}" ]]; then
            echo -e "\n\e[1mProcesses on CPU $psr:\e[0m"
            printf "%s\n" "$(printf -- '-%.0s' {1..100})"
            printf "%-10s %-10s %-30s %-20s %s\n" "TID" "PID" "COMM" "INITIAL CPU" "MIGRATION RESULT"
            printf "%s\n" "$(printf -- '-%.0s' {1..100})"
            seen_cpus[$psr]=1
        fi
        
        # Try to force migrate
        initial_psr=$psr
        if force_migrate "$tid" "$pid"; then
            new_psr=$(ps -o psr= -p "$tid" 2>/dev/null | tr -d ' ')
            if [[ -n "$new_psr" && "$new_psr" != "$initial_psr" ]]; then
                printf "%-10s %-10s %-30s %-20s \e[32mMigrated: %s → %s\e[0m\n" \
                    "$tid" "$pid" "$comm" "$initial_psr" "$initial_psr" "$new_psr"
            else
                printf "%-10s %-10s %-30s %-20s \e[33mStill on CPU %s\e[0m\n" \
                    "$tid" "$pid" "$comm" "$initial_psr" "$initial_psr"
            fi
        else
            if is_pid_in_process_tree "$pid"; then
                printf "%-10s %-10s %-30s %-20s \e[36mSkipped (launcher process)\e[0m\n" \
                    "$tid" "$pid" "$comm" "$initial_psr"
            else
                printf "%-10s %-10s %-30s %-20s \e[31mCannot signal process\e[0m\n" \
                    "$tid" "$pid" "$comm" "$initial_psr"
            fi
        fi
    fi
done < <(ps -eLo pid=,lwp=,psr=,comm= | sort -n -k3,3)

echo -e "\n[+] Running command: $COMMAND"
# Run the command as the original user
su "$REAL_USER" -c "taskset -c $CPU_RANGE $COMMAND"
COMMAND_STATUS=$?

echo "[+] Command finished with status: $COMMAND_STATUS"
echo "[+] Deisolating CPUs..."
# Deisolate CPUs
echo "[+] Resetting system.slice CPUs to ${ALL_CORES}"
systemctl set-property --runtime -- system.slice AllowedCPUs=${ALL_CORES}
ACTUAL=$(systemctl show system.slice -p AllowedCPUs | cut -d= -f2)
echo "    Requested: ${ALL_CORES} -> Actual: ${ACTUAL}"

echo "[+] Resetting init.scope CPUs to ${ALL_CORES}"
systemctl set-property --runtime -- init.scope AllowedCPUs=${ALL_CORES}
ACTUAL=$(systemctl show init.scope -p AllowedCPUs | cut -d= -f2)
echo "    Requested: ${ALL_CORES} -> Actual: ${ACTUAL}"

echo "[+] Resetting user.slice CPUs to ${ALL_CORES}"
systemctl set-property --runtime -- user.slice AllowedCPUs=${ALL_CORES}
ACTUAL=$(systemctl show user.slice -p AllowedCPUs | cut -d= -f2)
echo "    Requested: ${ALL_CORES} -> Actual: ${ACTUAL}"

echo "[+] Resetting user@${REAL_UID}.service CPUs to ${ALL_CORES}"
systemctl set-property --runtime -- user@${REAL_UID}.service AllowedCPUs=${ALL_CORES}
ACTUAL=$(systemctl show user@${REAL_UID}.service -p AllowedCPUs | cut -d= -f2)
echo "    Requested: ${ALL_CORES} -> Actual: ${ACTUAL}"

echo "[+] Resetting user-${REAL_UID}-gaming.slice CPUs to ${ALL_CORES}"
systemctl set-property --runtime -- user-${REAL_UID}-gaming.slice AllowedCPUs=${ALL_CORES}
ACTUAL=$(systemctl show user-${REAL_UID}-gaming.slice -p AllowedCPUs | cut -d= -f2)
echo "    Requested: ${ALL_CORES} -> Actual: ${ACTUAL}"
echo "[+] Done"

exit $COMMAND_STATUS
