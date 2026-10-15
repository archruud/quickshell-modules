#!/usr/bin/env bash
set -Eeuo pipefail
BACKEND="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/archruud-kairos-original/scripts/backend.py"
[[ -f "$BACKEND" ]] || { echo "Install ARCHRUUD Kairos first: $BACKEND" >&2; exit 2; }
MODE="${1:-status}"
case "$MODE" in
 status)
   python3 "$BACKEND" settings | python3 -c 'import json,sys;s=json.load(sys.stdin); print("Selected weather mode:",s.get("weatherSpot","auto"));print("Home:",s.get("locations",{}).get("home"));print("Cabin:",s.get("locations",{}).get("cabin"))'
   ;;
 auto|home|cabin)
   python3 "$BACKEND" set weatherSpot "\"$MODE\""
   echo "Selected weather mode: $MODE"
   echo "Restart Kairos or select the mode in the Weather screen to refresh immediately."
   ;;
 test)
   python3 "$BACKEND" weather | python3 -c 'import json,sys;w=json.load(sys.stdin); print("Available:",w.get("available"));print("Mode:",w.get("selectedSpot"));print("Location:",w.get("location"));print("Temperature:",w.get("tempNow"));print("Status:",w.get("status"));print("24-hour entries:",len(w.get("hourly",[])));print("Daily entries:",len(w.get("daily",[])))'
   ;;
 *)
   echo 'Usage: bash weather.sh {status|auto|home|cabin|test}' >&2
   exit 2
   ;;
esac
