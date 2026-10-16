#!/usr/bin/env bash
set -euo pipefail

BASE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SRC="$BASE/config/quickshell/archruud-overview"
LUA_SRC="$BASE/config/hypr/module-config/archruud-overview.lua"
DEST="$HOME/.config/quickshell/archruud-overview"
LUA_DEST="$HOME/.config/hypr/module-config/archruud-overview.lua"
STATE="$HOME/.local/state/archruud/overview-backups"
BACKUP="$STATE/$(date +%Y%m%d-%H%M%S)-$$"

[[ -f "$SRC/shell.qml" && -f "$SRC/modules/overview/OverviewWidget.qml" && -f "$LUA_SRC" ]] || {
    echo 'ERROR: Package is incomplete.' >&2
    exit 1
}
if [[ -e "$DEST" && ! -d "$DEST" ]]; then
    echo "ERROR: Cannot install over non-directory: $DEST" >&2
    exit 1
fi
mkdir -p "$BACKUP" "$(dirname "$DEST")" "$(dirname "$LUA_DEST")"

if [[ -d "$DEST" ]]; then
    cp -a -- "$DEST" "$BACKUP/archruud-overview"
    echo yes > "$BACKUP/module-existed"
else
    echo no > "$BACKUP/module-existed"
fi
if [[ -e "$LUA_DEST" ]]; then
    cp -a -- "$LUA_DEST" "$BACKUP/archruud-overview.lua"
    echo yes > "$BACKUP/lua-existed"
else
    echo no > "$BACKUP/lua-existed"
fi

# Keep the user's actual settings on upgrades. The supplied config.json
# serves only as the initial default on a fresh installation.
TMP_CONFIG=''
if [[ -f "$DEST/config.json" ]]; then
    TMP_CONFIG="$(mktemp "$BACKUP/user-config.XXXXXXXX")"
    cp -a -- "$DEST/config.json" "$TMP_CONFIG"
fi
mkdir -p "$DEST"
cp -a -- "$SRC/." "$DEST/"
if [[ -n "$TMP_CONFIG" ]]; then
    cp -a -- "$TMP_CONFIG" "$DEST/config.json"
    rm -f -- "$TMP_CONFIG"
fi

# Do not replace a user's working Lua module on upgrade.
if [[ ! -e "$LUA_DEST" ]]; then
    cp -a -- "$LUA_SRC" "$LUA_DEST"
    echo 'Installed new Hyprland Lua module.'
else
    echo 'Existing Hyprland Lua module preserved.'
fi
printf '%s\n' "$BACKUP" > "$STATE/.last-backup"

echo 'ARCHRUUD Overview v1.0.1 installed.'
echo "Backup saved: $BACKUP"
echo 'hyprland.lua and the legacy overview configuration were NOT changed.'
echo 'Existing config.json was preserved if it existed.'
echo 'Restart the archruud-overview instance to load the installed version.'
echo 'New users: read INSTALL.md before adding the Lua require line.'
