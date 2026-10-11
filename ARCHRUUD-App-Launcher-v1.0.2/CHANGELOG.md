# Changelog

## v1.0.2 — Stable (2026-10-11)

### Changed since v1.0
- The bottom-center screen-edge trigger now opens App Launcher **only after a left mouse click**. Simply moving the pointer to the edge no longer opens the panel.
- The invisible edge target was increased from **2 px to 8 px** for easier clicking.
- The help text in the launcher was updated to explain the new click behavior.

### Unchanged
- `SUPER+A` opens/toggles App Launcher.
- Layout, colors, icons, application discovery, navigation, launch actions and five-second auto-close behavior.
- Existing Hyprland Lua integration and Quickshell IPC behavior.
- Existing installation paths and automatic backups.

### Tested by project owner
- Bottom-center left-click opens the launcher.
- `SUPER+A` continues to work.

### Notes
- No other ARCHRUUD Quickshell modules are modified.
- This release supersedes the v1.0.1 held-button-drag experiment, which did not work reliably under Wayland.
