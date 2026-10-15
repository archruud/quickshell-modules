#!/usr/bin/env bash
set -Eeuo pipefail
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/archruud-kairos-original"
[[ -f "$DEST/shell.qml" ]] || { echo 'The test module is not installed; no action taken.'; exit 0; }
printf 'Removing only %s\n' "$DEST"
rm -rf -- "$DEST"
printf 'Personal settings and previous backups are preserved.\n'
