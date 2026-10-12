-- ARCHRUUD Power Menu v1.0
-- Import once from ~/.config/hypr/hyprland.lua

hl.on("hyprland.start", function()
    hl.exec_cmd("qs -c archruud-power-menu")
end)

hl.bind(
    "SUPER + P",
    hl.dsp.exec_cmd("qs ipc -c archruud-power-menu call powerMenu toggle")
)
