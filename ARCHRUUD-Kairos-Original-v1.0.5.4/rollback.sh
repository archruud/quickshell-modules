#!/usr/bin/env bash
set -Eeuo pipefail
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/archruud-kairos-original"
BACKUP_BASE="${XDG_STATE_HOME:-$HOME/.local/state}/archruud/backups/kairos-original"
backup="$(find "$BACKUP_BASE" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | sort -r | head -n 1)"
[[ -n "$backup" && -f "$backup/shell.qml" ]] || { echo 'No previous standalone original-port backup found.' >&2; exit 2; }
[[ ! -e "$DEST" ]] || rm -rf -- "$DEST"
cp -a "$backup" "$DEST"
printf 'Restored: %s\n' "$backup"
