# ARCHRUUD Quickshell Wallpaper v1.1 — Installation

Dette dokumentet beskriver installasjon av den selvstendige ARCHRUUD Wallpaper-modulen for **Arch Linux + Hyprland + Quickshell**.

## Krav

- Arch Linux
- Hyprland med Lua-konfigurasjon
- Quickshell (`qs`)
- `awww` som wallpaper-backend

Installereren kontrollerer Quickshell og `awww`, og installerer dem med `pacman` dersom de mangler.

## 1. Klon repoet

```bash
git clone https://github.com/archruud/quickshell-modules.git
cd quickshell-modules/modules/wallpaper
```

Hvis wallpaper-modulen ligger i et eget repository, går du i stedet inn i mappen som inneholder `install.sh`.

## 2. Gjør installereren kjørbar

```bash
chmod +x install.sh uninstall.sh
chmod +x config/quickshell/wallpaper/scripts/*.sh
```

På ARCHRUUD-oppsettet kan også aliaset `run` brukes for å gjøre `.sh`-filer kjørbare.

## 3. Installer

```bash
./install.sh
```

Installereren gjør følgende:

1. Kontrollerer at Quickshell finnes.
2. Kontrollerer at `awww` finnes.
3. Oppretter `~/.config/hypr/wallpapers/` hvis mappen mangler.
4. Tar backup av en eksisterende wallpaper-modul.
5. Installerer Quickshell-modulen i `~/.config/quickshell/wallpaper/`.
6. Installerer Hyprland-modulen i `~/.config/hypr/module-config/quickshell-wallpaper.lua`.
7. Legger til følgende import i `~/.config/hypr/hyprland.lua` dersom den mangler:

```lua
require("module-config.quickshell-wallpaper")
```

## 4. Legg wallpapers i riktig mappe

Alle wallpapers legges i:

```text
~/.config/hypr/wallpapers/
```

Eksempel:

```text
~/.config/hypr/wallpapers/
├── ARCHRUUD_1920x1200.png
├── ARCHRUUD_2560x1440.png
├── ARCHRUUD_2560x1600.png
├── dark-1920x1080.png
├── dark-1920x1200.png
├── dark-2560x1080.png
├── dark-2560x1440.png
├── dark-2560x1600.png
├── light-1920x1080.png
├── light-1920x1200.png
├── light-2560x1080.png
├── light-2560x1440.png
└── light-2560x1600.png
```

Støttede bildeformater er PNG, JPG/JPEG og WEBP.

Navn som starter med `dark-` vises under **Dark**, og navn som starter med `light-` vises under **Light**. Andre bilder vises fortsatt under **Alle**.

## 5. Test uten logout

Start modulen i én terminal:

```bash
qs -c wallpaper
```

Åpne/lukk picker-vinduet fra en annen terminal:

```bash
qs ipc -c wallpaper call wallpaper toggle
```

Klikk på et wallpaper. Bildet skal byttes via `awww`, og valgt wallpaper skal markeres som **AKTIV**.

## 6. Normal bruk

Etter neste Hyprland-start starter modulen gjennom Hyprland-konfigurasjonen.

Åpne/lukk wallpaper-picker med:

```text
SUPER + W
```

Valgt wallpaper lagres i:

```text
~/.local/state/archruud/wallpaper/current-wallpaper
```

Det samme wallpaperet gjenopprettes automatisk ved neste Hyprland-start.

## Dark / Light

Wallpaper v1.1 håndterer **Dark** og **Light** som filtre for wallpaper-biblioteket. Modulen er med vilje uavhengig av Wallust.

Den planlagte `quickshell-theme`-modulen kan senere lese valgt wallpaper og bruke Wallust til å generere ARCHRUUD-farger uten at Wallpaper-modulen blir avhengig av Theme-modulen.

## Feilsøking

Kontroller `awww`:

```bash
awww query
```

Hvis daemon ikke kjører:

```bash
awww-daemon &
awww query
```

Se Quickshell-instanser:

```bash
qs list
```

Se loggen til wallpaper-modulen:

```bash
qs log -c wallpaper
```

## Avinstallering

Fra modulmappen:

```bash
./uninstall.sh
```

## Oppdatering

Ved en senere versjon:

```bash
git pull
./install.sh
```

Installereren tar backup av eksisterende wallpaper-modul før den nye kopieres inn.
