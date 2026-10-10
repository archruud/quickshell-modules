# ARCHRUUD Wallpaper Bottom v1.0

A standalone, bottom-attached wallpaper selector for **Arch Linux + Hyprland (Lua) + Quickshell**.

This release packages the **user-tested v0.3.2 QML** unchanged, together with the existing working `awww` wallpaper scripts. No new UI features have been introduced.

## Features

- Bottom-attached, dark-blue panel with curved shoulders and rounded upper corners
- **Exactly two visible rows**, with a five-column viewport at the tested desktop size
- Horizontal browsing with the **mouse wheel**, **without a visible scrollbar** (intentional minimal design)
- Keyboard arrow navigation; **Enter** applies the selected image; **Esc** closes
- **SUPER+W** toggles the panel via the existing Hyprland Lua module
- All / Dark / Light filters (based on filename prefix `dark-` or `light-`)
- Refresh button; auto-close after five seconds of inactivity
- Wallpaper state shared via `~/.local/state/archruud/wallpaper/current-wallpaper`
- Existing wallpaper images and unrelated Quickshell modules are left untouched

## Navigation

**No scrollbar is shown.** Hover over the thumbnail area and use the mouse wheel to move sideways through wallpapers. You can also use Left/Right/Up/Down and Enter. Keyboard input requires focus; click a thumbnail if arrow keys do not initially respond.

If more images exist than fit in two rows, they remain accessible by scrolling horizontally. The panel does not grow to a third row.

## Files and integration

- Quickshell config: `~/.config/quickshell/archruud-wallpaper-bottom/`
- Wallpapers: `~/.config/hypr/wallpapers/`
- Existing Lua binding: `~/.config/hypr/module-config/quickshell-wallpaper.lua`
- State: `~/.local/state/archruud/wallpaper/current-wallpaper`
- Installer backups: `~/.local/state/archruud/wallpaper-bottom-backups/`

`awww` and Quickshell must already be installed. This module does not install system packages.

See [INSTALL.md](INSTALL.md) for installation, tests, and rollback.

## Scope

This module is the wallpaper picker, **not** the future bottom-edge App Launcher. Wallpaper opens with SUPER+W; the planned launcher will open via SUPER+A and bottom-edge hover. They will share a visual and navigation pattern, but remain independent modules.
