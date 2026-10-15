# Install ARCHRUUD Kairos v1.0 Stable — Arch Linux with Lua Hyprland

The installed application is the exact known-working Kairos v0.4.2 Named Places configuration. Only autostart/deployment tools are new.

## A. Extract and install on the desktop

1. Extract the archive into Downloads. Open Kitty **inside the extracted folder**.
2. Stop any **manually** running `qs -c archruud-kairos-original` instance with Ctrl+C in its Kitty terminal.
3. Run:

```bash
bash dependencies.sh --check
bash install.sh
bash install-autostart.sh --dry-run
```

Read the proposed Lua diff. It should import Kairos once, disable the old `quickshell-clock` / `archruud-clock` module if present, and disable an exact active `hl.exec_cmd("dunst")` startup line if present. Any other modules are left untouched. Then:

```bash
bash install-autostart.sh
```

Autostart creates a separate Lua module under `~/.config/hypr/module-config/` and an import in `~/.config/hypr/hyprland.lua`:

```lua
require("module-config.archruud-kairos-original")
```

If the installer does not recognize a safe insertion point, **it exits without modifying Lua**. In that case send the output and relevant Lua imports, rather than forcing a guessed change. The package does not alter systemd startup or other modules.

## B. Set notification server

Kairos needs to be the **only** owner of `org.freedesktop.Notifications`. See `CLEANUP.md` for Dunst detection and cleanup. If currently opted in from the working version, keep the existing `notifications.enabled` flag. If not opted in and no other daemon owns the bus name:

```bash
python3 ~/.config/quickshell/archruud-kairos-original/scripts/notifications_control.py enable
```

Restart Kairos or log in again, and test `notify-send 'ARCHRUUD Kairos' 'Notifications work'`.

## C. Restart the desktop

Log out and back into Hyprland or reboot the computer. Merely reloading the Lua config may not fire `hyprland.start`.

After login, from the extracted folder:

```bash
bash post-reboot-check.sh
```

Check clock, music, notifications, sound, Wi-Fi, Bluetooth, weather, named place and saved UI padding. Initial graphical reboot and notification toast were confirmed by the user on their Arch/Hyprland desktop. Verify your own installation on every new computer.

## D. Backups / uninstall

- UI backup: `~/.local/state/archruud/backups/kairos-original/`
- Lua autostart backup: `~/.local/state/archruud/backups/kairos-autostart/`
- UI rollback: `bash rollback.sh`
- Lua autostart rollback: `bash rollback-autostart.sh`
- UI uninstall: `bash uninstall.sh` (inspect script first; won't remove unrelated standalone modules)
- The user settings file is separate and isn't overwritten by this installation.

## E. Manual editing (optional)

Use `nano -l ~/.config/hypr/hyprland.lua` to review your existing imports. If editing manually, the import line is `require("module-config.archruud-kairos-original")` and standalone file lives at `~/.config/hypr/module-config/archruud-kairos-original.lua`. Avoid adding a duplicate `hl.exec_cmd("qs -c archruud-kairos-original")` inside another module.
