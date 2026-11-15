# ARCHRUUD Screen Recorder v1.1

**Selvstendig Quickshell-modul for Arch Linux og Hyprland (Lua-konfigurasjon).**
Den forstyrrer ikke `~/.config/quickshell/` (liten q), eller andre moduler under `~/.config/Quickshell/` (stor Q).

## Nytt i v1.1 – EN tast + rød REC-knapp

- **SUPER + SHIFT + R** åpner menyen hvis ikke noe opptak pågår.
- Mens opptak pågår, stopper **samme** tast opptaket på en trygg måte.
- En liten **rød REC**-knapp vises **øverst til høyre** etter at området er valgt og opptaket starter. Klikk på REC for å stoppe.
- REC-indikatoren er en egen Quickshell-prosess og forsvinner automatisk etter avsluttet opptak. Det finnes ingen permanent bakgrunnstjeneste.
- `toggle.sh` er den nye kommandoen; eksisterende seks kvalitetsskript og menyen er beholdt.
- Ved nytt opptak brukes fremdeles automatisk ledige filnavn.

**Oppgradering fra 1.0:** Kjør `./install.sh` fra v1.1-mappen. Deretter bytter du KUN gammel `SUPER + SHIFT + R`-binding i din eksisterende `hyprland.lua`:

```lua
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("bash ~/.config/Quickshell/ScreenRecorder/toggle.sh"))
```

Ikke ha både gammel og ny R-binding samtidig. Den gamle `SUPER + SHIFT + X` kan beholdes som ekstrastopp. Ikke legg til en ekstra `require` eller `source` hvis du allerede har linjen i Lua-filen.

Test direkte i terminalen:

```bash
bash ~/.config/Quickshell/ScreenRecorder/toggle.sh
```

**REC kan være synlig i videoen** hvis det valgte skjermområdet omfatter indikatorens plass øverst til høyre. Flytt opptaksområdet hvis du ikke vil ha den med.

---

## 1. Hva du får

- Et frittstående Quickshell-vindu med navnefelt og seks opptaksvalg.
- Tre kvalitetsnivåer, både med og uten lyd.
- Klikk en kvalitet, velg skjermområde med musen via `slurp`.
- Unike filnavn: `kairos-test.mp4`, `kairos-test_2.mp4`, `kairos-test_3.mp4`.
- Tomt navnefelt -> automatisk tidsstemplet navn.
- Ikke automatisk overskriving av eksisterende videoer.
- Stoppknapp i Quickshell, egen stopp-hurtigtast eller kommandolinje.
- Seks uavhengige startskript (med/uten lyd for hver kvalitet).
- Videoer lagres i `~/Bilder/Skjermopptak`.
- Logg: `~/.local/state/archruud-screen-recorder/last.log`.

| Nivå | Video | Lyd når aktivert | Filformat |
| --- | --- | --- | --- |
| Lav | H.264, 15 FPS, CRF 30, veryfast | AAC 128 kbit/s, 48 kHz | MP4 |
| Middels | H.264, 30 FPS, CRF 23, fast | AAC 192 kbit/s, 48 kHz | MP4 |
| Full | H.264, 60 FPS, CRF 16, medium | AAC 320 kbit/s, 48 kHz | MP4 |

`Full` er **visuelt svært høy kvalitet**, ikke matematisk tapsfri. Ved høy skjermoppløsning kan 60 FPS med CPU-koding kreve mye kapasitet; dette kan senere byttes til Intel VA-API etter lokal testing.

## 2. Installer nødvendige programmer

```bash
sudo pacman -S --needed wf-recorder slurp ffmpeg libnotify
# Bare dersom Quickshell ikke allerede er installert:
yay -S --needed quickshell
```

`flock` følger normalt med `util-linux` på Arch. Koden bruker `wf-recorder` med `libx264` fordi akkurat dette har fungert hos deg.

## 3. Installer pakken

Pakk ut ZIP-filen, gå inn i den utpakkede mappen, og kjør:

```bash
chmod +x install.sh
./install.sh
```

Installereren oppretter bare `~/.config/Quickshell/ScreenRecorder/` og `~/Bilder/Skjermopptak/`, og endrer **ikke** din eksisterende Hyprland-konfigurasjon, andre Quickshell-moduler eller skrivebordsoppsettet.

