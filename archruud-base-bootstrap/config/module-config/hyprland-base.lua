-- ============================================================
-- ARCHRUUD Hyprland Base
-- Fil: ~/.config/hypr/module-config/hyprland-base.lua
-- ============================================================
-- Kun grunnfunksjoner som skal være tilgjengelige før
-- Quickshell-modulene installeres.

-- Norsk tastatur
hl.config({
    input = {
        kb_layout  = "no",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
    },
})

-- KDE/Dolphin bruker dette for XDG-menyintegrasjon.
hl.env("XDG_MENU_PREFIX", "arch-")

-- Secret Service. Viktig for programmer som skal huske passord.
-- gnome-keyring har også systemd/dbus-aktivering; denne er en ekstra
-- sikkerhet i den minimale Hyprland-sessionen.
hl.on("hyprland.start", function()
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
end)

-- MERK:
-- hyprpolkitagent startes som systemd --user service av 01-base.
-- Det er den som skal gi grafisk passorddialog ved f.eks. montering
-- av en ekstra NVMe via Dolphin/UDisks.
