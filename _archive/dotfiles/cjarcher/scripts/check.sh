#!/bin/bash
echo "PID  SLICE   SERVICE"
for THISPID in `pgrep $1`; do
    SLICE=$(cat /proc/$THISPID/cgroup | grep '^1:' | awk -F/ '{ print $2 }')
    SERVICE=$(cat /proc/$THISPID/cgroup | grep '^1:' | awk -F/ '{ print $3 }')
    echo "$THISPID $SLICE $SERVICE"
done
