#!/bin/bash

#OBS_USE_EGL=1 QT_QPA_PLATFORM=xcb obs -platform xcb
# steam -pipewire-dmabuf

# Hardware cursors not yet working on wlroots
export WLR_NO_HARDWARE_CURSORS=1

# Set WLRoots renderer to Vulkan to avoid flickering
export WLR_RENDERER=vulkan

# General wayland environment variables
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

# Firefox wayland environment variable
export MOZ_ENABLE_WAYLAND=1
export MOZ_USE_XINPUT2=1

# OpenGL Variables
export GBM_BACKEND=nvidia-drm
export __GL_GSYNC_ALLOWED=0
export __GL_VRR_ALLOWED=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export GDK_SCALE=1
XDG_CURRENT_DESKTOP=sway dbus-run-session sway --unsupported-gpu -D noscanout

# swaymsg output DP-1 mode 3840x2160@120Hz
#exec sway-nvidia
