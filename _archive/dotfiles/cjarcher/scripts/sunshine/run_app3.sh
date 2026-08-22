#!/bin/bash

#WAYLAND_DISPLAY=gamescope-0
env | grep DISPLAY
env | grep WAYLAND
env | grep XDG
env | grep QT
echo "1:  ----------------------------------------- ${XDG_CURRENT_DESKTOP}"

export QT_QPA_PLATFORM=wayland
export GTK_USE_PORTAL=1
export GDK_DEBUG=portals
export QT_DEBUG_PLUGINS=1

DISPLAY= WAYLAND_DISPLAY=gamescope-0 systemctl start --user xdg-desktop-portal-wlr
WAYLAND_DISPLAY=gamescope-0 systemctl start --user xdg-desktop-portal-gtk
WAYLAND_DISPLAY=gamescope-0 systemctl start --user xdg-desktop-portal

systemctl status --user xdg-desktop-portal-wlr
systemctl status --user xdg-desktop-portal-gtk
$WAYLAND_DISPLAY=gamescope-0 /usr/lib/xdg-desktop-portal --replace --verbose -l TRACE &
systemctl status --user xdg-desktop-portal

export PATH=/opt/cuda/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/opt/cuda/lib64

echo "2:  ----------------------------------------- ${XDG_CURRENT_DESKTOP}"
env | grep XDG
env | grep DISPLAY
env | grep WAYLAND
env | grep DESKTOP

#WAYLAND_DISPLAY=gamescope-0 /usr/lib/xdg-desktop-portal-wlr -l TRACE &
#WAYLAND_DISPLAY=gamescope-0 /usr/lib/plasma-xdg-desktop-portal-kde -l TRACE &


# dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=gamescope

WAYLAND_DISPLAY=gamescope-0 sunshine &
#sunshine &
WAYLAND_DISPLAY=gamescope-0 xrandr -q
WAYLAND_DISPLAY=gamescope-0 wlr-randr -q
WAYLAND_DISPLAY=gamescope-0 vainfo
WAYLAND_DEBUG=1 vkcube
#glxgears
