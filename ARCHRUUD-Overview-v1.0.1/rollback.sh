#!/usr/bin/env bash
set -euo pipefail
STATE="$HOME/.local/state/archruud/overview-backups"
DEST="$HOME/.config/quickshell/archruud-overview"
LUA_DEST="$HOME/.config/hypr/module-config/archruud-overview.lua"
BACKUP="${1:-}"
if [[ -z "$BACKUP" ]]; then
    [[ -s "$STATE/.last-backup" ]] || {
        echo 'ERROR: No last backup recorded; pass an exact backup folder.' >&2
        exit 1
    }
    BACKUP="$(cat "$STATE/.last-backup")"
fi
[[ -d "$BACKUP" && -f "$BACKUP/module-existed" && -f "$BACKUP/lua-existed" ]] || {
    echo 'ERROR: Missing or incomplete backup.' >&2
    exit 1
}
case "$(realpath -- "$BACKUP")" in
    "$(realpath -- "$STATE")"/*) ;;
    *) echo 'ERROR: Backup must be within the ARCHRUUD Overview backup directory.' >&2; exit 1 ;;
esac

# Restore only module-owned files; never edit hyprland.lua.
if [[ "$(cat "$BACKUP/module-existed")" = yes ]]; then
    [[ -d "$BACKUP/archruud-overview" ]] || { echo 'ERROR: Module backup missing.' >&2; exit 1; }
    rm -rf -- "$DEST"
    cp -a -- "$BACKUP/archruud-overview" "$DEST"
else
    rm -rf -- "$DEST"
fi
if [[ "$(cat "$BACKUP/lua-existed")" = yes ]]; then
    [[ -f "$BACKUP/archruud-overview.lua" ]] || { echo 'ERROR: Lua backup missing.' >&2; exit 1; }
    mkdir -p "$(dirname "$LUA_DEST")"
    cp -a -- "$BACKUP/archruud-overview.lua" "$LUA_DEST"
else
    rm -f -- "$LUA_DEST"
fi

echo "ARCHRUUD Overview rollback completed: $BACKUP"
echo 'Restart the Overview process. hyprland.lua is unchanged.'
