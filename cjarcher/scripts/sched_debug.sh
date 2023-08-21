#!/bin/bash

[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"
# /proc/sched_debug on some systems
sed -e '/^cpu#.*/,/^runnable.*/{//!d}' < /sys/kernel/debug/sched/debug

echo " ******************** Runnable List ***************** "
ps -Teo pid,psr,stat,cmd | awk '$3 ~ /R/' | sort -nk 2
