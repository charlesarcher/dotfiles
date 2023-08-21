#!/bin/bash

[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"

ALLCPUS="0-23"
AVAILABLECPUS="1-23"
APPLICATIONCPUS="4-11,16-23"
SYSTEMCPUS="0-3,12-15"


case $1 in
    "do")
        echo "+cpuset" | tee /sys/fs/cgroup/cgroup.subtree_control
        echo "+cpuset" | tee /sys/fs/cgroup/user.slice/cgroup.subtree_control
        echo "+cpuset" | tee /sys/fs/cgroup/system.slice/cgroup.subtree_control
        echo "+cpuset" | tee /sys/fs/cgroup/init.scope/cgroup.subtree_control
        echo "$APPLICATIONCPUS" | tee /sys/fs/cgroup/user.slice/cpuset.cpus
        echo "$SYSTEMCPUS" | tee /sys/fs/cgroup/system.slice/cpuset.cpus
        echo "$SYSTEMCPUS" | tee /sys/fs/cgroup/init.scope/cpuset.cpus
        ;;
    "undo")
        echo "$ALLCPUS" | tee /sys/fs/cgroup/user.slice/cpuset.cpus
        echo "$ALLCPUS" | tee /sys/fs/cgroup/system.slice/cpuset.cpus
        echo "$ALLCPUS" | tee /sys/fs/cgroup/init.scope/cpuset.cpus
        echo "-cpuset" | tee /sys/fs/cgroup/user.slice/cgroup.subtree_control
        echo "-cpuset" | tee /sys/fs/cgroup/system.slice/cgroup.subtree_control
        echo "-cpuset" | tee /sys/fs/cgroup/init.scope/cgroup.subtree_control
        echo "-cpuset" | tee /sys/fs/cgroup/cgroup.subtree_control
        ;;
esac


for x in /sys/devices/system/cpu/cpu[${AVAILABLECPUS}]*/online; do
    echo 0 > "$x"
done

for x in /sys/devices/system/cpu/cpu[${AVAILABLECPUS}]*/online; do
    echo 1 > "$x"
done
