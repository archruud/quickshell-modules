-- ARCHRUUD Overview v1.0.0 - Hyprland Lua module
-- Import once in ~/.config/hypr/hyprland.lua:
-- require("module-config.archruud-overview")
-- Disable any legacy overview startup and CTRL+TAB binding first.
hl.on("hyprland.start", function()
    hl.exec_cmd("qs -c archruud-overview")
end)

hl.bind("CTRL + TAB", hl.dsp.exec_cmd("qs ipc -c archruud-overview call overview toggle"))
