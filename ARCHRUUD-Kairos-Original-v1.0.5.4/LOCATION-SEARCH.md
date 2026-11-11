# ARCHRUUD Kairos — Weather place search

Kairos now provides four mutually exclusive location modes: **Automatic**, **Home**, **Cabin**, and (after you select a search result) **Selected**. Automatic is the default for a new installation. Search is **manual only**, never autocomplete.

## Find a location

1. Hover over Kairos, open Settings (gear) → Weather.
2. Type a place name (such as `Sarpsborg, Norway`) or paste coordinates from Google Maps (`59.546666, 11.626059`).
3. **Optional for coordinates:** an extra field appears beneath the search box. Type a friendly name, such as `Ørje`. Leave it blank if you prefer the original coordinates label. The optional name does not change the location or the weather API query.
4. Click Search, or press Enter. A list of up to five matching names opens (coordinate search has a single result).
5. Click the result to save its coordinates *and its optional friendly name* and switch to **Selected**. Escape or clicking outside closes the results.
6. Switch back to Automatic, Home or Cabin at any time.

To rename a coordinate place you already selected in v0.4.1, paste its coordinates again, type the new name, and click the result. This updates **Selected** without affecting Home, Cabin or other settings. The friendly name appears in the weather card and weather page after the forecast refresh; it is stored as `locations.custom.name` in settings.json.

Place search uses OpenStreetMap Nominatim, not Google's geocoding API. Weather forecasts continue to come from MET Norway / Yr. Place names can be ambiguous, so confirm the country and region displayed in the results.

## Edit Home / Cabin

In **Kairos Settings → Weather → Saved coordinates**, edit the *latitude* and *longitude* for Home or Cabin and click Save. Values must use decimal degrees (latitude -90..90, longitude -180..180). The settings are persisted to:

`~/.config/archruud/kairos-original/settings.json`

The exact JSON keys are `locations.home.lat`, `locations.home.lon`, `locations.cabin.lat`, `locations.cabin.lon`. These values survive reinstalling this module. Stop Kairos before manual JSON editing, or use the GUI instead.

## Privacy and third-party usage

- Automatic mode: IP geolocation (approximate; VPN can affect it).
- Manual name search: query goes to `nominatim.openstreetmap.org`, with a maximum of five results, no autocomplete, at most one request per second, 24-hour local cache. © OpenStreetMap contributors.
- Manual coordinate search: parsed locally; no geocoder request.
- Forecast: MET Norway API. Coordinates are transmitted for weather lookup.
- This package does not automatically install or uninstall any notification daemon.
