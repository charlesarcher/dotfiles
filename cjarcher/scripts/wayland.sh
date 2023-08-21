#!/bin/bash

[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"

# echo enabled |sudo tee /sys/bus/usb/devices/*/power/wakeup
# cat /home/archerc/Downloads/myfile.dat > /sys/kernel/debug/dri/0/DP-2/edid_override
cat /home/archerc/GDM-FW900.bin > /sys/kernel/debug/dri/0/DP-4/edid_override
echo 'always' | tee /sys/kernel/mm/transparent_hugepage/enabled

#export QT_QPA_PLATFORM=wayland
#export WLR_NO_HARDWARE_CURSORS=1
#export CLUTTER_BACKEND=wayland
#export SDL_VIDEODRIVER=wayland
#export QT_QPA_PLATFORM=wayland
#export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
#export MOZ_ENABLE_WAYLAND=1
#export GBM_BACKEND=nvidia-drm
#export __GLX_VENDOR_LIBRARY_NAME=nvidia
#export XDG_SESSION_TYPE=wayland
# 278d00
# KWIN_DRM_NO_DIRECT_SCANOUT
# qdbus org.kde.KWin /Compositor suspend
# qdbus org.kde.KWin /Compositor resume

# journalctl -b -1 --priority=4
#dbus-run-session startplasma-wayland

