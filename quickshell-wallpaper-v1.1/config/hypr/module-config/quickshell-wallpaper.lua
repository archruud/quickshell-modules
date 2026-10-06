-- ============================================================
-- ARCHRUUD Quickshell Wallpaper
-- ~/.config/hypr/module-config/quickshell-wallpaper.lua
-- ============================================================

-- Start wallpaper shell once with Hyprland.
hl.on("hyprland.start", function()
    hl.exec_cmd("qs -c wallpaper")
end)

-- SUPER+W toggles the wallpaper picker.
hl.bind(
    "SUPER + W",
    hl.dsp.exec_cmd("qs ipc -c wallpaper call wallpaper toggle")
)
