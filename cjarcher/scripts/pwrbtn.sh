#!/bin/bash -e

echo "XHCI" > /proc/acpi/wakeup

systemctl enable nvidia-suspend.service
systemctl enable nvidia-hibernate.service
systemctl enable nvidia-resume.service

#rm /lib/systemd/system-sleep/nvidia
