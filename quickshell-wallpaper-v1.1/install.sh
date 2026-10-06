#!/usr/bin/env bash
set -euo pipefail

BLUE='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

echo -e "${BLUE}ARCHRUUD Quickshell Wallpaper v1.1${RESET}"
echo "----------------------------------------"

if ! command -v qs >/dev/null 2>&1; then
    echo "Quickshell mangler. Installerer..."
    sudo pacman -S --needed quickshell
fi

if ! command -v awww >/dev/null 2>&1; then
    echo "Installerer awww..."
    sudo pacman -S --needed awww
fi

mkdir -p "$HOME/.config/quickshell"
mkdir -p "$HOME/.config/hypr/module-config"
mkdir -p "$HOME/.config/hypr/wallpapers"

if [[ -d "$HOME/.config/quickshell/wallpaper" ]]; then
    backup="$HOME/.config/quickshell/wallpaper.backup-$(date +%Y%m%d-%H%M%S)"
    echo -e "${YELLOW}Tar backup av eksisterende wallpaper-modul:${RESET}"
    echo "  $backup"
    cp -a "$HOME/.config/quickshell/wallpaper" "$backup"
fi

cp -a config/quickshell/wallpaper "$HOME/.config/quickshell/"
cp -a config/hypr/module-config/quickshell-wallpaper.lua \
      "$HOME/.config/hypr/module-config/quickshell-wallpaper.lua"

chmod +x "$HOME/.config/quickshell/wallpaper/scripts/"*.sh

HYPR="$HOME/.config/hypr/hyprland.lua"
IMPORT='require("module-config.quickshell-wallpaper")'

if [[ -f "$HYPR" ]]; then
    if ! grep -Fq "$IMPORT" "$HYPR"; then
        cp -a "$HYPR" "$HYPR.backup-wallpaper-$(date +%Y%m%d-%H%M%S)"
        tmp="$(mktemp)"
        awk -v import="$IMPORT" '
            BEGIN { inserted=0 }
            /^require\("module-config\./ && !inserted {
                print import
                inserted=1
            }
            { print }
            END {
                if (!inserted) {
                    print ""
                    print "-- ARCHRUUD Wallpaper module"
                    print import
                }
            }
        ' "$HYPR" > "$tmp"
        mv "$tmp" "$HYPR"
        echo "La til import i hyprland.lua."
    else
        echo "Wallpaper-import finnes allerede i hyprland.lua."
    fi
else
    echo -e "${YELLOW}Fant ikke $HYPR.${RESET}"
    echo "Legg inn manuelt:"
    echo "  $IMPORT"
fi

echo
echo -e "${GREEN}Installert.${RESET}"
echo "Bakgrunnsmappe:"
echo "  ~/.config/hypr/wallpapers"
echo
echo "Test uten logout:"
echo "  qs -c wallpaper"
echo
echo "I en annen terminal:"
echo "  qs ipc -c wallpaper call wallpaper toggle"
echo
echo "Etter neste Hyprland-start brukes SUPER+W."
