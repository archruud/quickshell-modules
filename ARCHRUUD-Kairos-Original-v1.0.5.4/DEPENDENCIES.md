# ARCHRUUD Kairos — required software on clean Arch Linux / Hyprland

This describes **Kairos only**. A future ARCHRUUD base/ISO image will additionally cover the standalone launcher, wallpaper/theme, clipboard, capture, editor, browser, office suite, and other desktop modules.

Run **`bash dependencies.sh --check`** to check prerequisites without installing anything. On a new Arch Linux installation with a working Hyprland session, you can install Kairos prerequisites with:

```bash
bash dependencies.sh --install
```

The install list is: `quickshell python networkmanager iproute2 bluez bluez-utils brightnessctl pipewire wireplumber libnotify glib2 fontconfig ttf-material-symbols-variable ttf-jetbrains-mono-nerd`.

| Package/component | Purpose |
| --- | --- |
| `quickshell` | Runs the Kairos QML shell (`qs`). Includes Quickshell MPRIS, PipeWire and notifications modules. |
| `python` | Persistent settings, coordinate search and MET Norway weather client. |
| `networkmanager`, `iproute2` | Wi-Fi / connection / networking. NetworkManager must run as an active service. |
| `bluez`, `bluez-utils` | Bluetooth control. Enable `bluetooth.service` when needed. |
| `pipewire`, `wireplumber` | Audio session and volume control via Quickshell and `wpctl`; normally part of your Arch desktop base. |
| `brightnessctl` | Display brightness slider (if hardware permits). |
| `libnotify` | `notify-send` test utility; Dunst is **not** needed for Kairos notifications. |
| `glib2` | `gdbus` tool for detecting existing notification providers. |
| `ttf-material-symbols-variable` | Material Symbols Rounded icons, used throughout Kairos. |
| `ttf-jetbrains-mono-nerd` | JetBrainsMono Nerd Font / mono display. |
| `fontconfig` | `fc-match` and `fc-cache` font diagnostics. |

The `ttf-material-symbols-variable` package is the correct Arch package for `Material Symbols Rounded`. To verify after install:

```bash
fc-cache -f
fc-match 'Material Symbols Rounded'
fc-match 'JetBrainsMono Nerd Font'
python3 ~/.config/quickshell/archruud-kairos-original/scripts/check.py
```

Font and icons are **system packages, not files embedded into the GitHub ZIP**. A fallback font can produce incorrect icons even though the main QML loads.

Kairos does not depend on Rofi, Dunst or a separate `playerctl` executable for its native MPRIS service. A compatible music player must still expose MPRIS; some browser/media sources may behave differently.

On a fresh machine, `NetworkManager.service` and `bluetooth.service` may need to be enabled by the person configuring the base Arch system; this release does not change service states automatically. This package does not install Zed, Firefox, LibreOffice or a full Hyprland desktop, since those belong to the future ARCHRUUD base install.
