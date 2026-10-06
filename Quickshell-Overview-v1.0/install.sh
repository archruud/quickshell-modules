#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
QS_DIR="$HOME/.config/quickshell/overview"
HYPR_DIR="$HOME/.config/hypr"
MODULE_DIR="$HYPR_DIR/module-config"
SYSTEMD_DIR="$HOME/.config/systemd/user"
UPSTREAM="https://github.com/Shanu-Kumawat/quickshell-overview.git"
STAMP="$(date +%Y%m%d-%H%M%S)"

need_pkg() {
    command -v "$1" >/dev/null 2>&1 || sudo pacman -S --needed "$2"
}

need_pkg git git
need_pkg jq jq
need_pkg qs quickshell

mkdir -p "$HOME/.config/quickshell" "$MODULE_DIR" "$SYSTEMD_DIR"

if [[ -d "$QS_DIR/.git" ]]; then
    echo "Oppdaterer upstream quickshell-overview ..."
    git -C "$QS_DIR" pull --ff-only
elif [[ -e "$QS_DIR" ]]; then
    echo "Tar backup av eksisterende Overview: ${QS_DIR}.backup-${STAMP}"
    mv "$QS_DIR" "${QS_DIR}.backup-${STAMP}"
    git clone "$UPSTREAM" "$QS_DIR"
else
    git clone "$UPSTREAM" "$QS_DIR"
fi

# ARCHRUUD brukerconfig beholdes utenfor upstream-koden så langt upstream tillater.
if [[ -f "$QS_DIR/config.json" ]]; then
    cp -a "$QS_DIR/config.json" "$QS_DIR/config.json.backup-${STAMP}"
fi
cp "$ROOT/config/quickshell/overview/config.json" "$QS_DIR/config.json"
mkdir -p "$QS_DIR/scripts"
cp "$ROOT/scripts/sync-wallpaper.sh" "$QS_DIR/scripts/sync-wallpaper.sh"
chmod +x "$QS_DIR/scripts/sync-wallpaper.sh"

cp "$ROOT/config/hypr/module-config/quickshell-overview.lua" "$MODULE_DIR/quickshell-overview.lua"
cp "$ROOT/config/systemd/user/archruud-overview-wallpaper.path" "$SYSTEMD_DIR/"
cp "$ROOT/config/systemd/user/archruud-overview-wallpaper.service" "$SYSTEMD_DIR/"

HYPR="$HYPR_DIR/hyprland.lua"
REQ='require("module-config.quickshell-overview")'
if [[ -f "$HYPR" ]] && ! grep -Fq "$REQ" "$HYPR"; then
    cp -a "$HYPR" "$HYPR.backup-${STAMP}"
    # Sett import sammen med andre ARCHRUUD module imports dersom mulig.
    if grep -q '^require("module-config\.' "$HYPR"; then
        sed -i "0,/^require(\"module-config\./s//${REQ}\n&/" "$HYPR"
    else
        printf '\n%s\n' "$REQ" >> "$HYPR"
    fi
fi

systemctl --user daemon-reload
systemctl --user enable --now archruud-overview-wallpaper.path
"$QS_DIR/scripts/sync-wallpaper.sh" || true
hyprctl reload >/dev/null 2>&1 || true

echo
echo "ARCHRUUD Quickshell Overview v1.0 installert."
echo "Config: $QS_DIR/config.json"
echo "Keybind: CTRL + TAB"
echo "Special workspaces: overview.showSpecialWorkspaces"
echo "Grid: overview.rows / overview.columns"
