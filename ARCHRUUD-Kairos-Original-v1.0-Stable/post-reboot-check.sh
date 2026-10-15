#!/usr/bin/env bash
# Run from this folder after first full reboot.
set -u
CFG="$HOME/.config/hypr/hyprland.lua"
MOD="$HOME/.config/hypr/module-config/archruud-kairos-original.lua"
QML="$HOME/.config/quickshell/archruud-kairos-original/shell.qml"
echo '=== ARCHRUUD Kairos startup verification ==='
for f in "$CFG" "$MOD" "$QML"; do
    if [[ -f "$f" ]]; then printf 'OK      %s
' "$f";
    else printf 'MISSING %s
' "$f"; fi
done
if [[ -f "$CFG" ]]; then
    grep -nF 'require("module-config.archruud-kairos-original")' "$CFG" || echo 'IMPORT NOT FOUND'
fi
echo; echo '=== Quickshell instances (inspect for old clock / duplicate Kairos) ==='
pgrep -a -x qs || pgrep -af '[q]uickshell' || echo 'No Quickshell instance detected'
echo; echo '=== Other notification daemons ==='
pgrep -a -x dunst || echo 'Dunst is not running'
for cmd in qs python3 nmcli wpctl bluetoothctl; do
    command -v "$cmd" >/dev/null && echo "OK      $cmd" || echo "MISSING $cmd"
done
echo; echo '=== Font check ==='
if command -v fc-match >/dev/null; then fc-match -f '%{family}
' 'Material Symbols Rounded'; fi
echo; echo '=== Notification status ==='
if [[ -f "$HOME/.config/quickshell/archruud-kairos-original/scripts/notifications_control.py" ]]; then
    python3 "$HOME/.config/quickshell/archruud-kairos-original/scripts/notifications_control.py" status
fi
echo; echo 'Check the clock, named places, Wi-Fi, sound, Bluetooth and a fresh notification visually.'
echo 'Notification status running means this Kairos session owns the D-Bus notification name.'
