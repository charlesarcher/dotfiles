#!/bin/bash


export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export LIBVA_DRIVER_NAME=nvidia
export NVD_BACKEND=direct
#
#export LIBSEAT_BACKEND=seatd
export DESKTOP_SESSION="sway"
export XDG_CURRENT_DESKTOP="sway"
export XDG_SESSION_DESKTOP="sway"
export XDG_SESSION_TYPE="wayland"
export WLR_RENDERER="vulkan"
export WLR_BACKENDS="headless,libinput"

# sudo setcap cap_sys_admin+ep /bin/sunshine
export PATH=/opt/cuda/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/opt/cuda/lib64
exec /usr/bin/sway --unsupported-gpu

