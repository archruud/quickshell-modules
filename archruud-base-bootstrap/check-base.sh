#!/usr/bin/env bash
set +e
echo "=== ARCHRUUD BASE CHECK ==="
for cmd in git yay qs nmcli wpctl bluetoothctl udisksctl dolphin kitty secret-tool; do
    if command -v "$cmd" >/dev/null 2>&1; then
        printf "OK   %-14s %s\n" "$cmd" "$(command -v "$cmd")"
    else
        printf "MISS %-14s\n" "$cmd"
    fi
done
echo
systemctl --no-pager --quiet is-active NetworkManager && echo "OK   NetworkManager active" || echo "MISS NetworkManager"
systemctl --no-pager --quiet is-active bluetooth && echo "OK   Bluetooth active" || echo "MISS Bluetooth"
systemctl --user --no-pager --quiet is-active hyprpolkitagent && echo "OK   hyprpolkitagent active" || echo "MISS hyprpolkitagent"
echo
echo "Directory handler: $(xdg-mime query default inode/directory 2>/dev/null)"
echo "PDF handler:       $(xdg-mime query default application/pdf 2>/dev/null)"
