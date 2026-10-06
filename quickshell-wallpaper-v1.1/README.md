# ARCHRUUD Quickshell Wallpaper

Standalone wallpaper-picker for **Arch Linux + Hyprland + Quickshell**.

**Version:** v1.1

Wallpaper v1.1 er første ferdige ARCHRUUD Quickshell-modul. Den gir et kompakt grafisk wallpaper-bibliotek med **Alle / Dark / Light**, aktiv-markering og direkte bytte av bakgrunn via `awww`.

## Funksjoner

- `SUPER + W` åpner/lukker wallpaper-picker.
- Leser wallpapers fra `~/.config/hypr/wallpapers/`.
- Støtter PNG, JPG/JPEG og WEBP.
- Filtrerer `dark-*` og `light-*` i egne visninger.
- Vanlige/eldre wallpapers uten dark/light-navn fungerer fortsatt.
- Klikk på thumbnail bytter wallpaper via `awww`.
- Aktivt wallpaper markeres i GUI-et.
- Valget lagres og gjenopprettes automatisk etter ny Hyprland-start.
- Wallpaper-modulen fungerer helt uten Wallust.
- Installereren tar backup før eksisterende modul erstattes.
- Installereren legger automatisk inn Hyprland Lua-import hvis den mangler.

## Skjermbilde

Et skjermbilde av v1.1 kan legges i `docs/images/` og vises her når repoet publiseres.

## Hurtiginstallasjon

```bash
git clone https://github.com/archruud/quickshell-modules.git
cd quickshell-modules/modules/wallpaper
chmod +x install.sh uninstall.sh
./install.sh
```

Deretter legges wallpapers i:

```text
~/.config/hypr/wallpapers/
```

Etter neste Hyprland-start brukes:

```text
SUPER + W
```

Se **[INSTALL.md](INSTALL.md)** for komplett steg-for-steg-installasjon, testing, feilsøking, oppdatering og avinstallering.

## Installerte filer

```text
~/.config/quickshell/wallpaper/
├── shell.qml
└── scripts/
    ├── list-wallpapers.sh
    ├── set-wallpaper.sh
    └── restore-wallpaper.sh

~/.config/hypr/module-config/
└── quickshell-wallpaper.lua
```

Hyprland importerer modulen med:

```lua
require("module-config.quickshell-wallpaper")
```

## Wallpaper state

Aktivt wallpaper lagres i:

```text
~/.local/state/archruud/wallpaper/current-wallpaper
```

Dette blir også grensesnittet mot den kommende ARCHRUUD Theme/Wallust-modulen: Wallpaper velger bildet, Theme kan senere generere fargene.

## Designprinsipp

ARCHRUUD-modulene bygges som små, selvstendige Quickshell-moduler. Wallpaper skal derfor kunne installeres, brukes og fjernes uten at Theme, Launcher, Clipboard eller andre ARCHRUUD-moduler er installert.

## Neste modul

`quickshell-theme` + Wallust.
