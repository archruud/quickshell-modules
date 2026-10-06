# Installasjon – ARCHRUUD Quickshell Theme v1.0

## 1. Pakk ut

```bash
unzip archruud-quickshell-theme-v1.0.zip
cd archruud-quickshell-theme-v1.0
```

## 2. Installer

```bash
chmod +x install.sh uninstall.sh
./install.sh
```

Installer gjør følgende:

- installerer `jq` og Wallust ved behov
- sikkerhetskopierer eksisterende `~/.config/quickshell/theme`
- installerer Theme Engine
- installerer `archruud-theme.path` og `archruud-theme.service`
- aktiverer wallpaper-watcher
- kobler Kitty til den genererte theme-filen
- beholder eksisterende valgt mode, eller bruker `darkblue` som standard
- genererer theme med en gang dersom `current-wallpaper` finnes

## 3. Kontroller

```bash
~/.config/quickshell/theme/scripts/show-theme.sh
```

```bash
systemctl --user status archruud-theme.path archruud-theme.service --no-pager
```

`archruud-theme.path` skal være `active (waiting)`. Servicen er `oneshot`, så `inactive (dead)` etter `status=0/SUCCESS` er normalt.

## 4. Test automatisk wallpaper -> theme

Velg et annet wallpaper med ARCHRUUD Wallpaper-modulen (`SUPER+W`). Vent et øyeblikk og kjør:

```bash
systemctl --user status archruud-theme.service --no-pager
```

Du skal se `TriggeredBy: archruud-theme.path` og `apply-theme.sh auto` med `status=0/SUCCESS`.

## 5. Bytt mode manuelt

```bash
~/.config/quickshell/theme/scripts/set-mode.sh darkblue
```

Andre gyldige valg:

```text
auto
dark
darkblue
light
native
```

## 6. Vis filer med linjenummer

```bash
nano -l ~/.config/quickshell/theme/scripts/apply-theme.sh
```

## Avinstaller

```bash
./uninstall.sh
```

Wallpaper-modulen og aktiv wallpaper blir ikke fjernet.
