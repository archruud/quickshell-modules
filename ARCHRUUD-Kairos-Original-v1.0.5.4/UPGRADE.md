# Install and upgrade safety

- **Already working v1.0.5.4:** GitHub upload does not require reinstall.
- **Older Kairos installations:** `bash install.sh` will back up the entire
  Quickshell `archruud-kairos-original` directory, then deploy the full source.
  This is a version upgrade, not a tiny patch; inspect `bash verify-release.sh`
  first. Existing personal weather settings are outside the source directory.
- **Autostart:** do not run `install-autostart.sh` again on a working machine.
  It may adjust Lua startup. A new machine should use its dry-run first.
- **Power Menu:** use `python3 install-power-companion.py --dry-run` separately,
  and only if Power Menu has not yet been integrated. Unknown source versions
  safely refuse modifications.
- **Keyboard:** this package deliberately does not change or remove `wpctl`
  keybindings. The Pulsar volume knob and mute rely on existing mappings.
- **DDC/CI:** optional `bash monitor-setup.sh --check` first. Only use
  `bash monitor-setup.sh --install` after inspecting the monitor and system.
- **Rollback:** `bash rollback.sh` restores the previous Kairos config folder.
  `python3 install-power-companion.py --rollback` reverts only an optional
  Power Menu integration installed **by that helper**, if unchanged since.
- **Reboot:** once after installing. Check `bash post-reboot-check.sh`.
- **Never:** run install scripts with `sudo`, start duplicate `qs` instances,
  disable safety checks, or overwrite an unknown Power Menu shell.
