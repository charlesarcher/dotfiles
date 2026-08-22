#!/bin/bash

#[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"

export QT_QPA_PLATFORM=wayland
#export WLR_NO_HARDWARE_CURSORS=1
export CLUTTER_BACKEND=wayland
export SDL_VIDEODRIVER=wayland
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export MOZ_ENABLE_WAYLAND=1
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export XDG_SESSION_TYPE=wayland
#export KWIN_DRM_FORCE_EGL_STREAMS=1

dbus-run-session startplasma-wayland

