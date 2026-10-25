# ARCHRUUD – Base Bootstrap

Første bootstrap-pakke for en ren Arch Linux + Hyprland (Lua) installasjon.

Målet er å få maskinen raskt i en stabil, brukbar tilstand før Quickshell-modulene
bygges én etter én.

## Rekkefølge

```bash
cd 01-base
./install.sh

cd ../02-fixes
./install.sh

cd ../03-kitty-bash
./install.sh

cd ../04-run-command
./install.sh

cd ../05-capture-early
./install.sh
```

Logg ut og inn igjen etter 01/02 dersom polkit/keyring eller diskmount ikke oppfører
seg riktig med en gang.

## Hva denne pakken IKKE gjør

- Den erstatter ikke `hyprland.lua`.
- Den installerer ikke Awww/Wallust ennå.
- Den installerer ikke Rofi/Fuzzel/Waybar.
- Den installerer ikke Bluetooth-, lyd- eller nettverks-GUI som senere skal erstattes
  av Quickshell.
- Den installerer ikke GPU/NPU-driverstakker på nytt. Intel-grafikk velges i Archinstall.
- Den skriver ikke ekstra NVMe-disker inn i `/etc/fstab`. Dolphin + UDisks + polkit
  skal kunne spørre om autorisasjon ved behov.

## Hyprland Lua

`02-fixes` installerer:

`~/.config/hypr/module-config/hyprland-base.lua`

Legg denne linjen i `~/.config/hypr/hyprland.lua`:

```lua
require("module-config.hyprland-base")
```

Dette blir mønsteret for fremtidige moduler:

```text
~/.config/hypr/module-config/quickshell-<modul>.lua
~/.config/quickshell/<modul>/
```
