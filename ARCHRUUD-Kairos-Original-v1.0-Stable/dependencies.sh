#!/usr/bin/env bash
# Default: informational only. --install: install optional prereqs with pacman, never remove packages.
set -Eeuo pipefail
PACKAGES=(quickshell python networkmanager iproute2 bluez bluez-utils brightnessctl pipewire wireplumber libnotify glib2 fontconfig ttf-material-symbols-variable ttf-jetbrains-mono-nerd)
if [[ "${1:-}" == '--install' ]]; then
    echo 'Review the package transaction before you confirm.'
    sudo pacman -S --needed "${PACKAGES[@]}"
    fc-cache -f
    exit
fi
if [[ "${1:-}" != '' && "${1:-}" != '--check' ]]; then
    echo 'Usage: bash dependencies.sh [--check|--install]'; exit 2
fi
for pair in 'qs:quickshell' 'python3:python' 'nmcli:networkmanager' 'ip:iproute2' 'bluetoothctl:bluez-utils' 'brightnessctl:brightnessctl' 'wpctl:wireplumber' 'gdbus:glib2' 'notify-send:libnotify' 'fc-match:fontconfig'; do
    cmd="${pair%%:*}"; pkg="${pair#*:}"
    if command -v "$cmd" >/dev/null 2>&1; then printf 'OK       %-16s (%s)
' "$cmd" "$pkg";
    else printf 'MISSING  %-16s (pacman package: %s)
' "$cmd" "$pkg"; fi
done
if command -v fc-match >/dev/null; then
    for font in 'Material Symbols Rounded' 'JetBrainsMono Nerd Font'; do
        family="$(fc-match -f '%{family}
' "$font" 2>/dev/null | head -1)"
        if [[ "$family" == *"$font"* ]]; then echo "FONT OK      $font";
        else echo "FONT MISSING $font (matched: $family)"; fi
    done
fi
for unit in NetworkManager.service bluetooth.service; do
    if systemctl is-active --quiet "$unit"; then echo "SERVICE OK   $unit";
    else echo "SERVICE OFF  $unit (needed for corresponding functions)"; fi
done
echo 'Install missing prerequisites, if needed: bash dependencies.sh --install'
