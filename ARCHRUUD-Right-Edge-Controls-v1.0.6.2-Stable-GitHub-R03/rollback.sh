#!/usr/bin/env bash
set -Eeuo pipefail
if [[ $# -ne 1 ]]; then echo 'Usage: bash rollback.sh /absolute/backup/path' >&2; exit 2; fi
backup="$(realpath -- "$1")"
[[ -f "$backup/config-root" && -f "$backup/power-existed" && -f "$backup/Scene-original.qml" ]] || {
    echo 'STOP: Invalid backup or missing files. Nothing changed.' >&2; exit 2;
}
CONF="$(cat "$backup/config-root")"
[[ "$CONF" == /* && "$CONF" == */quickshell ]] || { echo 'STOP: unexpected target path' >&2; exit 2; }
POWER="$CONF/archruud-power-menu"
SCENE="$CONF/archruud-kairos-original/Scene.qml"
[[ -d "$CONF/archruud-kairos-original" ]] || { echo 'STOP: Kairos target missing' >&2; exit 2; }
# Keep a copy of the current files before rolling back.
rollback_backup="$backup/before-rollback-$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$rollback_backup"
[[ ! -d "$POWER" ]] || cp -a "$POWER" "$rollback_backup/power-current"
[[ ! -f "$SCENE" ]] || cp -a "$SCENE" "$rollback_backup/Scene-current.qml"
rm -rf "$POWER"
if [[ "$(cat "$backup/power-existed")" == 1 ]]; then
    [[ -d "$backup/power-original" ]] || { echo 'STOP: Power backup missing' >&2; exit 3; }
    cp -a "$backup/power-original" "$POWER"
fi
cp -a "$backup/Scene-original.qml" "$SCENE"
echo "Rollback completed from $backup"
echo "Pre-rollback safety copy: $rollback_backup"
echo 'Log out and back in or reboot; do not launch duplicate Quickshell instances.'
