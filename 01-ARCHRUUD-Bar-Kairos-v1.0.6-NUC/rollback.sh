#!/usr/bin/env bash
set -Eeuo pipefail
[[ $# -eq 1 ]] || { echo 'Usage: bash rollback.sh /absolute/backup/path'; exit 2; }
BACKUP="$1"
MODULE="archruud-kairos-original"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/$MODULE"
[[ -d "$BACKUP" ]] || { echo 'Backup folder missing'; exit 2; }
if [[ -d "$BACKUP/replaced-original" ]]; then
    mv "$TARGET" "${TARGET}.rollback-$(date +%Y%m%d-%H%M%S)"
    cp -a "$BACKUP/replaced-original" "$TARGET"
elif [[ -f "$BACKUP/was-absent" ]]; then
    mv "$TARGET" "${TARGET}.rollback-$(date +%Y%m%d-%H%M%S)"
else echo 'Unrecognized backup'; exit 2; fi
echo "Restored: $TARGET"
