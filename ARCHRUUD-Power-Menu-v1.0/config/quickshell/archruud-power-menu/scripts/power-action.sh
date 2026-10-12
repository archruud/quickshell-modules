#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
  lock) loginctl lock-session ;;
  logout) hyprctl dispatch exit ;;
  suspend) systemctl suspend ;;
  reboot) systemctl reboot ;;
  shutdown) systemctl poweroff ;;
  hibernate) systemctl hibernate ;;
  *) echo "Unsupported power action" >&2; exit 2 ;;
esac
