#!/usr/bin/env bash
set -euo pipefail
DEST="$HOME/.config/quickshell/archruud-power-menu"
LUA_DEST="$HOME/.config/hypr/module-config/archruud-power-menu.lua"
echo 'Before uninstalling, comment out require("module-config.archruud-power-menu") in ~/.config/hypr/hyprland.lua.'
read -r -p 'Remove installed Power Menu files? [y/N] ' answer
[[ "$answer" == [yY] ]] || exit 0
rm -rf -- "$DEST"
rm -f -- "$LUA_DEST"
echo 'Removed installed Power Menu files. Backups remain under ~/.local/state/archruud/power-menu-backups/.'
