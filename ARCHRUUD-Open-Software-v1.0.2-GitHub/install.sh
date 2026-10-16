#!/usr/bin/env bash
set -euo pipefail
BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$BASE/config/quickshell/archruud-open-software"
DEST="$HOME/.config/quickshell/archruud-open-software"
BACKUP_BASE="$HOME/.local/state/archruud/open-software-backups"
BACKUP="$BACKUP_BASE/$(date +%Y%m%d-%H%M%S)-$$"
for cmd in hyprctl python3 qs; do command -v "$cmd" >/dev/null || { echo "Missing $cmd" >&2; exit 1; }; done
for name in shell.qml scripts/list-windows.py scripts/focus-window.py; do [[ -f "$SRC/$name" ]] || { echo "Missing $name" >&2; exit 1; }; done
python3 - "$SRC" <<'PY_CHECK'
import ast,sys
from pathlib import Path
for name in ('list-windows.py','focus-window.py'):
    ast.parse((Path(sys.argv[1])/'scripts'/name).read_text())
PY_CHECK
mkdir -p "$BACKUP" "$(dirname "$DEST")"
if [[ -d "$DEST" ]]; then
    cp -a "$DEST" "$BACKUP/archruud-open-software"
    echo existing > "$BACKUP/install-state"
else
    echo absent > "$BACKUP/install-state"
fi
STAGE="$(dirname "$DEST")/.archruud-open-software-stage-$$"
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE"
cp -a "$SRC/." "$STAGE/"
chmod +x "$STAGE/scripts/"*.py
# Full backup is made before any existing files are replaced.
rm -rf "$DEST"
mv "$STAGE" "$DEST"
printf '%s\n' "$BACKUP" > "$BACKUP_BASE/last-install-backup"
echo 'Installed ARCHRUUD Open Software v1.0.2.'
echo "Backup of previous module: $BACKUP"
echo 'No other Quickshell modules or Hyprland Lua config changed.'
