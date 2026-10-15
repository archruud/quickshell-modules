# ARCHRUUD Kairos Original — release notes

## v1.0 Stable — reboot-verified release

- User confirmed automatic startup on Arch Linux / Lua Hyprland after reboot.
- User confirmed a working native notification toast with Dunst no longer running.
- Improves post-reboot diagnostic: distinguishes Kairos itself owning the notification D-Bus name (`running`) from a verified conflict (`conflict`).
- Startup notification ownership protection and tested QML visuals/settings remain unchanged.

## v1.0 RC1 — deployment and Hyprland integration

- Preserves the working v0.4.2 Named Places QML/Python implementation unchanged.
- Adds standalone `archruud-kairos-original.lua` for `hyprland.start` (Lua Hyprland).
- Adds independent autostart installer with dry run, idempotence, timestamped Lua backup and rollback.
- Comments out only recognizable legacy clock imports/starts and an exact active Dunst autostart in `hyprland.lua`, without removing packages.
- Adds Arch dependency/font checks, optional install command, cleanup and after-reboot verification instructions.
- Adds GitHub documentation.

## v0.4.2 — user approved

- Search geographical coordinates and give the selected location any optional label, including custom places not listed by OpenStreetMap (e.g. Ørje and Myson).
- Retains weather, music, native opt-in notifications and original ARCHRUUD clock island appearance.
