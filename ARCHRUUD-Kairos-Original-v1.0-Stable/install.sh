#!/usr/bin/env bash
set -Eeuo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SRC="$HERE/config/quickshell/archruud-kairos-original"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/archruud-kairos-original"
BACKUP_BASE="${XDG_STATE_HOME:-$HOME/.local/state}/archruud/backups/kairos-original"
[[ -f "$SRC/shell.qml" && -f "$SRC/Scene.qml" ]] || { echo 'Incomplete release package' >&2; exit 2; }
command -v python3 >/dev/null || { echo 'Python 3 is required' >&2; exit 2; }
mkdir -p "$(dirname "$DEST")" "$BACKUP_BASE"
if [[ -e "$DEST" ]]; then
    backup="$BACKUP_BASE/$(date +%Y%m%d-%H%M%S)-$$"
    cp -a "$DEST" "$backup"
    printf 'Backup: %s\n' "$backup"
fi
TMP="$(mktemp -d "$(dirname "$DEST")/.archruud-kairos-original.XXXXXXXX")"
trap 'rm -rf -- "$TMP"' EXIT
cp -a "$SRC/." "$TMP/"
[[ ! -e "$DEST" ]] || rm -rf -- "$DEST"
mv "$TMP" "$DEST"
trap - EXIT
printf '\nInstalled in: %s\n' "$DEST"
printf 'Run first: python3 %s/scripts/check.py\n' "$DEST"
printf 'Start using: qs -c archruud-kairos-original\n'
printf 'No changes to archruud-kairos, hyprland.lua, systemd, or autostart.\n'
