#!/bin/bash

[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"


USER_CORES="0-31"
SYSTEM_CORES="8-15,24-31"
BACKGROUND_CORES="8-15,24-31"
GAMING_CORES="0-7,16-23"
AVAILABLECPUS="0-7,9-31"

# Migrate irqs to CPU 0
failed=0
success=0
for PROC in $(ls /proc/irq)
do
    if [[ -x "/proc/irq/$PROC" && $PROC != "0" ]]
    then
        cmd="echo "${BACKGROUND_CORES}" > /proc/irq/$PROC/smp_affinity_list"
        (eval "$cmd" > /dev/null 2>&1 ) &
        pid=$!
        wait $pid
        status=$?
        if [ $status -eq 0 ]; then
            success=$((success+1))
        else
            failed=$((failed+1))
        fi
    fi
done
echo "IRQ:  Migrated $success to (${BACKGROUND_CORES}), failed to migrate $failed"


# Migrate all possible tasks to CPU 0
failed=0
success=0
for PROC in $(ls /proc)
do
	if [ -x "/proc/$PROC/task/" ]
	then
		cmd="taskset -acp ${BACKGROUND_CORES} $PROC"
        (eval "$cmd" > /dev/null 2>&1 ) &
        pid=$!
        wait $pid
        status=$?
        if [ $status -eq 0 ]; then
            success=$((success+1))
        else
            failed=$((failed+1))
        fi
	fi
done
echo "Tasks:  Migrated $success (${BACKGROUND_CORES}), failed to migrate $failed"

for x in /sys/devices/system/cpu/cpu[${AVAILABLECPUS}]*/online; do
    echo 0 > "$x"
done

for x in /sys/devices/system/cpu/cpu[${AVAILABLECPUS}]*/online; do
    echo 1 > "$x"
done
echo "Varied OFF/ON cores (${AVAILABLECPUS})"


# Delay the annoying vmstat timer far away
sysctl vm.stat_interval=3600

# Shutdown nmi watchdog as it uses perf events
sysctl -w kernel.watchdog=0

# Pin the writeback workqueue to CPU0
echo 1 > /sys/bus/workqueue/devices/writeback/cpumask

# disable the rt 95% limit
echo -1 > /proc/sys/kernel/sched_rt_runtime_us

systemctl set-property --runtime -- system.slice AllowedCPUs=${SYSTEM_CORES}
systemctl set-property --runtime -- init.scope AllowedCPUs=${SYSTEM_CORES}
systemctl set-property --runtime -- user.slice AllowedCPUs=${USER_CORES}
systemctl set-property --runtime -- user@1000.service AllowedCPUs=${BACKGROUND_CORES}
#systemctl set-property --runtime -- session.slice AllowedCPUs=${SESSION_CORES}
#systemctl set-property --runtime -- background.slice AllowedCPUs=${BACKGROUND_CORES}
#systemctl set-property --runtime -- app.slice AllowedCPUs=${APP_CORES}
systemctl set-property --runtime -- user-1000-gaming.slice AllowedCPUs=${GAMING_CORES}

#systemd-run --slice=user-1000-gaming.slice --scope --uid=archerc --shell
