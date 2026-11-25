# ARCHRUUD Right Edge Controls — Stable source snapshot (v1.0.6.2 / R03)

**GitHub-ready package built from the two Quickshell folders provided by the owner on 25 November 2026.**

This package preserves the **working, post-reboot code** of the unified right-edge panel. No QML, Python, or shell application code has been rewritten for this release. The new documents and installation helpers are *packaging additions*, not a UI revision.

## What is in this release?

- **Power Menu**: Lock, Logout, Suspend, Reboot, Shutdown, Hibernate; existing action handling retained.
- **Volume**: vertically adjustable PipeWire output volume and mute inside the unified panel, with physical keyboard volume integration handled by the existing system configuration.
- **Monitor Light**: vertical brightness control backed by the existing `archruud_brightness.py`; works only when the screen/hardware supports a configured backlight or DDC/CI method.
- **One common panel and timeout**: `archruud-power-menu/shell.qml` owns the panel, the edge trigger, the hover state, and the three-second close timer.
- **Kairos compatibility**: `integration/.../Scene.qml` prevents the former separate `VolumeOSD.qml` from being instantiated a second time. The old file is *not deleted*; it is only no longer loaded from Scene.

## Layout of these files

```
config/quickshell/archruud-power-menu/
    shell.qml                   # all Power / Volume / Light UI, preserved exactly
    services/Audio.qml         # local PipeWire audio singleton
    services/qmldir
    scripts/power-action.sh    # delegates to the Power Foundation helper
    scripts/archruud_brightness.py
integration/quickshell/archruud-kairos-original/
    Scene.qml                  # the current, compatible Kairos Scene
```

**Important architectural detail:** Volume and Monitor Light are **now rendered in the Power Menu Quickshell process**, not as a second Kairos pop-up. Kairos itself still provides the clock, weather, notifications, and quick settings.

## On the owner's already-working Arch/Hyprland machine

You have already confirmed the combined panel works correctly after reboot. **Do not reinstall it merely to publish this release.** Upload the directory as-is to `archruud/quickshell-modules` and leave your installed files unchanged.

## Check or install on another machine

Dependencies: Quickshell, Qt/QML, PipeWire/WirePlumber audio with `wpctl`, Python 3, an existing Kairos installation, and the ARCHRUUD Power Foundation helper at `~/.config/hypr/scripts/archruud-power-action.sh`. `ddcutil` and/or `brightnessctl` and working monitor permissions are needed for supported brightness control.

```bash
bash verify.sh
bash install.sh --check
bash install.sh --install
```

The installer refuses to replace an **unexpected** Kairos Scene file. It backs up the entire existing Power Menu folder and the original Kairos Scene before installing, and it never edits `hyprland.lua`, other modules, systemd or autostart. Log out and in (or reboot) after installation. **Do not launch a second instance of Quickshell merely to refresh it.**

On an unconfigured new system, first install ARCHRUUD Kairos, the Power Foundation, and the established Hyprland Lua module bindings. This ZIP alone is not a full desktop installer.

For rollback, use `bash rollback.sh /absolute/backup/path` with the backup location printed by the installer.

## GitHub publishing

1. Extract this archive to a directory of the same name.
2. Upload the **extracted directory and its contents** to the root of [archruud/quickshell-modules](https://github.com/archruud/quickshell-modules), not the ZIP itself if you want the source browsable on GitHub.
3. Suggested commit: `Release stable right-edge Power, Volume and Light v1.0.6.2 (R03)`.
4. The existing `ARCHRUUD-Kairos-Original-v1.0.5.4-GitHub` remains an independent Kairos release. This integration snapshot complements it; it does **not** overwrite it in your repository.

## Boundaries / privacy

No personal saved settings, home/cabin coordinates, screenshots, videos, private backups, recorder files, shell history, Hyprland Lua files, or the separate `Quickshell/ScreenRecorder` folder are included. This is intentional. The old and new case-sensitive Quickshell directories have **not** been merged.

See `SOURCE-MANIFEST.json` and `SHA256SUMS` to verify the exact original code snapshots. The uploader confirmed real machine operation after reboot; local ZIP verification is not a substitute for runtime QML testing on another device.
