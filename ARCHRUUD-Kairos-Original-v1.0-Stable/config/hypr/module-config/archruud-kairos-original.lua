-- ARCHRUUD Desktop - Kairos Original module - v1.0 Stable
-- Loaded by ~/.config/hypr/hyprland.lua:
-- require("module-config.archruud-kairos-original")
--
-- Starts only the installed Kairos standalone Quickshell configuration.
-- The legacy clock must not be started in parallel.
hl.on("hyprland.start", function()
    hl.exec_cmd("qs -c archruud-kairos-original")
end)
