# Dependencies and related modules

## Existing system requirements

- Arch Linux + Hyprland (Lua-based configuration in the owner's environment).
- `quickshell` / `qs`, compatible QtQuick, QtQuick.Controls, QtQuick.Layouts, Quickshell.Io, Quickshell.Wayland and PipeWire bindings.
- PipeWire + WirePlumber; `wpctl` is provided by the PipeWire toolchain.
- Python 3 for brightness backend.
- DDC/CI (`ddcutil`) for supported external monitor brightness or `brightnessctl` for a supported backlight device; neither is universally available.
- `~/.config/hypr/scripts/archruud-power-action.sh`, installed previously by ARCHRUUD Power Foundation, for real lock/log out/suspend/reboot/shutdown actions.
- An existing working `archruud-kairos-original` Quickshell configuration. Kairos owns the clock, weather, notifications and quick settings.
- Working Hyprland Lua `require(...)` autostart entries and any volume keybindings installed separately; this snapshot does not make or change them.

## Integration

The Power Menu folder contains **its own** tracked `services/Audio.qml`, even though Kairos also has an identical audio service. Its `shell.qml` renders volume and light in the Power Menu process. The integration Scene file prevents two separate volume/light windows from appearing. `VolumeOSD.qml` in Kairos remains on disk for compatibility with older releases but is not used by the current Scene.

## Distinct configuration trees

The recorder installed as `~/.config/Quickshell/ScreenRecorder` (capital Q) is a different, case-sensitive folder from `~/.config/quickshell/archruud-power-menu` (lowercase q). Do not rename or combine them as part of this release. A future tools-module migration can handle this separately.
