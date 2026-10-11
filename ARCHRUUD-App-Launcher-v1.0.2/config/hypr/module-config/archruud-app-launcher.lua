-- ARCHRUUD App Launcher v1.0.2
-- Loaded from ~/.config/hypr/hyprland.lua
-- Requires Hyprland Lua with hl bindings.

hl.on("hyprland.start", function()
    hl.exec_cmd("qs -c archruud-launcher")
end)

hl.bind(
    "SUPER + A",
    hl.dsp.exec_cmd("qs ipc -c archruud-wallpaper-bottom call wallpaperBottom close >/dev/null 2>&1; qs ipc -c archruud-launcher call appLauncher toggle")
)
