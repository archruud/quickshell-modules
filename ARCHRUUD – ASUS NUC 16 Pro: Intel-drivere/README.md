# ARCHRUUD – ASUS NUC 16 Pro: Intel-drivere, programmering og lokal AI

**Versjon 2.0 | Arch Linux + Hyprland | trinnvis og kontrollert**

Denne pakken er laget for ASUS NUC 16 Pro med Intel Core Ultra 7 356H, integrert Xe3/Intel Graphics, Intel NPU og 32 GB RAM. Systemet bruker Arch Linux og Hyprland. Den tidligere kontrollerte lagringskonfigurasjonen var Samsung 9100 PRO 1 TB som systemdisk og Kingston NVMe 2 TB som `~/Data`.

**Ingen automatisk kjøring av alle trinn.** Kjør ett skript, se resultatet og la oss kontrollere det før du går videre. Det er lagt inn sperrer slik at et trinn ikke kan kjøres før forrige kontroll er godkjent.

## Dette installeres

- Intel microcode og Linux-firmware
- Intel Xe3 GPU: Mesa, Vulkan og VA-API
- Intel NPU: driver og kompilator
- OpenVINO med CPU/GPU/NPU-støtte
- Utviklingsmiljø: Zed, Python/uv, C++/Clang/GCC/CMake, Rust, Node.js/npm, Git og terminalverktøy
- llama.cpp med Vulkan-backend **bare hvis nødvendig**; eksisterende fungerende binærfiler erstattes ikke ukritisk
- Kontroller av de fem tidligere valgte GGUF-filene og en frivillig kort test av hovedmodellen

Kun offisielle Arch-pakker brukes til systeminstallasjonen. Ingen NVIDIA/CUDA. Ingen AUR. Ingen installasjon av en ny kernel, bootloader eller partisjonering.

**Lyd-til-tekst/transkripsjon inngår IKKE.** Dette bygges som et separat prosjekt senere.

## Slik pakker du ut

Åpne ZIP-filen i Dolphin og pakk ut hele mappen. Du kan legge den under `~/Data/Prosjekter/` eller et annet sted. Skriptene fungerer fra hvilken som helst mappe, så lenge de beholder den opprinnelige mappestrukturen.

Åpne Kitty i den utpakkede prosjektmappen. For eksempel:

```bash
cd ~/Data/Prosjekter/ARCHRUUD-NUC16-Intel-AI-Dev-Setup-v2
chmod +x scripts/*.sh
```

Hvis du pakket ut et annet sted, bruk den faktiske mappen i `cd`.

## Kjørerekkefølge – STOPP mellom trinnene

| Trinn | Kommando | Hva skjer? | Godkjenningssignal |
|---|---|---|---|
| 00 | `./scripts/00-preflight.sh` | Kun lesing av maskinvare, disk, UEFI og Arch | `PRECHECK_PASS=1` |
| 01 | `./scripts/01-install-intel-stack.sh` | Intel CPU/GPU/NPU/OpenVINO-pakker | Installert; **start på nytt** |
| 01b | `./scripts/01b-verify-intel-stack.sh` | Test Vulkan + OpenVINO CPU/GPU/NPU etter omstart | `DRIVER_VERIFY_PASS=1` |
| 02 | `./scripts/02-install-development-tools.sh` | Zed, Git, Python/uv, C++, Rust, Node | Installasjon fullført |
| 02b | `./scripts/02b-verify-development-tools.sh` | Kompilerer og kjører små tester uten nett | `DEVELOPMENT_VERIFY_PASS=1` |
| 03 | `./scripts/03-install-or-verify-llama-vulkan.sh` | Beholder eller installerer llama.cpp/Vulkan | `LLAMA_VULKAN_PASS=1` |
| 04 | `./scripts/04-check-selected-models.sh` | Søker etter valgte modeller (ingen nedlasting) | `MODEL_CHECK_PASS=1` |
| 05 | `./scripts/05-smoke-test-main-llm.sh` | Kjører én kort test med Qwen3-30B-A3B | `LLM_SMOKE_PASS=1` |

