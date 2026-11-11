#!/usr/bin/env bash
# Controlled PipeWire command-line test. Only changes volume when asked.
set -Eeuo pipefail
command -v wpctl >/dev/null || { echo 'wpctl is missing (wireplumber)' >&2; exit 2; }
case "${1:-status}" in
  status) wpctl get-volume '@DEFAULT_AUDIO_SINK@';;
  up) wpctl set-volume -l 1.0 '@DEFAULT_AUDIO_SINK@' 5%+; wpctl get-volume '@DEFAULT_AUDIO_SINK@';;
  down) wpctl set-volume -l 1.0 '@DEFAULT_AUDIO_SINK@' 5%-; wpctl get-volume '@DEFAULT_AUDIO_SINK@';;
  mute) wpctl set-mute '@DEFAULT_AUDIO_SINK@' toggle; wpctl get-volume '@DEFAULT_AUDIO_SINK@';;
  *) echo 'Usage: bash audio-test.sh status|up|down|mute' >&2; exit 2;;
esac
