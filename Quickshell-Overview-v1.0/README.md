# Quickshell Overview v1.0 — ARCHRUUD

Standalone Overview-modul for Hyprland/Quickshell, basert på upstream-prosjektet Shanu-Kumawat/quickshell-overview.

## Hva installasjonen gjør

- kloner eller oppdaterer upstream til `~/.config/quickshell/overview`
- legger inn ARCHRUUD `config.json`
- legger inn Lua-modul i `~/.config/hypr/module-config/quickshell-overview.lua`
- legger automatisk til `require("module-config.quickshell-overview")` i `hyprland.lua` hvis den mangler
- bruker `CTRL + TAB`
- synkroniserer aktiv ARCHRUUD-wallpaper til tomme workspaces
- følger `~/.local/state/archruud/wallpaper/current-wallpaper` med en systemd user path

## Installer

```bash
chmod +x install.sh
./install.sh
```

## Viktigste innstillinger

Rediger med linjenummer:

```bash
nano -l ~/.config/quickshell/overview/config.json
```

Antall normale workspaces i Overview:

```json
"rows": 1,
"columns": 5
```

Vis/skjul special workspaces:

```json
"showSpecialWorkspaces": false
```

Sett `true` for å vise dem.

Etter manuell endring av config, restart bare Overview:

```bash
qs ipc -c overview call overview close
pkill -f 'qs.*-c overview' 2>/dev/null || true
qs -c overview &
```

## Aktiv wallpaper i tomme workspaces

`sync-wallpaper.sh` leser:

`~/.local/state/archruud/wallpaper/current-wallpaper`

og skriver den absolutte bildestien til både `emptyWorkspaceWallpaper` og `specialEmptyWorkspaceWallpaper` i Overview-configen. Wallpaper-modulen er ikke en hard dependency: Overview virker også uten denne state-filen.

## Oppdater upstream

```bash
./update.sh
```

Dette gjør `git pull --ff-only` i upstream-klonen. ARCHRUUD-filer ligger som brukerconfig/integrasjon og kan vedlikeholdes separat.
