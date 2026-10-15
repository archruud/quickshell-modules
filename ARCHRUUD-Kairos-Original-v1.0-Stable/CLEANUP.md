# ARCHRUUD — Dunst and Rofi cleanup (optional)

**Do this after Kairos has started successfully and receives notifications.** The Lua installer only disables an exact, active `hl.exec_cmd("dunst")` line in `hyprland.lua`, if one exists. It does not remove Dunst, Rofi or services and does not touch unrelated module files.

First inspect where they might start:

```bash
pgrep -af 'dunst|rofi|mako|swaync'
systemctl --user status dunst.service --no-pager
rg -n -i 'dunst|rofi|mako|swaync|archruud-clock' ~/.config/hypr ~/.config/systemd/user ~/.config/autostart 2>/dev/null
```

If the `dunst.service` unit is running, stop it with `systemctl --user stop dunst.service`; `static` services cannot simply be disabled in all situations. If some other config starts Dunst, disable that *specific* entry first. Note: backup and example Lua files may contain obsolete mentions which are not active.

Once no other notification service owns the D-Bus name, use the installed Kairos control script (the release's `notifications.sh` targets the source release and may be run from there):

```bash
python3 ~/.config/quickshell/archruud-kairos-original/scripts/notifications_control.py enable
```

Restart Kairos (or log out and back in), then test:

```bash
notify-send 'ARCHRUUD Kairos' 'Notification delivery works'
```

**Only after confirmation**, optionally remove packages:

```bash
sudo pacman -Rns dunst
sudo pacman -Rns rofi
```

Review the pacman removal list before agreeing. Rofi should be removed **only if** your launcher, shortcuts and scripts no longer call `rofi`. Do not remove `libnotify`: `notify-send` is useful for testing and programs can still send notifications without Dunst. If removing `dunst` also proposes removing dependencies your environment uses, cancel and investigate.

If a notification test fails, restore the previous daemon or the autostart configuration using `rollback-autostart.sh`. The release never silently removes system packages.
