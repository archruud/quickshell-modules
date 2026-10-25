#!/usr/bin/env bash
set -Eeuo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HYPR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
MODULE_DIR="$HYPR_DIR/module-config"

echo -e "${GREEN}ARCHRUUD 02 – Post-install fixes${NC}"

mkdir -p "$MODULE_DIR"
install -m 0644 "$SCRIPT_DIR/../config/module-config/hyprland-base.lua" \
    "$MODULE_DIR/hyprland-base.lua"

# Norsk XDG-struktur – eksplisitt, så vi ikke er avhengige av at nb_NO.UTF-8
# allerede er generert som locale.
mkdir -p \
    "$HOME/Skrivebord" \
    "$HOME/Nedlastinger" \
    "$HOME/Maler" \
    "$HOME/Offentlig" \
    "$HOME/Dokumenter" \
    "$HOME/Musikk" \
    "$HOME/Bilder" \
    "$HOME/Videoer"

xdg-user-dirs-update --set DESKTOP "$HOME/Skrivebord"
xdg-user-dirs-update --set DOWNLOAD "$HOME/Nedlastinger"
xdg-user-dirs-update --set TEMPLATES "$HOME/Maler"
xdg-user-dirs-update --set PUBLICSHARE "$HOME/Offentlig"
xdg-user-dirs-update --set DOCUMENTS "$HOME/Dokumenter"
xdg-user-dirs-update --set MUSIC "$HOME/Musikk"
xdg-user-dirs-update --set PICTURES "$HOME/Bilder"
xdg-user-dirs-update --set VIDEOS "$HOME/Videoer"

# Dolphin -> Kitty.
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"
KDEGLOBALS="${XDG_CONFIG_HOME:-$HOME/.config}/kdeglobals"
touch "$KDEGLOBALS"

if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file kdeglobals --group General --key TerminalApplication kitty
    kwriteconfig6 --file kdeglobals --group General --key TerminalService kitty.desktop
else
    # Fallback: legg til en General-seksjon. Dolphin leser siste verdi.
    cat >> "$KDEGLOBALS" <<'EOF'

[General]
TerminalApplication=kitty
TerminalService=kitty.desktop
EOF
fi

# Standardprogrammer. Brukeren kan endre disse senere.
xdg-mime default org.kde.dolphin.desktop inode/directory || true
xdg-mime default org.kde.gwenview.desktop image/png || true
xdg-mime default org.kde.gwenview.desktop image/jpeg || true
xdg-mime default org.kde.gwenview.desktop image/webp || true

# Xournal++ desktop-id varierer historisk; finn faktisk desktop-fil.
XOURNAL_DESKTOP="$(basename "$(find /usr/share/applications -maxdepth 1 -type f \
    \( -iname '*xournal*.desktop' -o -iname '*xournalpp*.desktop' \) -print -quit 2>/dev/null || true)")"
if [[ -n "$XOURNAL_DESKTOP" ]]; then
    xdg-mime default "$XOURNAL_DESKTOP" application/pdf || true
fi

# Sørg for at Hyprland polkit-agent er aktiv.
systemctl --user enable --now hyprpolkitagent.service || true

echo
echo -e "${YELLOW}VIKTIG – én manuell linje i hyprland.lua:${NC}"
echo 'require("module-config.hyprland-base")'
echo
echo "Kontroll:"
echo "  systemctl --user status hyprpolkitagent.service"
echo "  xdg-mime query default inode/directory"
echo "  xdg-mime query default application/pdf"
echo
echo -e "${GREEN}02-fixes ferdig.${NC}"
