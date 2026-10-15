# ARCHRUUD Kairos Original — v1.0 Stable (GitHub-ready)

A complete standalone top-edge Quickshell Kairos bar for ARCHRUUD Desktop on Arch Linux / Lua-based Hyprland.

**Built from the user-tested and approved v0.4.2 Named Places package.** The QML and Python functionality, settings and appearance are preserved. This stable package adds independent Hyprland Lua autostart, safe preview/backup/rollback, dependency checking and reboot instructions. No automatic package removal.

## Features

- ARCHRUUD top-connected dynamic island clock with date wheel and independent left/right/top/bottom padding.
- Quickshell MPRIS now-playing music bubble, cover art and transport controls (for compatible players).
- Wi-Fi, Bluetooth, audio slider and brightness control.
- Native opt-in Quickshell notifications with blue toasts and session history (Dunst must not own the same session bus name).
- MET Norway weather, temperature in °C/°F, Automatic/Home/Cabin/Selected locations, 24-hour and 8-day forecasts.
- Search place names and coordinates; give custom labels to coordinate results (e.g. Ørje/Myson).
- Separate settings saved at `~/.config/archruud/kairos-original/settings.json`.

## Install (safe two-stage workflow)

In Kitty, from this extracted directory:

```bash
bash dependencies.sh --check
bash install.sh
bash install-autostart.sh --dry-run
bash install-autostart.sh
```

`install.sh` updates **only** `~/.config/quickshell/archruud-kairos-original` with timestamped backup of the previous UI. `install-autostart.sh` installs `~/.config/hypr/module-config/archruud-kairos-original.lua` and adds one import to the user's Lua `hyprland.lua`. It **backs up** the existing Lua configuration, comments out only explicitly matched legacy clock and Dunst autostart lines, and leaves all other modules intact. Read `INSTALL.md` and `REBOOT-CHECKLIST.md` before rebooting.

## Manual import (if you prefer to edit Lua yourself)

Open `nano -l ~/.config/hypr/hyprland.lua` and add this line **once**, beside the other `module-config` imports:

```lua
require("module-config.archruud-kairos-original")
```

The standalone module (`config/hypr/module-config/archruud-kairos-original.lua`) must also be placed in `~/.config/hypr/module-config/`. **Do not both manually add the line and run a second autostart entry.**

## After first login / reboot

```bash
bash post-reboot-check.sh
```

Read `REBOOT-CHECKLIST.md`, `DEPENDENCIES.md`, `CLEANUP.md`, `NOTIFICATIONS.md`, `WEATHER.md`, `LOCATION-SEARCH.md` and `GITHUB.md` for focused documentation. No webcam, GPS permission or custom Yr credential is required by this version; Automatic weather uses approximate IP location, not GPS.

## Rollback

```bash
bash rollback-autostart.sh   # restore Lua startup
bash rollback.sh             # restore prior QML installation
```

**Validation:** The user successfully verified startup after a full Arch/Hyprland reboot, including one Kairos instance and a working notification toast. Automated offline tests cover the source and deployment helpers. After installing on a different machine, check its own hardware/services using `bash post-reboot-check.sh`.
