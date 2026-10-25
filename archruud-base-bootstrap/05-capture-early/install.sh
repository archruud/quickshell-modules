#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

sudo pacman -S --needed grim slurp swappy jq wl-clipboard

mkdir -p "$HOME/.config/hypr/scripts" "$HOME/.config/hypr/module-config"
install -m 0755 "$SCRIPT_DIR/files/screenshot-window.sh" \
    "$HOME/.config/hypr/scripts/screenshot-window.sh"
install -m 0644 "$SCRIPT_DIR/quickshell-capture.lua" \
    "$HOME/.config/hypr/module-config/quickshell-capture.lua"

echo 'Legg til i hyprland.lua: require("module-config.quickshell-capture")'
echo "Hvis de samme tre screenshot-bindings allerede står i hyprland.lua,"
echo "fjern de gamle linjene først for å unngå doble bindings."
