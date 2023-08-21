#!/bin/bash

[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"

SYSTEM_CORES=0-23
USER_CORES=0-23
BACKGROUND_CORES=0-23
GAMING_CORES=0-23

systemctl set-property --runtime -- system.slice AllowedCPUs=${SYSTEM_CORES}
systemctl set-property --runtime -- init.scope AllowedCPUs=${SYSTEM_CORES}
systemctl set-property --runtime -- user.slice AllowedCPUs=${USER_CORES}
systemctl set-property --runtime -- user@1000.service AllowedCPUs=${BACKGROUND_CORES}
systemctl set-property --runtime -- user-1000-gaming.slice AllowedCPUs=${GAMING_CORES}
