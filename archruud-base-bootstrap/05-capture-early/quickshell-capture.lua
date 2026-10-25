-- ARCHRUUD Capture – tidlig funksjonell versjon
-- Senere erstattes/utvides dette med standalone Quickshell Capture GUI.

local mainMod = "SUPER"

-- Område
hl.bind(mainMod .. " + SHIFT + S",
    hl.dsp.exec_cmd([[grim -g "$(slurp)" - | swappy -f -]]))

-- Hele skjermen
hl.bind(mainMod .. " + CTRL + S",
    hl.dsp.exec_cmd([[sh -c "grim - | swappy -f -"]]))

-- Aktivt vindu
hl.bind(mainMod .. " + ALT + S",
    hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot-window.sh"))
