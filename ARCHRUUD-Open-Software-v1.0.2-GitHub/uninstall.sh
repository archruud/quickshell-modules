#!/usr/bin/env bash
set -euo pipefail
DEST="$HOME/.config/quickshell/archruud-open-software"
if [[ -d "$DEST" ]]; then
    BACKUP="$HOME/.local/state/archruud/open-software-backups/uninstall-$(date +%Y%m%d-%H%M%S)-$$"
    mkdir -p "$BACKUP"
    mv "$DEST" "$BACKUP/archruud-open-software"
    echo "Moved installed module to $BACKUP"
else
    echo 'No installed module found.'
fi
