-- ARCHRUUD Open Software v1.0.2
-- Load from hyprland.lua after hl is initialized.
-- Do not define SUPER + O elsewhere.

hl.bind("SUPER + O",
    hl.dsp.exec_cmd("qs ipc -c archruud-open-software call openSoftware toggle"))
