#!/usr/bin/env bash
set -Eeuo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}ARCHRUUD 01 – Minimal Base${NC}"
echo "Dette installerer bare grunnlaget vi trenger."

mapfile -t PACMAN_PKGS < <(grep -Ev '^[[:space:]]*(#|$)' "$SCRIPT_DIR/pacman-packages.txt")

sudo pacman -Syu --needed "${PACMAN_PKGS[@]}"

echo
echo "Aktiverer systemtjenester..."
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now bluetooth.service

echo
echo "Aktiverer Hyprland sin polkit-agent som user service..."
systemctl --user enable --now hyprpolkitagent.service || true

echo
if ! command -v yay >/dev/null 2>&1; then
    echo -e "${YELLOW}yay finnes ikke. Installerer yay fra AUR...${NC}"
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    (
        cd "$tmpdir/yay"
        makepkg -si --noconfirm
    )
else
    echo "yay er allerede installert."
fi

if grep -Eq '^[[:space:]]*[^#[:space:]]' "$SCRIPT_DIR/aur-packages.txt"; then
    mapfile -t AUR_PKGS < <(grep -Ev '^[[:space:]]*(#|$)' "$SCRIPT_DIR/aur-packages.txt")
    yay -S --needed "${AUR_PKGS[@]}"
fi

echo
echo -e "${GREEN}01-base ferdig.${NC}"
echo "NetworkManager: $(systemctl is-enabled NetworkManager.service 2>/dev/null || true)"
echo "Bluetooth:      $(systemctl is-enabled bluetooth.service 2>/dev/null || true)"
echo
echo "Neste: cd ../02-fixes && ./install.sh"
