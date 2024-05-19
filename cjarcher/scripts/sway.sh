#!/bin/bash


export DESKTOP_SESSION="sway"
export XDG_CURRENT_DESKTOP="sway"
export XDG_SESSION_DESKTOP="sway"
export XDG_SESSION_TYPE="wayland"
export WLR_BACKENDS="headless,libinput"
export WLR_LIBINPUT_NO_DEVICES="1"
XDG_CURRENT_DESKTOP=sway sway --unsupported-gpu
