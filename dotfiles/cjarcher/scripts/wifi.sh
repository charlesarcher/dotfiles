#!/bin/bash

# wpa_cli -p /var/run/wpa_supplicant/cat /etc/wpa_supplicant/wpa_supplicant.conf
[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"

systemctl stop NetworkManager
systemctl stop wpa_supplicant
wpa_supplicant -B -i wlp2s0 -c /etc/wpa_supplicant/wpa_supplicant.conf
dhclient wlp2s0
