#!/bin/sh

# PROTON_HIDE_NVIDIA_GPU=0 PROTON_ENABLE_NVAPI=1 WINE_FULLSCREEN_FSR=1 DXVK_ASYNC=1 mangohud gamemoderun %command%

# Application path
APP_PATH="$(dirname "${BASH_SOURCE[0]}")"
APP_PATH='/home/archerc/.local/share/Steam/steamapps/common/Dark Souls II Scholar of the First Sin/Game'
cd "$APP_PATH"

# Executable file
APP_EXEC="$APP_PATH/DarkSoulsII.exe"

# Steam / IDs
export SteamAppId="335300"
export SteamGameId="335300"

# Steam / Client path
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam"

# Steam / Apps path
STEAM_APPS_PATH="$STEAM_COMPAT_CLIENT_INSTALL_PATH/steamapps"

# Steam / Compat data path
export STEAM_COMPAT_DATA_PATH="$STEAM_APPS_PATH/compatdata/$SteamAppId"

# Proton / Path
PROTON_PATH="$STEAM_APPS_PATH/common/Proton - Experimental"

# Proton / Executable script
PROTON_EXEC="$PROTON_PATH/proton"

python "$PROTON_EXEC" run "$APP_EXEC"
