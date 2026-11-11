# ARCHRUUD Kairos v1.0.1 — Audio & Notifications test release

This update is limited to audio service wiring, slider commits and notification
re-probing. The clock, weather, music, network, Bluetooth, visual geometry,
Hyprland Lua files and existing session services are unchanged.

## Why the sliders may have failed

Quickshell requires `PwObjectTracker` to bind a default PipeWire node before
`node.audio.volume` and `node.audio.muted` are usable. Audio.qml now explicitly
tracks both current default nodes, including when Bluetooth headphones are
connected or removed, and retains the existing device-list tracker. While
dragging a slider it updates the tracked QML audio node. On releasing the
slider it also commits through `wpctl` to the CURRENT default node. This is a
fallback and never changes a hardcoded HDMI/Bluetooth device.

## Install and start

1. Stop the Kairos instance you are running before updating. If launched in
   Kitty, press Ctrl+C in that terminal. If autostarted, log out/in after
   installation rather than starting a duplicate instance.
2. In this extracted directory run `bash install.sh`.
3. Log out/in or restart only Kairos (`qs -c archruud-kairos-original`) when
   not already running.
4. Open Quick Settings and slide Sound. Test HDMI and Bluetooth separately.

The installer backs up the previous `~/.config/quickshell/archruud-kairos-original`.
It does not replace `~/.config/archruud/kairos-original/settings.json`, the
notification opt-in flag, or any other Quickshell modules.

## Diagnosing audio and keyboard keys

Run `bash diagnose.sh` and then test `bash audio-test.sh up` and
`bash audio-test.sh down`. These last two actually adjust the current default
PipeWire sink by 5%. If they work but keyboard keys do not, the issue is in
the active Hyprland Lua bindings or the key events, not the PipeWire driver.

The conventional Lua binds (ONLY if your current config is missing them):

```lua
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
```

Use `nano -l ~/.config/hypr/hyprland.lua` to inspect first; do not add a
second copy of existing bindings. `wev` can show if the actual keyboard
sends XF86AudioRaiseVolume/XF86AudioLowerVolume.

`wpctl status` marks the current default sink with an asterisk. If changing
volume appears to do nothing but the value changes in `wpctl get-volume`,
check whether the selected default sink is the HDMI monitor rather than your
Bluetooth earbuds; select the correct Output in Kairos Sound or pavucontrol.

## Diagnosing notifications

Kairos does not automatically take over an active notification D-Bus name.
This is intentional. Run:

```bash
bash notifications.sh status
bash diagnose.sh
```

* `disabled`: opt in with `bash notifications.sh enable` when no competing
  notification provider owns the name, then restart Kairos.
* `running`: Kairos already owns the D-Bus name. Send `notify-send 'ARCHRUUD' 'Test'`;
  check the blue toast and history.
* `conflict`: another process owns `org.freedesktop.Notifications`. The
  diagnostic now reports its PID and command line where available. Do not
  blindly remove or kill packages. Stop only the identified competing service.
* `active`: opted in, no provider currently owns the name. Restart Kairos.
* `error`: the session D-Bus query failed. Investigate the session service.

If another daemon held the bus during a transient QML reload, Kairos will now
retry probing every seven seconds and activate once the name is free.

The update does not uninstall Dunst, change systemd, install a new driver, or
automatically rewrite the user's `hyprland.lua`.

## Rollback

Use the most recent backup path printed by `bash install.sh` and restore that
folder in place of `~/.config/quickshell/archruud-kairos-original` while
Kairos is stopped. The package also includes `rollback.sh` with its existing
backup convention. The prior Lua config and local weather/settings remain
unchanged.
