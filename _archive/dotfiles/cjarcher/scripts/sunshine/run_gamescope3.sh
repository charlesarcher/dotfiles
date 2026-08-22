#!/bin/bash

#env | grep WAY


export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __NV_PRIME_RENDER_OFFLOAD=1
export LIBVA_DRIVER_NAME=nvidia
export NVD_BACKEND=direct
#
export DESKTOP_SESSION="sway"
#export XDG_CURRENT_DESKTOP="sway"
#export XDG_SESSION_DESKTOP="sway"
#export XDG_SESSION_TYPE="wayland"
#export WLR_RENDERER="vulkan"
#export WLR_BACKENDS="headless,libinput"
#export WLR_NO_HARDWARE_CURSORS=1

unset WAYLAND_DISPLAY
unset DISPLAY
#strace -f -e trace=execve

export SCREEN_WIDTH=3840
export SCREEN_HEIGHT=2160
export CONNECTOR=*,DP-3

gamescope -bef -W $SCREEN_WIDTH -H $SCREEN_HEIGHT -O $CONNECTOR --xwayland-count 2  $*
#gamescope -bef --headless --xwayland-count 2 --prefer-vk-device $*
#gamescope -bef --headless --prefer-vk-device $*
