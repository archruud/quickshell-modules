#!/usr/bin/env bash
set -euo pipefail
BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$BASE/config/quickshell/archruud-wallpaper-bottom"
DEST="$HOME/.config/quickshell/archruud-wallpaper-bottom"
LUA="$HOME/.config/hypr/module-config/quickshell-wallpaper.lua"
BACKUP="$HOME/.local/state/archruud/wallpaper-bottom-backups/$(date +%Y%m%d-%H%M%S)-$$"
[[ -f "$SRC/shell.qml" ]] || { echo 'ERROR: Missing shell.qml'; exit 1; }
mkdir -p "$BACKUP" "$DEST"
if [[ -f "$DEST/shell.qml" ]]; then cp -a "$DEST" "$BACKUP/archruud-wallpaper-bottom"; fi
if [[ -f "$LUA" ]]; then cp -a "$LUA" "$BACKUP/quickshell-wallpaper.lua"; fi
cp -a "$SRC/." "$DEST/"
chmod +x "$DEST/scripts/"*.sh
if [[ -f "$LUA" ]]; then
  python3 - "$LUA" <<'PYINNER'
from pathlib import Path
import sys
p=Path(sys.argv[1]); s=p.read_text()
old_start='qs -c wallpaper'
old_toggle='qs ipc -c wallpaper call wallpaper toggle'
new_start='qs -c archruud-wallpaper-bottom'
new_toggle='qs ipc -c archruud-wallpaper-bottom call wallpaperBottom toggle'
if new_start in s and new_toggle in s:
    print('Wallpaper Lua integration already present.')
elif old_start in s and old_toggle in s:
    p.write_text(s.replace(old_start,new_start).replace(old_toggle,new_toggle))
    print('Updated existing wallpaper autostart and SUPER+W binding.')
else:
    print('WARNING: Unknown Lua binding format. Left Lua unchanged; see INSTALL.md.')
PYINNER
else
  echo 'WARNING: Wallpaper Lua module not found; see INSTALL.md for manual integration.'
fi
printf 'Installed ARCHRUUD Wallpaper Bottom v1.0\nBackup: %s\n' "$BACKUP"
echo 'Run: hyprctl reload'
echo 'For the current session, if not running: qs -c archruud-wallpaper-bottom'
echo 'Other Quickshell modules and the legacy wallpaper directory were not deleted.'
