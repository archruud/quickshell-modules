# 02-ARCHRUUD-Power-Standalone-v1.1

Power-only extraction from the NUC unified panel: lock/logout/suspend/reboot/shutdown/hibernate, retaining the original 142px Power area. Requires existing Hyprland power-action helper.

## Standalone installation

```bash
bash install.sh --check
bash install.sh --install
```

- Installs **only** `~/.config/quickshell/archruud-power-menu/` (assuming default XDG_CONFIG_HOME).
- Preserves a complete backup and prints a rollback path.
- Does not modify `hyprland.lua`, bindings, autostart, other modules or running processes.
- Standalone means separate module directory and installer. The desktop must still launch the module; this installer deliberately does not start it automatically.
- Do not run this alongside the older **combined** Right Edge Controls: it would duplicate Power or Volume/Light UI.
- **Not runtime-tested on your NUC.** Source was inspected and statically extracted from your supplied working backup.

## Important

The working NUC system is based on a unified panel. To use the separated Power and Audio/Light processes, first stop the old unified panel instance and configure each process to launch exactly once. Back up the live system before changing autostart. Prefer testing on another session/computer before replacing the working setup.