## 4. Test Quickshell-vinduet først

```bash
bash ~/.config/Quickshell/ScreenRecorder/open.sh
```

Velg et filnavn (uten `.mp4`), velg `Middels kvalitet · Med lyd`, marker et skjermområde, og prøv deretter:

```bash
bash ~/.config/Quickshell/ScreenRecorder/recorder.sh stop
```

Avslutt opptaket normalt med stoppkommandoen, ikke `kill -9`, ellers kan MP4-filen bli uferdig. For å se om det kjører:

```bash
bash ~/.config/Quickshell/ScreenRecorder/recorder.sh status
```

## 5. Legg til hurtigtaster i Hyprland Lua

I din eksisterende `hyprland.lua`, etter at `hl` er definert, bruk **toggle-bindingen** (erstatt gammel R-binding ved oppgradering):

```lua
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("bash ~/.config/Quickshell/ScreenRecorder/toggle.sh"))
-- Valgfritt: behold tidligere separat stopptast:
-- hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd("bash ~/.config/Quickshell/ScreenRecorder/recorder.sh stop"))
```

- **SUPER + SHIFT + R** åpner menyen når ingen opptak kjører, ellers stopper den opptaket.
- **SUPER + SHIFT + X** er fortsatt mulig som en valgfri ekstratast for å stoppe.

Hvis `SUPER + SHIFT + R` eller `X` allerede brukes til noe annet, velg andre kombinasjoner.

Filene inneholder også `hyprland-binds.lua` som kopi av linjen og `hyprland-binds.conf` for eldre Hyprland-versjoner med tradisjonelt `.conf`-format. **Ikke bland .conf-syntaks inn i Lua.**

## 6. De seks startskriptene

Kjør fra terminal med eller uten eget filnavn. For eksempel:

```bash
bash ~/.config/Quickshell/ScreenRecorder/lav-med-lyd.sh "Undervisning"
bash ~/.config/Quickshell/ScreenRecorder/lav-uten-lyd.sh
bash ~/.config/Quickshell/ScreenRecorder/middels-med-lyd.sh
bash ~/.config/Quickshell/ScreenRecorder/middels-uten-lyd.sh
bash ~/.config/Quickshell/ScreenRecorder/full-med-lyd.sh
bash ~/.config/Quickshell/ScreenRecorder/full-uten-lyd.sh
```

Hvert skript velger opptaksområdet og kjører til du stopper opptaket fra en annen terminal eller hurtigtasten.

## 7. Lydkilde

Med lyd bruker programmet samme `-a` som du allerede har testet. Hvilken lyd som tas opp avhenger av valgt kilde; åpne `pavucontrol` under opptak og velg riktig `Monitor of ...` under **Opptak** for systemlyd. Mikrofon velges tilsvarende. Mik + systemlyd samtidig krever at du setter opp en kombinert kilde (ikke automatisk inkludert).

## 8. Feilsøking

Om noe ikke starter:

```bash
cat ~/.local/state/archruud-screen-recorder/last.log
```

I terminalen får du mer Quickshell-feilmelding med:

```bash
quickshell -p ~/.config/Quickshell/ScreenRecorder/shell.qml
```

Hvis vinduet eller navnefeltet ikke mottar tastetrykk, gjelder det Quickshell/Hyprland-versjonsavhengig fokus. QML-filen bruker `HyprlandFocusGrab` og `WlrKeyboardFocus.OnDemand` for å håndtere dette.

## 9. Tester

```bash
bash tests/smoke-test.sh
bash tests/toggle-test.sh
```

Testene bruker simulerte opptak. Det endelige QML-vinduet må prøves på Arch/Hyprland-maskinen din.

## 10. Merknader om testing

Bash-koden er syntakskontrollert, og enhetstester med falske `wf-recorder`/`slurp`-kommandoer har bekreftet seks profiler, lydflagget og automatisk unike filnavn. Faktisk skjermopptak og Quickshell-fokus må testes på din Arch/Hyprland-maskin, fordi dette miljøet ikke har en kjørende Hyprland-/Quickshell-sesjon.
