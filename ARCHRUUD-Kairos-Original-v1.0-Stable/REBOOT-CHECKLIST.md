# Kairos — first-login and reboot checklist

1. Stop the manually launched Kairos in Kitty with `Ctrl+C` before your first login/reboot test.
2. Run `bash install.sh` for Kairos v0.4.2 UI (the GitHub package includes this exact working UI).
3. Run `bash install-autostart.sh --dry-run`, read the proposed Lua diff, then `bash install-autostart.sh`.
4. Run `bash dependencies.sh --check` and install only missing packages if necessary.
5. See `CLEANUP.md` to safely stop Dunst; if required, enable Kairos native notifications once the D-Bus name is free.
6. Log out/in or reboot. The `hyprland.start` event is **not** guaranteed to re-fire on a config reload.
7. Open Kitty in this package and run `bash post-reboot-check.sh`.
8. Confirm on screen: top-connected island; bold clock and four independently adjustable paddings; music card when a compatible player runs; notification toast and quick settings list; Wi-Fi/Bluetooth/audio; Home/Cabin/Automatic and custom named locations; 24-hour and 8-day forecasts.

Expected active single startup in `~/.config/hypr/hyprland.lua`:

```lua
require("module-config.archruud-kairos-original")
```

Expected standalone module at `~/.config/hypr/module-config/archruud-kairos-original.lua`:

```lua
hl.on("hyprland.start", function()
    hl.exec_cmd("qs -c archruud-kairos-original")
end)
```

**If the bar does not appear:** open Kitty and try `qs -c archruud-kairos-original`. Collect the terminal error output rather than changing multiple modules at once. If two clocks appear, check for an old `quickshell-clock` import or external autostart. If native notifications report `running`, Kairos itself owns the notification D-Bus name as intended. If they report `conflict`, inspect ownership before changing any service.

**Rollback options:** `bash rollback-autostart.sh` for Lua import/startup; `bash rollback.sh` for the QML files. These are independent. The weather and padding settings live separately under `~/.config/archruud/kairos-original/settings.json`.
