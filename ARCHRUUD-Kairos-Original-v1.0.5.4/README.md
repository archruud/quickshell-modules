# ARCHRUUD Kairos Original v1.0.5.4 — GitHub source release

A complete, reproducible ARCHRUUD Kairos Quickshell top bar for Arch Linux and
Lua-based Hyprland, with the **user-verified v1.0.5.4 vertical Volume + Monitor
Light interface**. This package consolidates the original v1.0.1
Audio/Notifications base and the following tested changes: interactive volume
OSD, brightness helper, Power Menu companion IPC and +20-QML-pixel alignment.

**GitHub-ready source snapshot; not a new graphical implementation.** It was
reconstructed from the original versioned ZIP artifacts, not guessed from screenshots.
The live Arch session and physical monitor cannot be reproduced inside the build
environment. The existing installation was verified through user-provided video.

## Features

- Dynamic centre-top clock/calendar, quick settings, music and notifications.
- MET Norway weather, Automatic/Home/Cabin/Selected places and named coordinates.
- Working PipeWire volume slider/mute with hardware-volume live OSD.
- Vertical Volume card above vertical Monitor Light card, side by side with the
  standalone six-action ARCHRUUD Power Menu, using its existing hover/SUPER+P
  trigger through Quickshell IPC.
- Per-machine Monitor Light via backlight or DDC/CI where supported. A real display
  must support brightness VCP control; the interface may say `N/A` otherwise.
- Safeguarded full-folder backup/rollback for Kairos. An **optional**, separately
  safeguarded Power Menu shell integration; no forced changes to Hyprland Lua.

## IMPORTANT: if v1.0.5.4 already works on your PC

**Do not reinstall it just to upload source to GitHub.** Upload the **contents of
this extracted folder** to your `quickshell-modules` repo under a new directory
(e.g. `ARCHRUUD-Kairos-Original-v1.0.5.4-GitHub/`). The installed Quickshell
config stays at `~/.config/quickshell/archruud-kairos-original/`, unchanged.
Do not rename that internal directory or its `archruud-kairos-original.lua` file.

## Install or upgrade Kairos on an Arch workstation

Read `INSTALL.md`, `UPGRADE.md`, `DEPENDENCIES.md` first, then from the extracted
release folder:

```bash
bash dependencies.sh --check
bash install.sh
```

The existing installer replaces **only**
`~/.config/quickshell/archruud-kairos-original/` after backing it up.
The saved personal settings in `~/.config/archruud/kairos-original/settings.json`
are outside this directory and are not overwritten.

For a **new** Lua-Hyprland install only (if Kairos autostart is not configured):

```bash
bash install-autostart.sh --dry-run
bash install-autostart.sh
```

The import is `require("module-config.archruud-kairos-original")`. Existing
users with working autostart must not add a second instance.

### Power Menu integration (optional, existing Power Menu only)

For an **unmodified** Power Menu shell matching the published v1.0.1 source,
this optional integration makes the companion cards open/close with Power Menu:

```bash
python3 install-power-companion.py --dry-run
python3 install-power-companion.py --install
```

If Power Menu is **already patched** as part of v1.0.5.3/v1.0.5.4, this script
will say it is already installed and change nothing. Any other Power Menu
source is refused, not overwritten. See `POWER-MENU-INTEGRATION.md`.

Restart your existing single user session / reboot to load the updated code.
**Do not run a second Quickshell Kairos instance in the background.**

## Volume keys and brightness

This release does **not** modify `hyprland.lua` volume keybindings.
The existing `wpctl` volume bindings on the Pulsar Xboard remain valid.
`monitor-setup.sh --check` performs a read-only DDC/CI check; installation of
`ddcutil` is optional and never automatic. See `POWER-MENU-INTEGRATION.md`
and `BRIGHTNESS.md`.

## Verify

```bash
bash verify-release.sh
bash post-reboot-check.sh
python3 ~/.config/quickshell/archruud-kairos-original/scripts/archruud_brightness.py status
```

Older documentation is retained in `README-v1.0.1.md` plus the individual guides.
See `CHANGELOG.md`, `RELEASE-NOTES.md`, and `GITHUB.md` for package history and
publishing instructions.
