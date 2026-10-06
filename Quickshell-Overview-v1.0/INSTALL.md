# Install — Quickshell Overview v1.0

1. Pakk ut mappen.
2. Åpne terminal i `Quickshell Overview v1.0`.
3. Kjør:

```bash
chmod +x install.sh
./install.sh
```

Kontroller:

```bash
systemctl --user status archruud-overview-wallpaper.path --no-pager
```

Åpne Overview med `CTRL + TAB`.

Konfigurasjon:

```bash
nano -l ~/.config/quickshell/overview/config.json
```

- `rows` + `columns`: antall workspace-fliser
- `showSpecialWorkspaces`: `true` / `false`
- `emptyWorkspaceWallpaper`: settes automatisk fra aktiv ARCHRUUD-wallpaper
