# Installation — ARCHRUUD Overview v1.0.1

## Requirements

- Arch Linux with Hyprland (Lua-based configuration for included keybinds).
- Quickshell / `qs`, Qt Quick and Quickshell Hyprland/Wayland integrations.

## Install or upgrade

Extract the release archive in `~/Downloads`:

```bash
cd ~/Downloads/ARCHRUUD-Overview-v1.0.1
bash install.sh
```

The installer:
1. Makes timestamped backups of any pre-existing Overview and Lua module in `~/.local/state/archruud/overview-backups/`.
2. Installs the complete self-contained configuration to `~/.config/quickshell/archruud-overview/`.
3. **Preserves your existing** `~/.config/quickshell/archruud-overview/config.json` on upgrade.
4. Installs the Lua module only if that Lua file does not exist. **An existing working Lua file is not overwritten.**
5. Does **not** edit your `hyprland.lua`, old `overview` configuration, or other modules.

## Hyprland Lua configuration

If you already have a working ARCHRUUD Overview with `CTRL + TAB` and corner-click activation, **do not change `hyprland.lua`**.

For a fresh installation, first remove/disable any legacy `CTRL + TAB` mapping and old `qs -c overview` autostart to avoid duplicate bindings or multiple running panels. Then edit:

```bash
nano -l ~/.config/hypr/hyprland.lua
```

Add once alongside the other imports (after `hl` is initialized):

```lua
require("module-config.archruud-overview")
```

The included Lua module automatically starts `qs -c archruud-overview` on a fresh Hyprland session and binds `CTRL + TAB` to IPC toggle. If the module is not yet running in the current session, start it manually:

```bash
qs -c archruud-overview
```

Then validate:

```bash
hyprctl reload
hyprctl configerrors
```

## After upgrading

Stop only the `archruud-overview` instance and start it again in Kitty to load the new QML files. This does not stop the other Quickshell modules:

```bash
pkill -f '^qs -c archruud-overview$'
qs -c archruud-overview
```

To test toggling manually from another Kitty terminal:

```bash
qs ipc -c archruud-overview call overview toggle
```

Test `CTRL + TAB`, the upper-left corner click, all ten workspaces, live previews and window activation.

## Rollback

```bash
bash rollback.sh
```

By default, this restores the saved state from the most recent installation, including any former Lua file. A specific backup directory can also be passed as an argument. Restart Overview afterwards.

## Uninstall

1. Stop `qs -c archruud-overview`.
2. Use `nano -l ~/.config/hypr/hyprland.lua` and comment out the `require("module-config.archruud-overview")` line, if present. Reload Hyprland so its keybinding is removed.
3. Run `bash uninstall.sh` from the extracted release folder. The script refuses to uninstall if an active import still appears in `hyprland.lua`.

The uninstall script creates a final backup before removing this module's files. It never removes the old upstream `overview` configuration.

## Troubleshooting

```bash
pgrep -af 'quickshell|qs '
grep -RniE 'CTRL[[:space:]]*\+[[:space:]]*TAB|qs -c overview|archruud-overview' ~/.config/hypr --include='*.lua' --include='*.sh'
```

Only one Overview should own the `CTRL + TAB` keybinding. In particular, avoid running the original `qs -c overview` and this module concurrently unless intentionally comparing them.

## Kairos top-bar compatibility (v1.0.1)

Overview's fullscreen surface and 28 × 28 px top-left click target use
`exclusionMode: ExclusionMode.Ignore`, so Kairos or other shell bars cannot
push the Overview down. This does not change Kairos.

After installing, restart **only** the Overview instance, then verify:

1. CTRL+TAB opens the Overview with its blue top edge at the physical top of the display.
2. Close it and click the **top-left 28 × 28 px screen corner** to open it.
3. Clicking workspaces and closing via Esc still works.

If you previously customized `position.topMargin` in your installed
`~/.config/quickshell/archruud-overview/config.json`, set it to `0` for
a flush-top panel. The installer intentionally preserves your config.
