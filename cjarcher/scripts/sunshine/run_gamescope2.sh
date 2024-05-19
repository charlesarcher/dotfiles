#!/bin/bash

export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __NV_PRIME_RENDER_OFFLOAD=1
export LIBVA_DRIVER_NAME=nvidia
export NVD_BACKEND=direct
export WLR_RENDERER="vulkan"
export WLR_BACKENDS="libinput"

DISPLAY=:1 xrandr
unset WAYLAND_DISPLAY
DISPLAY=:1 /usr/bin/gamescope --hdr-enabled --hdr-itm-enable \
    --hide-cursor-delay 3000 --fade-out-duration 200 --xwayland-count 2  \
    -W $SCREEN_WIDTH -H $SCREEN_HEIGHT -O $CONNECTOR $*
