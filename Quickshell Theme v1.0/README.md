# ARCHRUUD Quickshell Theme v1.0

Selvstendig dynamisk theme-motor for Arch Linux + Hyprland.

Wallpaper-modulen velger kun wallpaper og skriver aktiv fil til:

`~/.local/state/archruud/wallpaper/current-wallpaper`

`archruud-theme.path` følger denne state-filen og starter Theme Engine automatisk. Wallpaper har derfor ingen direkte avhengighet til Theme.

Theme Engine bruker Wallust som fargemotor og skriver et stabilt semantisk API til:

`~/.cache/archruud/theme/theme.json`

Fremtidige ARCHRUUD Quickshell-moduler skal bruke navn som `background`, `surface`, `foreground`, `primary`, `secondary`, `accent` og `border`, ikke Wallust `color0`-`color15` direkte.

## ARCHRUUD DarkBlue

Dette er standardprofilen. Den låser den mørke blå/svarte basen:

- background `#080D14`
- surface `#0D1724`
- surface_alt `#132337`
- foreground `#EAF6FF`
- muted `#8CA6B8`

Blå/accent-farger hentes dynamisk fra aktiv wallpaper via Wallust.

## Moduser

`auto`, `dark`, `darkblue`, `light`, `native`.

På ARCHRUUD-oppsettet brukes `darkblue` som standard, også med lyse wallpapers. `light`, `dark` og `native` kan velges manuelt.

## Kitty

Theme Engine genererer:

`~/.cache/archruud/theme/kitty.conf`

Installer legger én include-linje i `~/.config/kitty/kitty.conf`. Eksisterende Kitty-konfigurasjon sikkerhetskopieres før endring.

Se `INSTALL.md` for installasjon og test.
