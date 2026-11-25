# 03-ARCHRUUD-Audio-Light-Standalone-v1.0

Volume and monitor brightness extracted from the NUC unified panel, independently running with its own hover trigger. Requires PipeWire, wpctl, python3 and available brightness backend.

## Standalone installation

```bash
bash install.sh --check
bash install.sh --install
```

- Installs **only** `~/.config/quickshell/archruud-audio-light/` (assuming default XDG_CONFIG_HOME).
- Preserves a complete backup and prints a rollback path.
- Does not modify `hyprland.lua`, bindings, autostart, other modules or running processes.
- Standalone means separate module directory and installer. The desktop must still launch the module; this installer deliberately does not start it automatically.
- Do not run this alongside the older **combined** Right Edge Controls: it would duplicate Power or Volume/Light UI.
- **Not runtime-tested on your NUC.** Source was inspected and statically extracted from your supplied working backup.

## Important

The working NUC system is based on a unified panel. To use the separated Power and Audio/Light processes, first stop the old unified panel instance and configure each process to launch exactly once. Back up the live system before changing autostart. Prefer testing on another session/computer before replacing the working setup.
