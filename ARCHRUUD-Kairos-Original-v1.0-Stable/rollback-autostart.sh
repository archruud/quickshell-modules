#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/archruud/backups/kairos-autostart"
[[ -d "$ROOT" ]] || { echo 'No autostart backup found.'; exit 1; }
mapfile -t ALL < <(find "$ROOT" -mindepth 1 -maxdepth 1 -type d | sort -r)
(( ${#ALL[@]} )) || { echo 'No autostart snapshot found.'; exit 1; }
BACKUP="${ALL[0]}"
echo "Restore backup: $BACKUP"
echo 'WARNING: Any newer edits to hyprland.lua would be lost.'
read -r -p 'Type RESTORE to confirm: ' CONFIRM
[[ "$CONFIRM" == 'RESTORE' ]] || { echo 'Cancelled.'; exit 1; }
cp -a -- "$BACKUP/hyprland.lua" "$HOME/.config/hypr/hyprland.lua"
DEST="$HOME/.config/hypr/module-config/archruud-kairos-original.lua"
if [[ -f "$BACKUP/archruud-kairos-original.lua" ]]; then
    cp -a -- "$BACKUP/archruud-kairos-original.lua" "$DEST"
else
    rm -f -- "$DEST"
fi
echo 'Restored. Log out/in or reboot to apply.'
