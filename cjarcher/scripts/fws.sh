#!/bin/bash

# /home/archerc/.local/share/Steam/steamapps/compatdata
# WINEPREFIX="/path/to/steamapps/compatdata/<app_id>/pfx" wine fws.exe
APPID=335300
WINE="/home/archerc/.steam/steam/steamapps/common/Proton\ -\ Experimental/files/bin/wine"

#WINEPREFIX="/home/archerc/.local/share/Steam/steamapps/compatdata/335300/pfx/

WINEPREFIX="/home/archerc/.local/share/Steam/steamapps/compatdata/${APPID}/pfx"


eval ${WINE} taskmgr.exe
