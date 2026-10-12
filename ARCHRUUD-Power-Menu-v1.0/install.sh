#!/usr/bin/env bash
set -euo pipefail
BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$BASE/config/quickshell/archruud-power-menu"
LUA_SRC="$BASE/config/hypr/module-config/archruud-power-menu.lua"
DEST="$HOME/.config/quickshell/archruud-power-menu"
LUA_DEST="$HOME/.config/hypr/module-config/archruud-power-menu.lua"
BACKUP="$HOME/.local/state/archruud/power-menu-backups/$(date +%Y%m%d-%H%M%S)-$$"
[[ -f "$SRC/shell.qml" && -f "$SRC/scripts/power-action.sh" && -f "$LUA_SRC" ]] || { echo 'ERROR: Incomplete package'; exit 1; }
mkdir -p "$BACKUP" "$(dirname "$DEST")" "$(dirname "$LUA_DEST")"
if [[ -d "$DEST" ]]; then cp -a "$DEST" "$BACKUP/archruud-power-menu"; fi
if [[ -f "$LUA_DEST" ]]; then cp -a "$LUA_DEST" "$BACKUP/archruud-power-menu.lua"; fi
mkdir -p "$DEST"
cp -a "$SRC/." "$DEST/"
cp -a "$LUA_SRC" "$LUA_DEST"
chmod +x "$DEST/scripts/power-action.sh"
printf 'Installed ARCHRUUD Power Menu v1.0\nBackup: %s\n' "$BACKUP"
printf 'Add require("module-config.archruud-power-menu") to ~/.config/hypr/hyprland.lua if not already present.\n'
printf 'If an existing SUPER+P binding exists, disable it first.\n'
printf 'No other Quickshell modules or main Hyprland Lua file were changed.\n'
