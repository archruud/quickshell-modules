# ARCHRUUD Open Software — GitHub v1.0.2

Repository: <https://github.com/archruud/quickshell-modules>

**Update the existing `open-software/` directory** with the *contents* of this versioned package. Do not rename the installed Quickshell configuration; the exact runtime name `archruud-open-software` is required by existing shortcuts and IPC.

From your existing local clone (where `open-software/` already exists), after replacing the files:

```bash
git add open-software
git commit -m "Update ARCHRUUD Open Software to v1.0.2"
git push
```

This ZIP does not push changes automatically.

## Fresh-install integration only

If an existing `SUPER+O` binding already works, **do not add another one**. Otherwise copy `module-config/quickshell-open-software.lua` into `~/.config/hypr/module-config/` and add only one import inside your Lua-based Hyprland config using `nano -l ~/.config/hypr/hyprland.lua`:

```lua
require("module-config.quickshell-open-software")
```

## Upgrade safety

- `bash install.sh` replaces only the Open Software Quickshell config and creates a full backup.
- `bash rollback.sh` restores the previous installed release.
- `bash uninstall.sh` moves the installed module into a backup folder.
- Does **not** touch Kairos, Overview, Power Menu, Hyprland Lua, system services or autostart.

The working window-activation Python script and the current single-click behavior are preserved. Only the visual layout is redesigned to match Power Menu.
