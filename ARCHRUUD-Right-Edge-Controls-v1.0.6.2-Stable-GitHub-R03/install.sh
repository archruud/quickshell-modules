#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell"
POWER="$CONF/archruud-power-menu"
SCENE="$CONF/archruud-kairos-original/Scene.qml"
SRC_POWER="$ROOT/config/quickshell/archruud-power-menu"
SRC_SCENE="$ROOT/integration/quickshell/archruud-kairos-original/Scene.qml"
OLD_SCENE_SHA="cf050c0d4830ec6c8cbe69e9174b4a6823c44be7c4e3a66d4ec7337dc4835ed0"
NEW_SCENE_SHA="4eb2d935b316e00d2be01bf60bac364566d8b7496c73418b0362ae4d5e9fc329"

check() {
    bash "$ROOT/verify.sh"
    echo
    echo 'Existing installation:'
    if [[ -f "$POWER/shell.qml" ]]; then
        if cmp -s "$SRC_POWER/shell.qml" "$POWER/shell.qml"; then
            echo "  OK     $POWER/shell.qml (already identical)"
        else
            echo "  DIFF   $POWER/shell.qml"
        fi
    else echo "  MISSING $POWER/shell.qml"; fi
    if [[ -f "$SCENE" ]]; then
        sha="$(sha256sum "$SCENE" | awk '{print $1}')"
        if [[ "$sha" == "$NEW_SCENE_SHA" ]]; then
            echo "  OK     $SCENE (already compatible)"
        elif [[ "$sha" == "$OLD_SCENE_SHA" ]]; then
            echo "  READY  $SCENE (known earlier Kairos release)"
        else
            echo "  STOP   $SCENE (customized; installer will not overwrite)"
        fi
    else echo "  MISSING $SCENE (install Kairos first)"; fi
    helper="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/archruud-power-action.sh"
    if [[ -x "$helper" ]]; then echo '  OK     existing Power Foundation action helper';
    else echo "  NOTE   $helper missing (power actions require it)"; fi
    echo 'No running programs, Hyprland bindings or other modules were changed.'
}

install() {
    bash "$ROOT/verify.sh" >/dev/null
    [[ -f "$SCENE" ]] || { echo "STOP: Kairos Scene missing: $SCENE" >&2; exit 2; }
    sha="$(sha256sum "$SCENE" | awk '{print $1}')"
    if [[ "$sha" != "$OLD_SCENE_SHA" && "$sha" != "$NEW_SCENE_SHA" ]]; then
        echo "STOP: Kairos Scene differs from the verified source. No files changed." >&2
        echo "Found hash: $sha" >&2
        exit 2
    fi
    backroot="${XDG_STATE_HOME:-$HOME/.local/state}/archruud/backups/right-edge-controls"
    backup="$backroot/$(date +%Y%m%d-%H%M%S)-$$"
    mkdir -p "$backup"
    if [[ -d "$POWER" ]]; then
        cp -a "$POWER" "$backup/power-original"
        echo '1' > "$backup/power-existed"
    else
        echo '0' > "$backup/power-existed"
    fi
    cp -a "$SCENE" "$backup/Scene-original.qml"
    echo "$CONF" > "$backup/config-root"
    # Stage first; do not alter the working installation if a copy fails.
    stage="$(mktemp -d "$backup/stage.XXXXXXXX")"
    cp -a "$SRC_POWER" "$stage/new-power"
    cp -a "$SRC_SCENE" "$stage/new-Scene.qml"
    # Install the complete verified Power Menu directory as one tree.
    # Backups remain separate; this modifies no unrelated module or autostart.
    mkdir -p "$CONF"
    if [[ -d "$POWER" ]]; then mv "$POWER" "$backup/power-replaced-at-install"; fi
    mv "$stage/new-power" "$POWER"
    cp "$stage/new-Scene.qml" "$SCENE"
    rm -rf "$stage"
    echo "Installed. Backup: $backup"
    echo "Rollback: bash rollback.sh '$backup'"
    echo 'Log out and back in or reboot. Do not start a duplicate Quickshell process.'
}

case "${1:---check}" in
  --check) check ;;
  --install) install ;;
  *) echo 'Usage: bash install.sh [--check|--install]' >&2; exit 2 ;;
esac
