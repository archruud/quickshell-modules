-- ============================================================
-- ARCHRUUD Quickshell Overview
-- ============================================================

-- Start Overview ved innlogging
hl.on("hyprland.start", function()
    hl.exec_cmd("qs -c overview")
end)

-- CTRL + TAB åpner/lukker Overview
hl.bind(
    "CTRL + TAB",
    hl.dsp.exec_cmd("qs ipc -c overview call overview toggle")
)
