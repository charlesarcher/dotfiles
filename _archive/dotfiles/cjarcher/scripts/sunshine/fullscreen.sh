#!/bin/bash

while true; do
    echo "Looping for Full Screen Steam"
  swaymsg -t subscribe '["window"]' |
    jq 'select(.change == "focus" or .change == "fullscreen_mode").container | if (.name == "Steam Big Picture Mode") then halt_error(127-.fullscreen_mode) else halt end'
    [[ $? -eq 127 ]] && swaymsg fullscreen enable
    sleep 1
done
