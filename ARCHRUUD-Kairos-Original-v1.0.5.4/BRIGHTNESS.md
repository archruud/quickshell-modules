# Monitor Light (external display / DDC/CI)

The GUI calls `scripts/archruud_brightness.py` in the installed Kairos tree.
It is separate from sound control and keyboard firmware.

Read-only checks:

```bash
bash monitor-setup.sh --check
bash diagnose-monitor.sh
python3 ~/.config/quickshell/archruud-kairos-original/scripts/archruud_brightness.py status
```

Some external monitors permit brightness adjustment via DDC/CI. It needs
`ddcutil`, a usable I2C device and DDC/CI enabled in the **monitor's own** menu.
Do not grant unrestricted `/dev/i2c*` permissions or run Quickshell as root.

If detection is confirmed, inspect the backend configuration at:
`~/.config/archruud/kairos-brightness.json`

- `backend`: `"ddcutil"` (if applicable)
- `ddc_display`: index from a real `ddcutil detect --brief` command
- `ddc_bus`: fixed bus if independently verified (takes precedence)
- `min_percent`: default safety floor (typically 10)

The previous on-device diagnostics in v1.0.5.4 showed the external
**Legion 27Q-10** monitor responding to DDC/CI read requests. A UI percentage
change alone does not prove the physical panel changed; test by eye.
A value `N/A` means the current backend cannot confirm brightness support.

**No requirement to remap the Pulsar Xboard's keyboard:** monitor brightness
can be controlled with the mouse even if the keyboard lacks supported keys.
