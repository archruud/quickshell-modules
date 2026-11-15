-- ARCHRUUD Screen Recorder v1.1: use ONE toggle keybinding.
-- IMPORTANT: Replace the old SUPER + SHIFT + R binding, do NOT add duplicate!
-- Add the following in your current hyprland.lua after `hl` is defined:
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("bash ~/.config/Quickshell/ScreenRecorder/toggle.sh"))

-- Optional dedicated STOP key (your previous shortcut still works):
-- hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd("bash ~/.config/Quickshell/ScreenRecorder/recorder.sh stop"))
