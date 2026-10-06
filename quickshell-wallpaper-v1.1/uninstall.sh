#!/usr/bin/env bash
set -euo pipefail

rm -rf "$HOME/.config/quickshell/wallpaper"
rm -f "$HOME/.config/hypr/module-config/quickshell-wallpaper.lua"

HYPR="$HOME/.config/hypr/hyprland.lua"
if [[ -f "$HYPR" ]]; then
    sed -i '/require("module-config\.quickshell-wallpaper")/d' "$HYPR"
fi

pkill -f 'qs -c wallpaper' 2>/dev/null || true

echo "ARCHRUUD Wallpaper-modulen er fjernet."
echo "awww og wallpaper-filene er ikke slettet."
