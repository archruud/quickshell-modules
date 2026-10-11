# ARCHRUUD App Launcher v1.0.2

A standalone, bottom-edge-attached Quickshell application launcher for Arch Linux, Hyprland Lua and Wayland.

## Features

- Two rows of installed application icons, sourced from `.desktop` entries.
- Five visible columns with horizontal navigation via mouse wheel or arrow keys.
- No visible scrollbar (intentional).
- Double-click or Enter to launch; Esc to close.
- Left-click the bottom-center edge (8-pixel invisible target), or press `SUPER+A`, to open.
- Five-second inactivity timeout, configurable to three seconds.
- Opening App Launcher requests the ARCHRUUD Wallpaper Bottom panel to close.
- Does not replace or uninstall Rofi.

## Configure inactivity timeout

File: `~/.config/quickshell/archruud-launcher/shell.qml`

Search for the line: `property int autoCloseMs: 5000`

Change `5000` to `3000` for three seconds. The timer uses `interval: root.autoCloseMs`. The line number may change with updates; search for `autoCloseMs` rather than relying on a fixed number. Restart this Quickshell configuration to apply the change.

## Known warnings

Some installed applications reference icon names unavailable in the current icon theme. These may produce harmless icon warnings.

See [INSTALL.md](INSTALL.md) for installation and Hyprland Lua integration.
