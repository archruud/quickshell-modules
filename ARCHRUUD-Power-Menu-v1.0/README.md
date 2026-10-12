# ARCHRUUD Power Menu v1.0

A standalone Quickshell power menu for Arch Linux / Hyprland (Lua configuration).

## Features

- Right-center screen edge activation and `SUPER+P` shortcut
- Compact vertical layout: Lock, Logout, Suspend, Reboot, Shutdown, Hibernate
- Colorful built-in vector icons (no external icon theme required)
- ARCHRUUD navy background and a single thin cyan outward-curving outline
- Confirmation before Logout, Suspend, Reboot, Shutdown and Hibernate
- Escape to close, and configurable inactivity timeout
- Backups on installation; other Quickshell modules remain untouched

## Inactivity timeout

Edit `~/.config/quickshell/archruud-power-menu/shell.qml` near the top of `ShellRoot`:

```qml
property int autoCloseMs: 5000
```

Change `5000` to `3000` for three seconds. Restart the `archruud-power-menu` Quickshell instance to apply the change. The timeout does not automatically confirm power actions.

## Power commands

Commands are defined in `~/.config/quickshell/archruud-power-menu/scripts/power-action.sh`.
`Lock` uses `loginctl lock-session`, so an appropriate lock-screen implementation must be configured separately. Hibernate requires system support (including suitable swap/resume setup). Unsupported actions may fail; this module does not configure them.

## Keyboard and edge

`SUPER+P` toggles the menu after Hyprland Lua integration. Hover over the middle of the right edge to open it. `Escape` closes it. Click a power action and then Confirm (except Lock).

## Important

Do not run a second `qs -c archruud-power-menu` instance if one is already running. Existing `SUPER+P` bindings must be disabled before enabling this module. See `INSTALL.md`.
