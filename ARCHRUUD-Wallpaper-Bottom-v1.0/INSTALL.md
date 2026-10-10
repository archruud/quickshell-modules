# Installation — ARCHRUUD Wallpaper Bottom v1.0

## Requirements

Arch Linux, a running Hyprland Lua configuration, Quickshell (`qs`), `awww`, Bash, and Python 3. Existing wallpapers should be placed in `~/.config/hypr/wallpapers/`.

## Install

Extract the ZIP and open a terminal in the `ARCHRUUD-Wallpaper-Bottom-v1.0` directory:

```bash
bash install.sh
hyprctl reload
```

If the wallpaper shell is not running in this session, start it:

```bash
qs -c archruud-wallpaper-bottom
```

Do **not** kill all `qs` processes; other modules such as Clock and Overview use separate instances.

### Hyprland Lua integration

The installer only modifies the known legacy wallpaper commands in `~/.config/hypr/module-config/quickshell-wallpaper.lua`, if both are found. It backs up that file first. It does not rewrite your main `hyprland.lua`.

Ensure the existing main Lua config already imports the wallpaper module:

```lua
require("module-config.quickshell-wallpaper")
```

The wallpaper module should start `qs -c archruud-wallpaper-bottom` on login and bind **SUPER+W** to:

```bash
qs ipc -c archruud-wallpaper-bottom call wallpaperBottom toggle
```

If the installer reports an unknown Lua format, edit your Lua config manually with `nano -l ~/.config/hypr/module-config/quickshell-wallpaper.lua` and update only the old wallpaper start/toggle commands; preserve other bindings.

## Test checklist

1. Press **SUPER+W**: the panel opens from the bottom of the screen.
2. Verify exactly **two rows** of thumbnails.
3. Move the mouse wheel over the thumbnails: additional images appear **horizontally**. There is **no visible scrollbar by design**.
4. Use arrow keys, Enter and Esc. Click a thumbnail once if keyboard focus is missing.
5. Check All, Dark, Light, Refresh, and five-second inactivity close.
6. Reboot/login later to verify autostart.

## Rollback

The installer prints its backup directory. To restore the previous Lua binding and QML directory, replace `BACKUP_PATH` below with the printed directory:

```bash
cp -a BACKUP_PATH/quickshell-wallpaper.lua ~/.config/hypr/module-config/quickshell-wallpaper.lua
```

If a previous module directory was backed up:

```bash
cp -a BACKUP_PATH/archruud-wallpaper-bottom/. ~/.config/quickshell/archruud-wallpaper-bottom/
```

Then run `hyprctl reload` and restart only the wallpaper shell as needed. If you prefer to remove the v1.0 module directory, run `bash uninstall.sh` **after** restoring your Lua binding. This script moves the directory to a backup rather than deleting it.

The legacy wallpaper configuration, wallpaper image directory, and all other modules are intentionally preserved.