**Ikke kjør alle på én gang.** Send meg loggen eller skjermbildet fra trinn 00 først. Vi går videre når kontrollen er godkjent.

## Valgte modeller – ikke endre modellfamilie

| Formål | Modell / GGUF-navn |
|---|---|
| Generell LLM | `Qwen3-30B-A3B-Q4_K_M.gguf` |
| Programmering | `Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf` |
| Embedding / RAG | `Qwen3-Embedding-4B-Q8_0.gguf` |
| Vision / dokument | `Qwen3VL-30B-A3B-Instruct-Q4_K_M.gguf` |
| Vision-projektor | `mmproj-Qwen3VL-30B-A3B-Instruct-F16.gguf` |

`30B-A3B` var størrelsen vi kom frem til, ikke 28B. Tidligere NUC-tester ga omtrent 32,55 genererte tokens/s for Qwen3-30B-A3B og 29,9 tokens/s for Qwen3-Coder i en faktisk kodetest. Dette er tidligere målinger, ikke garantier for en ny installasjon.

`llama.cpp` + Intel Vulkan (`Vulkan0`) var den stabile løsningen. Vi antar **ikke** at de store Qwen-modellene skal kjøres på NPU. NPU brukes først når en bestemt modell og runtime faktisk er testet der.

Skript 04 søker i `~/AI/models`, `~/Data/AI/models` og `~/Data/models`. Du kan angi en ekstra mappe slik:

```bash
MODEL_DIR="$HOME/MinAnnenModellmappe" ./scripts/04-check-selected-models.sh
```

Modellene lastes ikke ned automatisk. Hvis en fil mangler, stopper vi og finner korrekt modellkilde før neste trinn.

## Logger og kontrollpunkter

Alle logger og godkjenningsfiler lagres under:

```text
~/AI/nuc16-setup/logs/
~/AI/nuc16-setup/state/
```

Kjør aldri skriptene med `sudo bash`. De ber om sudo bare ved pakkebehandling og eventuell `render`-gruppe. Ingen passord lagres.

## Hva pakken IKKE gjør

- Endrer ikke EFI, UEFI BootOrder, GRUB, systemd-boot eller Ubuntu
- Endrer ikke diskpartisjoner eller monteringspunkter
- Endrer ikke Hyprland, Quickshell, Waybar eller shell-aliaser
- Installerer ikke NVIDIA/CUDA eller drivere fra `.run`-filer
- Installerer ikke Whisper eller transkripsjonsmodeller
- Starter ikke AI-servere automatisk eller åpner nettverksporter
- Overskriver ikke GGUF-modeller

**Merk:** `pacman -Syu` oppdaterer installerte Arch-pakker og kan også oppdatere en allerede installert kernel. Det er en vanlig full systemoppdatering, ikke en installasjon av en alternativ kernel. Les alltid transaksjonslisten før du svarer ja.

## Innhold

```text
ARCHRUUD-NUC16-Intel-AI-Dev-Setup-v2/
├── README.md
├── scripts/
│   ├── 00-preflight.sh
│   ├── 01-install-intel-stack.sh
│   ├── 01b-verify-intel-stack.sh
│   ├── 02-install-development-tools.sh
│   ├── 02b-verify-development-tools.sh
│   ├── 03-install-or-verify-llama-vulkan.sh
│   ├── 04-check-selected-models.sh
│   └── 05-smoke-test-main-llm.sh
├── lib/common.sh
├── tools/
│   ├── openvino_devices.py
│   ├── check_models.py
│   └── get_main_model.py
├── templates/
│   ├── python/
│   ├── cpp/
│   ├── rust/
│   └── typescript/
└── MANIFEST.sha256
```
