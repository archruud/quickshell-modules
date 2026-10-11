#!/usr/bin/env bash
set -euo pipefail
BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$BASE/config/quickshell/archruud-launcher"
DEST="$HOME/.config/quickshell/archruud-launcher"
LUA_SRC="$BASE/config/hypr/module-config/archruud-app-launcher.lua"
LUA_DEST="$HOME/.config/hypr/module-config/archruud-app-launcher.lua"
BACKUP="$HOME/.local/state/archruud/launcher-backups/$(date +%Y%m%d-%H%M%S)-$$"
[[ -f "$SRC/shell.qml" && -f "$LUA_SRC" ]] || { echo 'ERROR: Package incomplete'; exit 1; }
mkdir -p "$BACKUP" "$(dirname "$DEST")" "$(dirname "$LUA_DEST")"
[[ ! -d "$DEST" ]] || cp -a "$DEST" "$BACKUP/archruud-launcher"
[[ ! -e "$LUA_DEST" ]] || cp -a "$LUA_DEST" "$BACKUP/archruud-app-launcher.lua"
mkdir -p "$DEST"
cp -a "$SRC/." "$DEST/"
cp -a "$LUA_SRC" "$LUA_DEST"
chmod +x "$DEST/scripts/"*.py
printf 'Installed ARCHRUUD App Launcher v1.0.2\nBackup: %s\n' "$BACKUP"
echo 'NEXT: See INSTALL.md to disable old Rofi SUPER+A binding and add the require line.'
echo 'The installer intentionally does NOT modify hyprland.lua or existing Rofi bindings.'
