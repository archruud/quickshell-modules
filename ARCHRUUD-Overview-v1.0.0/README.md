# ARCHRUUD Overview v1.0.0

A standalone Quickshell workspace overview for **Arch Linux, Hyprland Lua and Wayland**, styled for the ARCHRUUD Desktop.

**Status:** v1.0.0 release package based on **v0.3 design**, tested successfully by the project owner on a 2560 × 1440 display. No functional QML or geometry changes were made in this release repackaging.

## Features

- Top-centered navy panel with thin blue border (`#39A8F0`), rounded corners and shoulder accents.
- 1260 × 344 px nominal panel on a 2560 px-wide display; responsive width for smaller displays.
- Ten workspaces in a 5-column × 2-row grid, with scaled live previews.
- **CTRL + TAB** toggles the panel via Quickshell IPC.
- **Left-click at the upper-left screen corner** opens the panel; hover alone does not.
- Click workspaces/windows to switch, along with the retained upstream overview controls.
- Independent Quickshell configuration name: `archruud-overview`.

## Usage

```bash
qs -c archruud-overview
qs ipc -c archruud-overview call overview toggle
```

The Lua keybinding and startup hook are in `config/hypr/module-config/archruud-overview.lua`. For setup and upgrades, read [INSTALL.md](INSTALL.md).

## Layout

```text
config/
  quickshell/archruud-overview/  # self-contained QML configuration
  hypr/module-config/archruud-overview.lua
install.sh
rollback.sh
uninstall.sh
INSTALL.md
CHANGELOG.md
GITHUB-RELEASE.md
UPSTREAM.md
```

## Notes

- This v1.0.0 package uses the same QML files and dimensions as the user-tested v0.3 design.
- On upgrade, `config.json` is preserved from the existing installation. On fresh installation, the tested default configuration is supplied.
- No installer script modifies `hyprland.lua`, the old `overview` directory, or other ARCHRUUD modules.
- Non-fatal QML warnings about numeric conversion or missing application icons may appear on some systems; the tested configuration remained functional. These have not been modified in v1.0.0.
- Upstream code credits and redistribution caveats are in [UPSTREAM.md](UPSTREAM.md).

## Project

Part of [archruud/quickshell-modules](https://github.com/archruud/quickshell-modules).
