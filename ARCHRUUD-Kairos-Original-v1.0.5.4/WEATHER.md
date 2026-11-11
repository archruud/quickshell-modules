# ARCHRUUD Kairos v0.4.1 — MET Norway weather

## User controls

The weather card in **Kairos Quick Settings** opens the Weather page. It shows:

- **Automatic** (default on fresh installs and for the legacy implicit `home` default)
- **Home** — Hjemme, 59.546666, 11.626059
- **Cabin** — Hytta, 59.367511, 11.840253

A fourth option, **Selected**, appears after using Settings → Weather → Find another place. All available options are mutually exclusive, saved as `weatherSpot` in
`~/.config/archruud/kairos-original/settings.json`. The same controls
are available through the top-clock **gear → Weather**.

Click the weather card again for current conditions, next 24 hours, or next
8 days (when provided by the API). Times are shown in the machine's local time
zone. Temperatures can be switched between °C and °F in the gear settings.

## Automatic mode — accuracy and privacy

Automatic uses the *approximate public IP location* returned by `ipwho.is`
(or `ipapi.co` if the first service fails). It does **not** use GPS,
Wi-Fi triangulation, or browser permission. A VPN, mobile hotspot, satellite
connection, or ISP network may make the location inaccurate. The detected
city is shown in Kairos so the user can verify it. Choose Home or Cabin for
more accurate local forecasts. The automatic location is cached for 30 minutes.

MET Norway Locationforecast 2.0 provides weather data. The application makes
an HTTPS request using latitude and longitude, and caches forecast responses
for 20 minutes. The app supplies a descriptive User-Agent with the project URL.
No Yr webpage is embedded or copied; weather icons and UI follow the existing
ARCHRUUD style. Credit: **Norwegian Meteorological Institute / MET Norway (Yr)**.

External services receive the requester's public IP. MET Norway also receives
the chosen coordinates. No personal login credentials or API keys are used.
If network access fails, Kairos shows unavailable instead of guessing the
user is home. A previously cached MET forecast may be shown offline.

## Installation and configuration

```bash
bash install.sh
qs -c archruud-kairos-original
```

**Stop the currently running Kairos with Ctrl+C before restarting it.**
Do not run two notification-enabled Kairos instances at the same time.

This install updates only `~/.config/quickshell/archruud-kairos-original/`.
It preserves `~/.config/archruud/kairos-original/settings.json` and the
opt-in Quickshell notification state. Clock padding, visual geometry, music,
network, sound, Bluetooth, and existing Lua autostart are unchanged.

Optional CLI:

```bash
bash weather.sh status
bash weather.sh auto
bash weather.sh home
bash weather.sh cabin
bash weather.sh test
```

Run `bash rollback.sh` from the package to restore the most recent backed up
Kairos configuration (backups are under
`~/.local/state/archruud/backups/kairos-original/`).

### Coordinate adjustment and place lookup

Open **gear → Weather → Saved coordinates** to edit the Home and Cabin
latitude and longitude separately, then click **Save**. The values persist
in `~/.config/archruud/kairos-original/settings.json` (`locations.home` and
`locations.cabin`); see [LOCATION-SEARCH.md](LOCATION-SEARCH.md) for
instructions to change them through the GUI or manually.

Under **Find another place**, enter a name or paste `latitude, longitude`
from Google Maps and press **Search** (or Enter). The drop-down list is
populated only on a deliberate search; clicking a result makes it the active
**Selected** place. Escape or clicking outside closes the search list.
Location name search uses OpenStreetMap Nominatim; © OpenStreetMap contributors.


## Known limitations

- Live Quickshell rendering must be tested on your own Arch Linux / Hyprland
  machine; CI only covers offline Python/structural tests.
- Automatic geolocation is approximate and can be unreliable with VPNs.
- This version does not embed the official Yr web module; that module's terms
  prohibit source/design customization. Here we use MET Norway API data
  in an independent UI.
- The 8-day list is assembled from the forecast time series and shows daily
  approximations, not an official Yr eight-day table reproduction.
