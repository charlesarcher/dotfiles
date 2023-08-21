#!/bin/bash

IFS=$'\n'
set -o noglob

echo " ================================================= "
echo "${@}"
declare -a ARGS
declare -a PRE

ARGS=("${@}")
PRE=("${@}")
unset 'PRE[-1]'

cmd=""
for i in "${ARGS[@]}"; do
    echo "---> $i"
    cmd+="'$i' "
done
$(eval "$cmd") &
sleep 1

cmd=""
for i in "${PRE[@]}"; do
    echo "---> $i"
    cmd+="'$i' "
done


echo "$cmd" FlawlessWidescreen.exe
echo " --------------- HERE ---------------"
cd '/home/archerc/.local/share/Steam/steamapps/compatdata/335300/pfx/drive_c/Program Files (x86)/Flawless Widescreen'
eval "$cmd" FlawlessWidescreen.exe
cd -

echo " --------------- HERE ---------------"

#cmd=("${*:1:99}")
#declare -a cmd
#cmd=("${@}")
#for i in "${cmd[@]}"; do
#    echo "------->" $i
#done




echo " ================================================= "

#protontricks-launch --appid 335300 --no-bwrap  -v FlawlessWidescreen.exe
#protontricks-launch --appid 335300 --no-bwrap  -v DarkSoulsII.exe

#/call/some/script
#steam steam//appid
#/call/another/script
