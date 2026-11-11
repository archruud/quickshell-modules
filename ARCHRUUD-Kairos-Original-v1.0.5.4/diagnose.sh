#!/usr/bin/env bash
# Read-only troubleshooting: does not change audio devices, services or settings.
set -uo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CTL="$HERE/config/quickshell/archruud-kairos-original/scripts/notifications_control.py"
if [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/archruud-kairos-original/scripts/notifications_control.py" ]]; then
    CTL="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/archruud-kairos-original/scripts/notifications_control.py"
fi
printf '\n=== ARCHRUUD Kairos v1.0.1 troubleshooting ===\n'
printf '\n[Audio services]\n'
for name in wpctl pactl; do command -v "$name" || true; done
for service in pipewire.service pipewire-pulse.service wireplumber.service; do
    if command -v systemctl >/dev/null; then
        printf '%-26s %s\n' "$service" "$(systemctl --user is-active "$service" 2>/dev/null || true)"
    fi
done
if command -v wpctl >/dev/null; then
    printf '\n[Default output volume]\n'
    wpctl get-volume '@DEFAULT_AUDIO_SINK@' 2>&1 || true
    printf '\n[Default input volume]\n'
    wpctl get-volume '@DEFAULT_AUDIO_SOURCE@' 2>&1 || true
    printf '\n[Devices / defaults -- look for * next to the selected sink]\n'
    wpctl status 2>&1 || true
fi
printf '\n[Notification service]\n'
python3 "$CTL" status 2>&1 || true
printf '\n[Notification owner PID]\n'
python3 - "$CTL" <<'PYCODE'
import importlib.util, sys
spec=importlib.util.spec_from_file_location('kairos_notifications', sys.argv[1])
m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
pid=m.notification_owner_pid()
print(pid if pid is not None else 'No identifiable owner')
if pid:
    try:
        from pathlib import Path
        raw=Path('/proc')/str(pid)/'cmdline'
        bits=raw.read_bytes().split(b'\0')
        print('Owner command:', ' '.join(x.decode('utf8','replace') for x in bits if x)[:500])
    except (OSError, PermissionError): pass
PYCODE
printf '\n[Hyprland Lua audio-key definitions; source files only]\n'
if [[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/hypr" ]]; then
    grep -RnE 'XF86Audio(RaiseVolume|LowerVolume|Mute|MicMute)' "${XDG_CONFIG_HOME:-$HOME/.config}/hypr" --include='*.lua' 2>/dev/null | head -25 || true
fi
printf '\n[Done -- no changes made]\n'
