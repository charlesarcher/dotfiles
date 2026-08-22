#!/bin/bash

# echo enabled |sudo tee /sys/bus/usb/devices/*/power/wakeup
echo "Disabling Display DP-2"
xrandr --output DP-2 --off
sleep 2

echo "Disabling Display DP-0"
xrandr --output DP-0  --off
sleep 2

echo "Disabling Display DP-4.8"
xrandr --output DP-4.8 --off
sleep 2


echo "Enabling Displays"
xrandr --output DP-4.8 --auto --output DP-0 --mode 3440x1440 --rate 120 --below DP-4.8 --output DP-2 --mode 1920x1200 --right-of DP-0 --primary
