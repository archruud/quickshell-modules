#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
TARGET="$HOME/.config/Quickshell/ScreenRecorder"
mkdir -p -- "$TARGET" "$HOME/Bilder/Skjermopptak"
# Only files in this module. Never touch other Quickshell modules or Hyprland.
for file in "$SCRIPT_DIR"/*.sh "$SCRIPT_DIR"/*.qml "$SCRIPT_DIR"/*.conf "$SCRIPT_DIR"/*.lua; do
    basename_file=${file##*/}
    if [[ "$(readlink -f "$file")" != "$(readlink -f "$TARGET/$basename_file" 2>/dev/null || true)" ]]; then
        install -m 755 "$file" "$TARGET/$basename_file"
    fi
done
chmod 644 "$TARGET"/*.qml "$TARGET"/*.conf "$TARGET"/*.lua
printf '\nARCHRUUD Screen Recorder v1.1 installert i %s\n' "$TARGET"
for cmd in quickshell wf-recorder slurp ffmpeg flock; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "MERK: Mangler $cmd"
    fi
done
cat <<NEXT

TEST NY TOGGLE:
  bash "$TARGET/toggle.sh"

VIKTIG: Oppdater KUN den eksisterende SUPER + SHIFT + R-bindingen i
hyprland.lua til dette (ikke opprett en ekstra binding for samme tast):
  hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("bash ~/.config/Quickshell/ScreenRecorder/toggle.sh"))

SUPER + SHIFT + R: Før opptak = åpne meny. Under opptak = stopp.
Etter områdevalget vises REC øverst til høyre; klikk på REC for stopp.
Du kan beholde SUPER + SHIFT + X som ekstra STOPP-tast.

Ikke gjort noen automatiske endringer i din hyprland.lua.
NEXT
