# ARCHRUUD Open Software v1.0.2

A compact, left-edge window switcher for **Arch Linux + Hyprland Lua + Quickshell**. This version matches the visual proportions and curved edge silhouette of **ARCHRUUD Power Menu v1.0**.

## Appearance

- **142-pixel shell width**, equal to Power Menu's configured width.
- One slim **vertical column** of 73-pixel application tiles; icon in a blue outlined circle, readable app name, and small workspace indicator.
- The old **ARCHRUUD OPEN** header, window-count badge, refresh button, close button and shortcut footer are removed.
- A dark, screen-connected shell with the same cyan border and outward-curved shoulders as Power Menu, mirrored for the left edge.
- Hover a tile to reveal the **full window title**, class and workspace in a tooltip. This makes multiple windows of the same program identifiable despite the narrower tiles.

## Behavior

- **Single click** activates the selected window, including switching workspace as needed, through the **unchanged** `scripts/focus-window.py` Lua dispatcher.
- Lists open Hyprland windows only. No placeholders for unused workspaces.
- The panel height grows and shrinks according to open-window count. With many windows it stops at the maximum height and can be scrolled.
- Opens via `SUPER+O` (existing Lua binding) or the left-edge hover sensor.
- Keyboard navigation: Up/Down (or Left/Right), Enter to activate, Escape to close. Auto-close after five idle seconds.
- Does not modify the other ARCHRUUD modules, keybindings or Hyprland configuration.

**Window scope:** All open normal-workspace Hyprland clients are listed, not just the focused app. Two separate windows of Firefox, for example, appear as two separate tiles.

## Update

Open Kitty in the extracted package directory:

```bash
bash install.sh
```

Restart **only** the running Open Software Quickshell instance. If it runs in a Kitty window, stop that instance there with `Ctrl+C` and launch:

```bash
qs -c archruud-open-software
```

Do not start a second persistent instance alongside the first. A reboot also loads the updated module if its working autostart is already installed.

## Rollback

```bash
bash rollback.sh
```

Restart Open Software after rollback. Previous releases are backed up to `~/.local/state/archruud/open-software-backups/` before replacement.

See `INSTALL.md`, `GITHUB.md` and `tests/test_release.py` for details. Static and isolated installer tests cannot replace a live Quickshell/Hyprland appearance test.
