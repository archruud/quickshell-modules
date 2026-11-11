# ARCHRUUD Kairos — Notifications v0.3.9

## What this release does

Kairos contains an optional **native Quickshell NotificationServer**.
Once enabled it receives application notifications over the standard
`org.freedesktop.Notifications` D-Bus interface, shows brief blue toast popups
at the upper-right of the first screen, and shows the three latest items in
Kairos > Quick Settings > Notifications. The in-memory history can hold 50.
No history is written to disk. This release is **not** a persistent archive.

This test does not implement notification action buttons, inline replies,
reopening dismissed notifications or importing history from another daemon.

## Safety: only one desktop notification server

Existing Dunst, Mako, SwayNC or another notification provider must NOT run
concurrently with the Quickshell server. Otherwise desktop notifications
will be delivered to whichever server owns the session D-Bus name.

ARCHRUUD starts **disabled**. The installer neither stops nor reconfigures
any other daemon. The user chooses whether to switch.

## Step 1: Install and test the original Kairos UI

Install as usual:

```bash
bash install.sh
qs -c archruud-kairos-original
```

With notifications disabled the Home card explains that native notifications
are not active. Clock and music continue to work.

## Step 2: Check the current session notification server

From the extracted ZIP folder:

```bash
bash notifications.sh status
pgrep -af 'dunst|mako|swaync|notification'
```

If the status says `running`, this Kairos instance itself owns the notification bus name (expected). If the status says `conflict`, the name is owned by a process that the diagnostic could not verify as this Kairos instance.
**Do not run random `pkill` commands.** Identify which daemon starts it,
and stop that particular daemon temporarily using the appropriate service
or command. Save its restart command so you can restore it afterwards.

For example, only if you have verified that the running program is Dunst:

```bash
systemctl --user stop dunst.service
```

If that service does not exist, do not assume Dunst is stopped. The status
command will tell you whether the name is still owned. If D-Bus auto-starts
the previous service, its auto-start configuration may need attention, but
this package deliberately does not change it.

## Step 3: Opt in to Quickshell notifications

Once the D-Bus name is unowned:

```bash
bash notifications.sh enable
```

Stop your currently running Kairos with Ctrl+C, and restart:

```bash
qs -c archruud-kairos-original
```

You can send a test notification from a second Kitty terminal:

```bash
sudo pacman -S libnotify
notify-send 'ARCHRUUD Kairos' 'Notification test from Kitty'
```

Expected: an ARCHRUUD blue popup at the upper-right and an item in the
Kairos Quick Settings Home notification history. `notify-send` requires the
`libnotify` package.

## Turn off / restore your previous notification service

```bash
bash notifications.sh disable
```

Stop and restart Kairos to release its D-Bus registration. Then restart
**your known previous notification daemon** manually. The ARCHRUUD installer
does not store or restore the previous daemon's service/autostart state.

## Troubleshooting

- `running`: this Kairos instance owns the notification bus name; notifications are active.
- `conflict`: some other or unverified process owns the name. Check service ownership before proceeding.
- `error`: the D-Bus owner query failed; the Quickshell server stays off.
- Notifications do not arrive: check `bash notifications.sh status` **before**
  restarting Kairos and verify only one Kairos process is running.
- History resets after closing Kairos. This is intentional for v0.3.9.
- If the user's existing daemon is preferred, leave this new feature disabled.
- Changes to `notifications.enabled` take effect after restarting Kairos.
