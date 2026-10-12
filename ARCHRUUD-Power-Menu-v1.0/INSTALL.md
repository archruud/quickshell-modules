# ARCHRUUD Power Menu v1.0 — Installation

## 1. Install

Extract the ZIP, open Kitty in `ARCHRUUD-Power-Menu-v1.0`, and run:

```bash
bash install.sh
```

The installer copies the tested Quickshell UI to `~/.config/quickshell/archruud-power-menu/` and installs the Lua integration at `~/.config/hypr/module-config/archruud-power-menu.lua`. Previous versions are backed up under `~/.local/state/archruud/power-menu-backups/`. The main `hyprland.lua` is never edited automatically.

## 2. Enable in Hyprland Lua

Open the main file:

```bash
nano -l ~/.config/hypr/hyprland.lua
```

Near your other module imports, add exactly once:

```lua
require("module-config.archruud-power-menu")
```

If `SUPER+P` is already assigned elsewhere, comment out the old binding first. Reload:

```bash
hyprctl reload
```

**Important:** The `hl.on("hyprland.start", ...)` hook runs at a fresh Hyprland session start, not merely on `hyprctl reload`. Until the next login/reboot, start the module manually:

```bash
qs -c archruud-power-menu
```

Run this only if it is not already running. In a separate Kitty window, test:

```bash
qs ipc -c archruud-power-menu call powerMenu toggle
```

You can also use `SUPER+P` or hover over the middle of the right screen edge.

## 3. Test safely

Verify edge activation, colored icons, curved outline, `SUPER+P`, Escape and the confirmation dialog. Do **not** confirm Logout, Suspend, Reboot, Shutdown or Hibernate until ready. Check automatic startup after the next login/reboot.

## 4. Change timeout from five to three seconds

Open:

```bash
nano -l ~/.config/quickshell/archruud-power-menu/shell.qml
```

Near the beginning of `ShellRoot`, change:

```qml
property int autoCloseMs: 5000
```

to:

```qml
property int autoCloseMs: 3000
```

Restart the Power Menu Quickshell process to apply the edit.

## 5. Uninstall / restore

First comment out the `require` line in `hyprland.lua` and reload Hyprland. Then run `bash uninstall.sh` from this package. Backups are retained under `~/.local/state/archruud/power-menu-backups/` for manual restoration.
