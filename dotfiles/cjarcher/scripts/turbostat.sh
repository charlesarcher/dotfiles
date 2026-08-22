#!/bin/bash

sudo sysctl -w vm.max_map_count=16777216
echo "190000000" | sudo tee /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw
sudo turbostat --Summary --interval 5 --show Avg_MHz,Busy%,Bzy_MHz,IRQ,PkgTmp,PkgWatt,GFXWatt

