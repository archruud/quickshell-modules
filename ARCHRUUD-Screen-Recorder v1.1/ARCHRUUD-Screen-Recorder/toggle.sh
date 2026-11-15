#!/usr/bin/env bash
# ONE keybinding: open recording picker if idle, stop gracefully if recording.
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

if bash "$SCRIPT_DIR/recorder.sh" status >/dev/null 2>&1; then
    exec bash "$SCRIPT_DIR/recorder.sh" stop
fi

# Do not open a second picker while slurp is selecting the recording area.
if bash "$SCRIPT_DIR/recorder.sh" busy >/dev/null 2>&1; then
    command -v notify-send >/dev/null 2>&1 && \
      notify-send -a 'ARCHRUUD Screen Recorder' 'Velg opptaksområde' \
      'Et områdevalg eller opptak er allerede i gang.' || true
    exit 0
fi

exec bash "$SCRIPT_DIR/open.sh"
