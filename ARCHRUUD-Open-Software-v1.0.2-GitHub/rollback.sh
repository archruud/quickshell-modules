#!/usr/bin/env bash
set -euo pipefail
DEST="$HOME/.config/quickshell/archruud-open-software"
BASE="$HOME/.local/state/archruud/open-software-backups"
[[ -f "$BASE/last-install-backup" ]] || { echo 'No previous install backup recorded' >&2; exit 1; }
BACKUP="$(cat "$BASE/last-install-backup")"
[[ "$BACKUP" == "$BASE/"* && -f "$BACKUP/install-state" ]] || { echo 'Invalid backup' >&2; exit 1; }
STATE="$(cat "$BACKUP/install-state")"
[[ "$STATE" == existing || "$STATE" == absent ]] || { echo 'Invalid state' >&2; exit 1; }
if [[ "$STATE" == existing && ! -d "$BACKUP/archruud-open-software" ]]; then echo 'Missing original backup' >&2; exit 1; fi
if [[ -d "$DEST" ]]; then
    SAFETY="$BASE/pre-rollback-$(date +%Y%m%d-%H%M%S)-$$"
    mkdir -p "$SAFETY"
    cp -a "$DEST" "$SAFETY/archruud-open-software"
    echo "Preserved current module in: $SAFETY"
fi
rm -rf "$DEST"
if [[ "$STATE" == existing ]]; then
    cp -a "$BACKUP/archruud-open-software" "$DEST"
    echo 'Previous module restored.'
else
    echo 'Module removed; none was installed before.'
fi
rm -f "$BASE/last-install-backup"
