# ARCHRUUD Open Software v1.0.2 — Installation

## Upgrade from v1.0 or v1.0.1

1. Extract `ARCHRUUD-Open-Software-v1.0.2-GitHub.zip`.
2. Open Kitty inside the extracted folder.
3. Run `bash install.sh` (does not use `sudo`).
4. Stop the **old** `qs -c archruud-open-software` process (Ctrl+C in its terminal, or log out and back in). Do not stop other modules.
5. Start `qs -c archruud-open-software` in Kitty to verify live appearance. If Open Software already autostarts successfully, reboot/login will use the new version automatically.
6. Open with **SUPER+O** or mouse hover at the left edge. Click an app once to activate it.
7. With one, three and many open windows, confirm the panel matches Power Menu width and changes height. Hover over a tile to inspect a full title.

**No changes needed to `hyprland.lua`.** The existing `SUPER+O` Lua import/binding is preserved.

## Undo

```bash
bash rollback.sh
```

Restart just the Open Software instance to load the restored files. `bash uninstall.sh` backs up and removes the installed Open Software module without modifying other modules.

## Fresh install

If `SUPER+O` is not configured, see `GITHUB.md` for the optional `module-config/quickshell-open-software.lua` import. Never add a duplicate Lua keybinding.

## Technical details

Only `~/.config/quickshell/archruud-open-software/` is replaced. Existing files are backed up automatically in `~/.local/state/archruud/open-software-backups/`. The `scripts/list-windows.py` and `scripts/focus-window.py` integrations remain exactly as in v1.0.1. No packages are installed or removed. The menu's shell width is 142px and the maximum height is 744px (also capped by screen size). The cursor tooltip exposes the full title in the reduced-width view.
