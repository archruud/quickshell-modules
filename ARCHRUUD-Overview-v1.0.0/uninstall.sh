#!/usr/bin/env bash
set -euo pipefail
DEST="$HOME/.config/quickshell/archruud-overview"
LUA_DEST="$HOME/.config/hypr/module-config/archruud-overview.lua"
HYPR="$HOME/.config/hypr/hyprland.lua"
STATE="$HOME/.local/state/archruud/overview-backups"

# Avoid leaving the Hyprland Lua configuration with a missing required module.
if [[ -f "$HYPR" ]] && grep -Eq '^[[:space:]]*require\(["\x27]module-config\.archruud-overview["\x27]\)' "$HYPR"; then
    echo 'ERROR: First comment out require("module-config.archruud-overview") in hyprland.lua.' >&2
    echo 'Then rerun uninstall.sh. No files were removed.' >&2
    exit 1
fi
BACKUP="$STATE/uninstall-$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$BACKUP"
if [[ -d "$DEST" ]]; then cp -a -- "$DEST" "$BACKUP/archruud-overview"; fi
if [[ -f "$LUA_DEST" ]]; then cp -a -- "$LUA_DEST" "$BACKUP/archruud-overview.lua"; fi
rm -rf -- "$DEST"
rm -f -- "$LUA_DEST"
echo 'ARCHRUUD Overview files removed; any original overview configuration remains untouched.'
echo "Uninstall backup: $BACKUP"
echo 'Restart Hyprland or reload only after checking your remaining bindings and startup.'
