# Changelog

## v1.0.1 — Kairos coexistence patch (runtime verification pending)

- Respect the user-requested physical top edge by setting the full-screen Overview `PanelWindow` to `ExclusionMode.Ignore`.
- Set the top-left click-only activation `PanelWindow` to `ExclusionMode.Ignore` and remove its `exclusiveZone: 0` (which otherwise forces Normal mode).
- Increase the corner click target from 12 × 12 to 28 × 28 px, with hover still disabled.
- Keep all other window previews, themes, layout and controls unchanged.
- Installer continues to back up installed content and retain the user's `config.json` and Lua module.

# Changelog

## [1.0.0] — 2026-10-12

First approved ARCHRUUD Overview release.

### Included from the tested v0.3 design
- Top-centered, rounded navy overview with blue edge border and shoulders.
- 1260 × 344 px nominal frame with responsive sizing.
- 5 columns × 2 rows (ten workspaces) with live window previews fitted to the frame.
- `CTRL + TAB` toggle and upper-left left-click trigger.
- Original overview window and workspace actions retained.

### Release packaging
- Full standalone Quickshell configuration bundled for fresh installs.
- Hyprland Lua module for startup and `CTRL + TAB`.
- Install/upgrade, timestamped backups, rollback and uninstall scripts.
- Preserve existing user settings and Lua module during upgrades.
- English README, installation instructions and GitHub release notes.

### Unchanged from user-tested v0.3
- No further changes to the QML behavior, preview scaling or visual design.
