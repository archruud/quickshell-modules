#!/usr/bin/env bash
# ARCHRUUD volume keys v1.0.3: direct PipeWire controls.
# Do not send notify-send: Kairos's live volume OSD observes the sink instead.
set -euo pipefail
sink='@DEFAULT_AUDIO_SINK@'
case "${1:-}" in
  up)    wpctl set-volume -l 1 "$sink" '5%+' ;;
  down)  wpctl set-volume "$sink" '5%-' ;;
  mute)  wpctl set-mute "$sink" toggle ;;
  status) ;;
  *) echo 'Usage: archruud-volume.sh {up|down|mute|status}' >&2; exit 2 ;;
esac
if [[ "${1:-}" == status ]]; then
  wpctl get-volume "$sink"
fi
