# ARCHRUUD App Launcher v1.0.2

**Release tag:** `v1.0.2`  
**Release title:** `ARCHRUUD App Launcher v1.0.2 — Click-to-open edge trigger`

## What's new

The bottom-center screen-edge launcher trigger has been changed from hover activation to **left-click activation**. Moving the mouse to the screen edge no longer opens the launcher accidentally. Click once at the bottom-center edge to open it. The invisible target area has been increased from 2 to 8 pixels.

`SUPER+A` remains available and unchanged.

## Other features (unchanged)
- Bottom-centered, two-row Quickshell app launcher
- Desktop-entry application discovery and icons
- Mouse wheel and arrow-key navigation
- Double-click or Enter to launch, Esc to close
- Configurable inactivity timeout (default: 5 seconds)
- Hyprland Lua configuration and Wallpaper Bottom coordination

## Installation / upgrade
1. Extract `ARCHRUUD-App-Launcher-v1.0.2-GitHub.zip`.
2. Run `bash install.sh` from the extracted folder. The installer backs up existing launcher files before replacing them.
3. Follow `INSTALL.md` for the `hyprland.lua` import if this is your first installation. Existing users should avoid adding duplicate `SUPER+A` bindings.
4. Restart the running `archruud-launcher` Quickshell configuration to load the updated QML.

## Verification
- Move the mouse to the bottom-center edge without clicking: the launcher should stay closed.
- Left-click at the bottom-center edge: the launcher should open.
- Press `SUPER+A`: the launcher should still open/toggle.

## Compatibility
Arch Linux, Hyprland with Lua configuration, Quickshell, Wayland.

See `README.md`, `INSTALL.md` and `CHANGELOG.md` for details.
