# Installation — ARCHRUUD App Launcher v1.0

## 1. Install

From this extracted directory:

```bash
bash install.sh
```

This backs up any existing launcher files and installs the QML, application discovery script, and the Lua module. **It does not modify `hyprland.lua` or the existing Rofi shortcut.**

## 2. Disable the old Rofi SUPER+A binding

Open the main Lua config:

```bash
nano -l ~/.config/hypr/hyprland.lua
```

Find the **existing Rofi binding for `SUPER + A`** (possibly in another imported module) and comment it out or remove it. **Do not remove unrelated Rofi shortcuts.** Do not enable the new binding until the old one is disabled.

## 3. Import the installed Lua module

In `~/.config/hypr/hyprland.lua`, alongside other `require(...)` statements, add exactly:

```lua
require("module-config.archruud-app-launcher")
```

The installed file is `~/.config/hypr/module-config/archruud-app-launcher.lua`. It defines the `SUPER+A` binding and launches the Quickshell config at a **new Hyprland login**.

Reload:

```bash
hyprctl reload
```

**Important:** `hyprctl reload` does not replay the `hyprland.start` event. Start the shell once in the current session if it is not running:

```bash
qs -c archruud-launcher
```

Do not run a second instance if the first one is already active. A full logout/login tests automatic startup.

## 4. Test

- `SUPER+A` toggles App Launcher; `SUPER+W` still opens Wallpaper Bottom.
- Hover at the bottom-center screen edge to open the launcher.
- Mouse wheel or arrow keys browse the two-row grid; there is intentionally no visible scrollbar.
- Double-click or Enter launches a selected app; Esc closes the panel.
- Opening the launcher closes the Wallpaper Bottom panel, if installed and running.

## 5. Change timeout from 5 to 3 seconds

```bash
nano -l ~/.config/quickshell/archruud-launcher/shell.qml
```

Find `property int autoCloseMs: 5000` near the beginning of `shell.qml` and change it to `property int autoCloseMs: 3000`. The timer reads this setting via `interval: root.autoCloseMs`. Restart only this Quickshell configuration after changing it.

## Rollback

First comment out `require("module-config.archruud-app-launcher")` in `hyprland.lua` and restore the original Rofi `SUPER+A` binding. Then run `hyprctl reload`. From the extracted package run `bash uninstall.sh` to move the installed launcher and Lua module into a dated backup folder. The installer also prints a backup path for any previous versions.

**Note:** The launcher closes Wallpaper when it opens. Wallpaper's own `SUPER+W` binding may need a matching close-launcher action to guarantee mutual exclusion when Wallpaper is opened second. This package does not silently modify the tested Wallpaper v1.0 module.
