#!/bin/bash
# optimize_latency.sh
#
# This script tunes various Zen kernel scheduler parameters for low-latency gaming.
#
# The following parameters are modified via the scheduler DebugFS interface:
#
# 1. base_slice_ns:
#    - Default: 1,600,000 ns
#    - Range: Positive integer (ns)
#    - Change: Set to 200,000 ns to allow more frequent context switches
#
# 2. latency_warn_ms:
#    - Default: 100 ms
#    - Range: Positive integer (ms)
#    - Change: Set to 1 ms to log even slight scheduling delays
#
# 3. latency_warn_once:
#    - Default: 1 (enabled)
#    - Range: 0 (disabled) or 1 (enabled)
#    - Change: Remains 1 to log the first occurrence of a latency warning
#
# 4. migration_cost_ns:
#    - Default: 250,000 ns
#    - Range: 0 to several hundred thousand ns
#    - Change: Set to 50,000 ns to make task migration more acceptable for responsiveness
#
# 5. nr_migrate:
#    - Default: 8
#    - Range: Positive integer
#    - Change: Set to 1 to minimize the number of tasks migrated during load balancing
#
# 6. preempt:
#    - Default: “none voluntary (full)” meaning it defaults to voluntary preemption
#    - Range: Typically accepts “voluntary” or “full”
#    - Change: Set to “full” to ensure full preemption for lower latency
#
# 7. tunable_scaling:
#    - Default: 1
#    - Remains: 1 (no change)
#
# Additionally, we disable NUMA balancing to avoid potential latency issues from inter-node migrations.
#
# fair_server and features are not modified here, but are listed as part of the scheduler debugfs.
#
# Usage: sudo ./optimize_latency.sh

set -euo pipefail

# Function to read the current sysfs/debugfs value (if readable)
read_sysfs_value() {
    local file="$1"
    if [[ -r "$file" ]]; then
        cat "$file"
    else
        echo "<unreadable>"
    fi
}

# Function to set a sysfs/debugfs value, printing the old and new values.
set_sysfs_value() {
    local file="$1"
    local new_value="$2"
    local old_value
    old_value=$(read_sysfs_value "$file")
    if [[ -w "$file" ]]; then
        echo "$new_value" > "$file" && echo "Set $file: ${old_value} -> ${new_value}"
    else
        echo "Warning: $file not found or not writable; skipping." >&2
    fi
}

# Ensure the script is run as root.
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Try: sudo $0" >&2
    exit 1
fi

echo "Optimizing Zen kernel scheduler for low-latency gaming..."

### 1. Scheduler Settings via DebugFS ###
DEBUGFS_SCHED="/sys/kernel/debug/sched"

# Ensure DebugFS is mounted.
if [ ! -d "$DEBUGFS_SCHED" ]; then
    echo "DebugFS is not mounted. Mounting it now..."
    mount -t debugfs debugfs /sys/kernel/debug || {
        echo "Failed to mount debugfs. Exiting." >&2
        exit 1
    }
fi

###############################################################################
# Parameter: preempt
# ------------------
# Default: "none" or "voluntary" (i.e. voluntary preemption) 
#          (as indicated by "none voluntary (full)")
# Range: Accepts "voluntary" or "full"
# Purpose: Set to "full" to ensure complete preemption, allowing for quicker
#          task interruption and lower latency.
###############################################################################
set_sysfs_value "$DEBUGFS_SCHED/preempt" full

###############################################################################
# Parameter: latency_warn_once
# ----------------------------
# Default: 1 (enabled)
# Range: 0 (disabled) or 1 (enabled)
# Purpose: Remains enabled to log a one-time warning when scheduling latency exceeds
#          the threshold set by latency_warn_ms.
###############################################################################
set_sysfs_value "$DEBUGFS_SCHED/latency_warn_once" 1

###############################################################################
# Parameter: latency_warn_ms
# --------------------------
# Default: 100 ms
# Range: Positive integer (milliseconds)
# Purpose: Lowered to 1 ms to log even minor scheduling delays that might affect gaming.
###############################################################################
set_sysfs_value "$DEBUGFS_SCHED/latency_warn_ms" 1

###############################################################################
# Parameter: nr_migrate
# ---------------------
# Default: 8
# Range: Positive integer
# Purpose: Reduced to 1 to minimize the number of tasks migrated during load balancing,
#          helping preserve cache locality and lower latency.
###############################################################################
set_sysfs_value "$DEBUGFS_SCHED/nr_migrate" 1

###############################################################################
# Parameter: migration_cost_ns
# ----------------------------
# Default: 250,000 ns
# Range: 0 to several hundred thousand ns
# Purpose: Lowered to 50,000 ns so the scheduler is more willing to migrate tasks quickly,
#          which can improve responsiveness.
###############################################################################
set_sysfs_value "$DEBUGFS_SCHED/migration_cost_ns" 50000

###############################################################################
# Parameter: base_slice_ns
# ------------------------
# Default: 1,600,000 ns
# Range: Positive integer (nanoseconds)
# Purpose: Lowered to 200,000 ns to reduce the time slice for each task,
#          allowing for more frequent context switches and better interactivity.
###############################################################################
set_sysfs_value "$DEBUGFS_SCHED/base_slice_ns" 200000

###############################################################################
# Parameter: tunable_scaling
# --------------------------
# Default: 1
# Range: Typically 0 or 1
# Purpose: Remains unchanged as 1, which is appropriate for our workload.
###############################################################################
set_sysfs_value "$DEBUGFS_SCHED/tunable_scaling" 1

###############################################################################
# Parameter: NUMA Balancing
# -------------------------
# Default: Typically enabled (1) on NUMA systems (not explicitly provided above)
# Range: 0 (disabled) or 1 (enabled)
# Purpose: Disabled (set to 0) to prevent potential latency increases due to
#          automatic migration of tasks between NUMA nodes.
###############################################################################
NUMA_BALANCE_DIR="$DEBUGFS_SCHED/numa_balancing"
if [ -d "$NUMA_BALANCE_DIR" ]; then
    if [ -w "$NUMA_BALANCE_DIR/enable" ]; then
        set_sysfs_value "$NUMA_BALANCE_DIR/enable" 0
    else
        echo "NUMA balancing control file not found in $NUMA_BALANCE_DIR; skipping." >&2
    fi
fi

###############################################################################
# Informational: fair_server and features
# ----------------------------------------
# fair_server (directory) and features (file) contain scheduling policies and
# enabled options. The default features (as provided) include:
#  PLACE_LAG, PLACE_DEADLINE_INITIAL, PLACE_REL_DEADLINE, RUN_TO_PARITY,
#  PREEMPT_SHORT, NO_NEXT_BUDDY, CACHE_HOT_BUDDY, DELAY_DEQUEUE, DELAY_ZERO,
#  WAKEUP_PREEMPTION, NO_HRTICK, NO_HRTICK_DL, NO_DOUBLE_TICK, NONTASK_CAPACITY,
#  TTWU_QUEUE, SIS_UTIL, NO_WARN_DOUBLE_CLOCK, RT_PUSH_IPI, NO_RT_RUNTIME_SHARE,
#  NO_LB_MIN, ATTACH_AGE_LOAD, WA_IDLE, WA_WEIGHT, WA_BIAS, UTIL_EST, NO_LATENCY_WARN
# We do not change these settings in this script.
###############################################################################

echo "Latency tuning applied via scheduler debugfs settings."
echo "Reboot or restore original settings to revert these changes."
exit 0
