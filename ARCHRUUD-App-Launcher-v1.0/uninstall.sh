#!/usr/bin/env bash
set -euo pipefail
DEST="$HOME/.config/quickshell/archruud-launcher"
LUA="$HOME/.config/hypr/module-config/archruud-app-launcher.lua"
BACKUP="$HOME/.local/state/archruud/launcher-backups/uninstalled-$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$BACKUP"
[[ ! -d "$DEST" ]] || mv "$DEST" "$BACKUP/archruud-launcher"
[[ ! -f "$LUA" ]] || mv "$LUA" "$BACKUP/archruud-app-launcher.lua"
echo "Files moved to: $BACKUP"
echo 'IMPORTANT: Comment out the launcher require in hyprland.lua before reloading Hyprland.'
echo 'Restore the original Rofi binding if desired.'
