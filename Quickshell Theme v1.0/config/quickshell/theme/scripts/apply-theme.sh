#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-auto}"
MODULE="$HOME/.config/quickshell/theme"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/archruud"
WP_FILE="$STATE_DIR/wallpaper/current-wallpaper"
MODE_FILE="$STATE_DIR/theme/mode"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/archruud/theme"
RAW="$CACHE/wallust.json"
OUT="$CACHE/theme.json"
KITTY_OUT="$CACHE/kitty.conf"

mkdir -p "$CACHE" "$(dirname "$MODE_FILE")"

if [[ "$MODE" == auto && -s "$MODE_FILE" ]]; then
    MODE="$(cat "$MODE_FILE")"
fi

[[ "$MODE" =~ ^(auto|dark|darkblue|light|native)$ ]] || {
    echo "Ugyldig modus: $MODE" >&2
    exit 2
}

[[ -s "$WP_FILE" ]] || {
    echo "Ingen aktiv wallpaper funnet: $WP_FILE" >&2
    exit 1
}

WALLPAPER="$(cat "$WP_FILE")"
[[ -f "$WALLPAPER" ]] || {
    echo "Wallpaper finnes ikke: $WALLPAPER" >&2
    exit 1
}

if [[ "$MODE" == auto ]]; then
    base="${WALLPAPER##*/}"
    low="${base,,}"
    if [[ "$low" == light-* || "$low" == *-light-* ]]; then
        EFFECTIVE=light
    else
        EFFECTIVE=dark
    fi
else
    EFFECTIVE="$MODE"
fi

case "$EFFECTIVE" in
    light) PAL=light16 ;;
    dark|darkblue) PAL=dark16 ;;
    native)
        base="${WALLPAPER##*/}"
        low="${base,,}"
        [[ "$low" == light-* || "$low" == *-light-* ]] && PAL=light16 || PAL=dark16
        ;;
esac

XDG_CONFIG_HOME="$MODULE/wallust-xdg" \
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}" \
    wallust run "$WALLPAPER" --palette "$PAL" --no-hooks >/dev/null

[[ -s "$RAW" ]] || {
    echo "Wallust genererte ikke $RAW" >&2
    exit 1
}

if [[ "$EFFECTIVE" == light ]]; then
    jq --arg mode "$EFFECTIVE" --arg wp "$WALLPAPER" '
    {version:1,mode:$mode,wallpaper:$wp,
     background:.background,surface:.color7,surface_alt:.color15,
     foreground:.foreground,muted:.color8,
     primary:.color4,secondary:.color6,accent:.color12,
     border:.color4,error:.color1,warning:.color3,success:.color2,
     raw:.}' "$RAW" > "$OUT.tmp"

elif [[ "$EFFECTIVE" == darkblue ]]; then
    jq --arg mode "$EFFECTIVE" --arg wp "$WALLPAPER" '
    {version:1,mode:$mode,wallpaper:$wp,
     background:"#080D14",surface:"#0D1724",surface_alt:"#132337",
     foreground:"#EAF6FF",muted:"#8CA6B8",
     primary:.color12,secondary:.color4,accent:.color14,
     border:.color12,error:.color9,warning:.color11,success:.color10,
     raw:.}' "$RAW" > "$OUT.tmp"

else
    jq --arg mode "$EFFECTIVE" --arg wp "$WALLPAPER" '
    {version:1,mode:$mode,wallpaper:$wp,
     background:.background,surface:.color0,surface_alt:.color8,
     foreground:.foreground,muted:.color7,
     primary:.color4,secondary:.color6,accent:.color12,
     border:.color4,error:.color9,warning:.color11,success:.color10,
     raw:.}' "$RAW" > "$OUT.tmp"
fi

mv "$OUT.tmp" "$OUT"

# Generate Kitty colors from the semantic ARCHRUUD API + raw Wallust palette.
BG="$(jq -r '.background' "$OUT")"
FG="$(jq -r '.foreground' "$OUT")"
CURSOR="$(jq -r '.raw.cursor // .foreground' "$OUT")"
SEL_BG="$(jq -r '.surface_alt' "$OUT")"
SEL_FG="$(jq -r '.foreground' "$OUT")"

{
    echo "# ARCHRUUD Theme Engine - generated file"
    echo "# Do not edit manually"
    echo "background $BG"
    echo "foreground $FG"
    echo "cursor $CURSOR"
    echo "selection_background $SEL_BG"
    echo "selection_foreground $SEL_FG"
    for i in {0..15}; do
        c="$(jq -r --arg key "color$i" '.raw[$key]' "$OUT")"
        echo "color$i $c"
    done
} > "$KITTY_OUT.tmp"
mv "$KITTY_OUT.tmp" "$KITTY_OUT"

printf '%s\n' "$MODE" > "$MODE_FILE"

# Ask running Kitty instances to reload config. Failure is harmless.
if command -v pgrep >/dev/null 2>&1; then
    while read -r pid; do
        [[ -n "$pid" ]] && kill -USR1 "$pid" 2>/dev/null || true
    done < <(pgrep -x kitty || true)
fi

echo ""
echo "ARCHRUUD Theme Engine"
echo "====================="
echo "Mode:       $EFFECTIVE"
echo "Wallpaper:  $WALLPAPER"
echo "Theme API:  $OUT"
echo "Kitty:      $KITTY_OUT"
echo ""
echo "Colors:"
printf '  %-11s %s\n' background "$(jq -r '.background' "$OUT")"
printf '  %-11s %s\n' surface "$(jq -r '.surface' "$OUT")"
printf '  %-11s %s\n' foreground "$(jq -r '.foreground' "$OUT")"
printf '  %-11s %s\n' primary "$(jq -r '.primary' "$OUT")"
printf '  %-11s %s\n' secondary "$(jq -r '.secondary' "$OUT")"
printf '  %-11s %s\n' accent "$(jq -r '.accent' "$OUT")"
printf '  %-11s %s\n' border "$(jq -r '.border' "$OUT")"
