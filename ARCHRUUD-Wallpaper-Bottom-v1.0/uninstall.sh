#!/usr/bin/env bash
set -euo pipefail
DEST="$HOME/.config/quickshell/archruud-wallpaper-bottom"
echo 'ARCHRUUD Wallpaper Bottom safe removal'
echo 'This removes only the new QML module directory, NOT wallpapers, Lua bindings or other modules.'
if [[ -d "$DEST" ]]; then
  BACKUP="$HOME/.local/state/archruud/wallpaper-bottom-backups/uninstall-$(date +%Y%m%d-%H%M%S)-$$"
  mkdir -p "$BACKUP"
  mv "$DEST" "$BACKUP/archruud-wallpaper-bottom"
  echo "Module moved to: $BACKUP"
fi
echo 'IMPORTANT: Restore the original quickshell-wallpaper.lua from your install backup before reloading Hyprland.'
echo 'See INSTALL.md for rollback steps.'
