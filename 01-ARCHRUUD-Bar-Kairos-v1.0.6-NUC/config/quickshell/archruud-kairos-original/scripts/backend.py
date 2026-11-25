#!/usr/bin/env python3
"""ARCHRUUD Kairos standalone adapters. No Ryoku socket/daemon.

Use only subprocess argv arrays (no shell). Persist small JSON settings safely.
MET Norway forecasts for Automatic, Home and Cabin weather modes.
"""
import json
import datetime as dt
import math
import socket
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import time
import urllib.request
import urllib.parse
import urllib.error

CONFIG = Path(os.environ.get('XDG_CONFIG_HOME', str(Path.home() / '.config'))) / 'archruud' / 'kairos-original'
STATE = Path(os.environ.get('XDG_CACHE_HOME', str(Path.home() / '.cache'))) / 'archruud' / 'kairos-original'
FILE = CONFIG / 'settings.json'
KAIROS = dict(padLeft=16, padRight=16, padTop=6, padBottom=10,
              clock12h=False, clockSeconds=True, dateWheel=True,
              music=True, tray=False, showLocation=True, musicPeek=100)
DEFAULT = dict(kairos=KAIROS, weatherLocation='', weatherUnit='celsius',
               weatherSpot='auto', weatherModeVersion=1,
               locations={
                   'home': {'name': 'Hjemme', 'lat': 59.546666, 'lon': 11.626059},
                   'cabin': {'name': 'Hytta', 'lat': 59.367511, 'lon': 11.840253}
               })


def read_config():
    data = json.loads(json.dumps(DEFAULT))
    try:
        raw = json.loads(FILE.read_text())
        if isinstance(raw, dict):
            for k in ('weatherLocation', 'weatherUnit', 'weatherSpot', 'locations', 'weatherModeVersion'):
                if k in raw:
                    data[k] = raw[k]
            # v0.3.9 shipped with 'home' as an invisible default. v0.4.0
            # changes this untouched legacy default to automatic, only once.
            if raw.get('weatherModeVersion') != 1 and raw.get('weatherSpot', 'home') == 'home':
                data['weatherSpot'] = 'auto'
            if data.get('weatherSpot') not in ('auto', 'home', 'cabin', 'custom'):
                data['weatherSpot'] = 'auto'
            if not isinstance(data.get('locations'), dict):
                data['locations'] = {}
            for key, coord in DEFAULT['locations'].items():
                if not valid_spot(data['locations'].get(key)):
                    data['locations'][key] = dict(coord)
            if not valid_spot(data['locations'].get('custom')):
                data['locations'].pop('custom', None)
                if data['weatherSpot'] == 'custom':
                    data['weatherSpot'] = 'auto'
            if isinstance(raw.get('kairos'), dict):
                for k, v in raw['kairos'].items():
                    if (k in KAIROS and type(v) is type(KAIROS[k])
                            and (k not in ('padLeft', 'padRight', 'padTop', 'padBottom') or 0 <= v <= 64)):
                        data['kairos'][k] = v
    except (OSError, ValueError):
        pass
    return data


def atomic_write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix='.archruud-', dir=path.parent)
    try:
        with os.fdopen(fd, 'w') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
            f.write('\n')
        os.chmod(tmp, 0o600)
        os.replace(tmp, path)
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)


def command(args, timeout=12):
    try:
        return subprocess.run(args, capture_output=True, text=True, timeout=timeout, check=False)
    except (OSError, subprocess.TimeoutExpired) as e:
        return subprocess.CompletedProcess(args, 1, '', str(e))


def network():
    state = {'wifiPresent': False, 'wifiRadio': False,
             'wifiConnectivity': 'Disconnected', 'activeSsid': '',
             'accessPoints': [], 'localIp': '', 'publicIp': ''}
    result = command(['nmcli', '-t', '-f', 'WIFI', 'general'], timeout=4)
    state['wifiRadio'] = result.stdout.strip().lower().endswith('enabled')
    result = command(['nmcli', '-t', '-f', 'TYPE,DEVICE,STATE,CONNECTION', 'device', 'status'])
    state['wifiPresent'] = any('wifi:' in line or 'wireless:' in line for line in result.stdout.splitlines())
    result = command(['nmcli', '-t', '-f', 'IN-USE,SSID,SIGNAL,SECURITY', 'dev', 'wifi', 'list', '--rescan', 'no'])
    for line in result.stdout.splitlines():
        # nmcli escapes colons inside SSIDs; this is intentionally conservative.
        parts = re.split(r'(?<!\\):', line)
        parts = [p.replace('\\:', ':').replace('\\\\', '\\') for p in parts]
        if len(parts) < 4:
            continue
        active, ssid, strength, sec = parts[:4]
        if not ssid:
            continue
        is_active = active.strip() == '*'
        if is_active:
            state['activeSsid'] = ssid
            state['wifiConnectivity'] = 'Connected'
        state['accessPoints'].append({'active': is_active, 'ssid': ssid,
               'strength': int(strength) if strength.isdigit() else 0,
               'security': sec, 'saved': False, 'bssid': ''})
    # Local IP for the default IPv4 route, fall back to the first global address.
    route = command(['ip', '-4', 'route', 'get', '1.1.1.1'], timeout=3).stdout
    match = re.search(r'\bsrc\s+(\d+(?:\.\d+){3})', route)
    if match:
        state['localIp'] = match.group(1)
    ip_file = STATE / 'public-ip.json'
    try:
        cached = json.loads(ip_file.read_text())
    except (ValueError, OSError):
        cached = {}
    if time.time() - float(cached.get('time', 0)) > 900:
        try:
            req = urllib.request.Request('https://api.ipify.org', headers={'User-Agent': 'ARCHRUUD-Kairos/0.3'})
            with urllib.request.urlopen(req, timeout=3) as r:
                ip = r.read(64).decode().strip()
            if re.fullmatch(r'[0-9a-fA-F:.]+', ip):
                cached = {'time': time.time(), 'ip': ip}
                atomic_write(ip_file, cached)
        except (OSError, ValueError, TimeoutError):
            pass
    state['publicIp'] = str(cached.get('ip', ''))
    return state


def _fetch_json(url, headers=None, timeout=6):
    req = urllib.request.Request(url, headers=headers or {
        'User-Agent': 'ARCHRUUD-Kairos/0.4 (https://github.com/archruud/quickshell-modules)',
        'Accept': 'application/json'})
    with urllib.request.urlopen(req, timeout=timeout) as response:
        return json.load(response)


def _auto_location():
    """Approximate IP geolocation, not GPS. Cache for 30 minutes."""
    cached_file = STATE / 'automatic-location.json'
    cached = {}
    try:
        cached = json.loads(cached_file.read_text(encoding='utf-8'))
        if time.time() - float(cached.get('time', 0)) < 1800:
            loc = cached.get('location')
            if isinstance(loc, dict) and valid_spot(loc):
                return loc
    except (OSError, ValueError, TypeError):
        pass
    sources = (
        ('https://ipwho.is/', lambda d: (d.get('success', False), d.get('latitude'), d.get('longitude'), d.get('city'), d.get('country'))),
        ('https://ipapi.co/json/', lambda d: (not d.get('error', False), d.get('latitude'), d.get('longitude'), d.get('city'), d.get('country_name')))
    )
    for url, decoder in sources:
        try:
            obj = _fetch_json(url, timeout=4)
            ok, lat, lon, city, country = decoder(obj)
            if not ok:
                continue
            loc = {'name': str(city or country or 'Automatic location')[:80],
                   'lat': float(lat), 'lon': float(lon)}
            if not valid_spot(loc):
                continue
            atomic_write(cached_file, {'time': time.time(), 'location': loc})
            return loc
        except (OSError, ValueError, TypeError, TimeoutError, KeyError):
            continue
    # Reuse last location with a stale indication rather than guessing Home.
    loc = cached.get('location') if isinstance(cached, dict) else None
    return loc if valid_spot(loc) else None


def valid_spot(spot):
    if not isinstance(spot, dict):
        return False
    try:
        lat, lon = float(spot['lat']), float(spot['lon'])
        return math.isfinite(lat) and math.isfinite(lon) and (-90 <= lat <= 90) and (-180 <= lon <= 180)
    except (TypeError, ValueError, KeyError):
        return False


def _symbol_to_wmo(symbol):
    # MET Locationforecast uses symbol_code, not numeric WMO weather codes.
    sym = symbol.lower()
    if 'thunder' in sym: return 95
    if 'heavysnow' in sym: return 75
    if 'snow' in sym: return 71
    if 'sleet' in sym: return 66
    if 'heavyrain' in sym: return 65
    if 'rain' in sym: return 61
    if 'fog' in sym: return 45
    if 'clearsky' in sym: return 0
    if 'fair' in sym: return 1
    if 'partlycloudy' in sym: return 2
    return 3


def _condition(symbol):
    sym = symbol.lower()
    for key, label in (
        ('thunder', 'Thunder'), ('snow', 'Snow'), ('sleet', 'Sleet'),
        ('rain', 'Rain'), ('fog', 'Fog'), ('clearsky', 'Clear sky'),
        ('partlycloudy', 'Partly cloudy'), ('fair', 'Fair'), ('cloudy', 'Cloudy')
    ):
        if key in sym:
            return label
    return 'Cloudy'


def _date_key(raw):
    return dt.datetime.fromisoformat(raw.replace('Z', '+00:00'))


def _forecast_data(timeseries, fahrenheit):
    now = dt.datetime.now(dt.timezone.utc)
    local_tz = dt.datetime.now().astimezone().tzinfo
    rows = []
    for item in timeseries:
        try:
            at = _date_key(item['time'])
            if at < now - dt.timedelta(hours=2):
                continue
            details = item['data']['instant']['details']
            temp_c = float(details['air_temperature'])
            sym = (item['data'].get('next_1_hours', {}).get('summary', {}).get('symbol_code')
                   or item['data'].get('next_6_hours', {}).get('summary', {}).get('symbol_code')
                   or 'cloudy')
            wind = float(details.get('wind_speed', 0))
            rain = item['data'].get('next_1_hours', {}).get('details', {}).get('precipitation_amount')
            rows.append({'at': at, 'tempC': temp_c, 'temp': round(temp_c * 9/5 + 32 if fahrenheit else temp_c),
                         'symbol': sym, 'code': _symbol_to_wmo(sym), 'wind': round(wind, 1),
                         'rain': max(0, float(rain)) if rain is not None else None})
        except (KeyError, TypeError, ValueError, OverflowError):
            continue
    if not rows:
        return None, [], []
    hourly = []
    for row in rows:
        # up to the next 24h, one sample every >=3h
        if row['at'] > now + dt.timedelta(hours=24):
            break
        if hourly and (row['at'] - hourly[-1]['_at']).total_seconds() < 3 * 3600:
            continue
        hourly.append({'_at': row['at'], 'time': row['at'].astimezone(local_tz).strftime('%H:%M'),
                       'temp': row['temp'], 'code': row['code'], 'wind': row['wind'], 'rain': row['rain']})
        if len(hourly) >= 8:
            break
    for item in hourly:
        del item['_at']
    by_day = {}
    for row in rows:
        day = row['at'].astimezone(local_tz).date()
        if day > (now.astimezone(local_tz) + dt.timedelta(days=8)).date():
            continue
        by_day.setdefault(day, []).append(row)
    days = []
    daynames = ('Man', 'Tir', 'Ons', 'Tor', 'Fre', 'Lør', 'Søn')
    for day in sorted(by_day)[:8]:
        rr = by_day[day]
        midday = min(rr, key=lambda r: abs(r['at'].astimezone(local_tz).hour - 12))
        low = min(r['tempC'] for r in rr)
        high = max(r['tempC'] for r in rr)
        to_unit = lambda c: round(c * 9/5 + 32 if fahrenheit else c)
        days.append({'day': daynames[day.weekday()] + ' ' + str(day.day) + '.' + str(day.month) + '.',
                     'min': to_unit(low), 'max': to_unit(high), 'code': midday['code'],
                     'wind': max(r['wind'] for r in rr)})
    return rows[0], hourly, days


def weather():
    data = read_config()
    mode = data.get('weatherSpot', 'auto')
    empty = {'available': False, 'city': '', 'location': '', 'selectedSpot': mode,
             'status': 'Weather unavailable', 'automatic': mode == 'auto',
             'current': None, 'condition': '', 'tempNow': 0, 'isDay': True,
             'hourly': [], 'daily': [], 'wind': 0}
    spot = (_auto_location() if mode == 'auto'
            else data.get('locations', {}).get(mode))
    if not valid_spot(spot):
        empty['status'] = ('Could not determine automatic location' if mode == 'auto'
                           else 'Location not configured')
        return empty
    lat, lon = float(spot['lat']), float(spot['lon'])
    empty['city'] = empty['location'] = str(spot.get('name') or mode.title())[:80]
    cache = STATE / f'weather-{mode}-{lat:.4f}-{lon:.4f}.json'
    frame = None
    stale = False
    try:
        saved = json.loads(cache.read_text())
        if time.time() - float(saved.get('time', 0)) < 1200:
            frame = saved.get('data')
    except (ValueError, OSError, TypeError):
        saved = {}
    if frame is None:
        url = f'https://api.met.no/weatherapi/locationforecast/2.0/compact?lat={lat:.4f}&lon={lon:.4f}'
        try:
            frame = _fetch_json(url, timeout=8)
            atomic_write(cache, {'time': time.time(), 'data': frame})
        except (OSError, ValueError, TimeoutError):
            frame = saved.get('data') if isinstance(saved, dict) else None
            stale = True
            if frame is None:
                empty['status'] = 'Weather network request failed'
                return empty
    try:
        fahrenheit = data.get('weatherUnit') == 'fahrenheit'
        latest, hourly, days = _forecast_data(frame['properties']['timeseries'], fahrenheit)
        if latest is None:
            return empty
        sym = latest['symbol']
        return {'available': True, 'city': empty['city'], 'location': empty['location'],
                'selectedSpot': mode, 'automatic': mode == 'auto',
                'status': 'Cached forecast (offline)' if stale else 'MET Norway forecast',
                'current': {'code': latest['code']}, 'condition': _condition(sym),
                'tempNow': latest['temp'], 'isDay': not sym.endswith('_night'),
                'hourly': hourly, 'daily': days, 'wind': latest['wind']}
    except (TypeError, ValueError, KeyError, IndexError, OverflowError):
        return empty


def validate_place(place, default_name='Selected place'):
    """Validate all third-party/user-supplied location input before persisting."""
    if not valid_spot(place):
        raise ValueError('Coordinates must be valid latitude and longitude')
    name = str(place.get('name') or default_name).strip()[:80]
    if not name:
        name = default_name
    return {'name': name, 'lat': round(float(place['lat']), 6),
            'lon': round(float(place['lon']), 6)}


def search_places(query):
    """Manual-only search; avoids autocomplete forbidden by Nominatim policy.

    Accepts pasted Google Maps coordinates or a place name. Caches search
    results and rate-limits requests to the public OpenStreetMap instance.
    """
    query = str(query).strip()
    if not query or len(query) > 120:
        raise ValueError('Enter a place name or coordinates (max 120 characters)')
    coord = re.fullmatch(r'\s*([+-]?\d{1,3}(?:\.\d+)?)\s*[,; ]\s*([+-]?\d{1,3}(?:\.\d+)?)\s*',query)
    if coord:
        place = validate_place({'name': 'Coordinates: ' + query,
                                'lat': float(coord.group(1)), 'lon': float(coord.group(2))})
        return {'results': [place], 'status': 'Coordinates ready to use'}
    cache_dir = STATE / 'search-cache'
    import hashlib
    cache_key = hashlib.sha256(query.casefold().encode('utf-8')).hexdigest()
    saved_file = cache_dir / (cache_key + '.json')
    try:
        saved = json.loads(saved_file.read_text())
        if time.time() - float(saved.get('time', 0)) < 86400:
            return {'results': saved['results'], 'status': 'Cached place search'}
    except (OSError, ValueError, KeyError, TypeError):
        pass
    # 1 req/s across searches, no auto-complete and max 5 results.
    throttle = STATE / 'last-place-query.json'
    try:
        prior = json.loads(throttle.read_text())
        elapsed = time.time() - float(prior.get('time', 0))
        if elapsed < 1.1:
            time.sleep(1.1 - max(0, elapsed))
    except (OSError, ValueError, TypeError):
        pass
    atomic_write(throttle, {'time': time.time()})
    params = urllib.parse.urlencode({'q': query, 'format': 'jsonv2', 'limit': 5,
                                     'addressdetails': 0, 'accept-language': 'nb,en'})
    url = 'https://nominatim.openstreetmap.org/search?' + params
    req = urllib.request.Request(url, headers={
        'User-Agent': 'ARCHRUUD-Kairos/0.4.1 (https://github.com/archruud/quickshell-modules)',
        'Accept-Language': 'nb,en', 'Accept': 'application/json'})
    try:
        with urllib.request.urlopen(req, timeout=10) as res:
            raw = json.load(res)
    except (OSError, ValueError, TimeoutError, urllib.error.HTTPError) as exc:
        raise ValueError('Place search is unavailable (network or rate limit)') from exc
    results = []
    for candidate in raw if isinstance(raw,list) else []:
        try:
            item = validate_place({'name': candidate.get('display_name',''),
                                   'lat': candidate.get('lat'), 'lon': candidate.get('lon')})
            if item not in results:
                results.append(item)
        except (ValueError, TypeError):
            pass
    atomic_write(saved_file, {'time': time.time(), 'results': results})
    return {'results': results, 'status': ('Select a location' if results else 'No matching places found')}


def update_location(key, place, select=False):
    """Atomically modify only the chosen place, preserving clock/misc settings."""
    if key not in ('home', 'cabin', 'custom'):
        raise ValueError('Invalid location type')
    place = validate_place(place, DEFAULT['locations'].get(key, {'name':'Selected place'})['name'])
    data = read_config()
    data['locations'][key] = place
    if select:
        data['weatherSpot'] = key
        data['weatherModeVersion'] = 1
    atomic_write(FILE, data)
    return {'key': key, 'spot': data['weatherSpot'], 'place': place}


def brightness():
    r = command(['brightnessctl', '-m'], timeout=3)
    m = re.search(r'(\d+)%', r.stdout)
    return {'available': bool(m), 'percent': int(m.group(1)) if m else 50}


def main(args):
    if not args:
        raise ValueError('A command is required')
    action = args[0]
    if action == 'settings':
        print(json.dumps(read_config()))
    elif action == 'set' and len(args) == 3:
        path, value = args[1], json.loads(args[2]); obj = read_config()
        if path == 'kairos':
            if not isinstance(value, dict): raise ValueError('Invalid settings object')
            obj['kairos'] = {**KAIROS, **{k:v for k,v in value.items() if k in KAIROS}}
        elif path.startswith('kairos.') and path[7:] in KAIROS:
            if type(value) is not type(KAIROS[path[7:]]): raise ValueError('Wrong setting type')
            if path[7:] in ('padLeft', 'padRight', 'padTop', 'padBottom') and not 0 <= value <= 64:
                raise ValueError('Padding must be between 0 and 64 px')
            obj['kairos'][path[7:]] = value
        elif path == 'weatherSpot':
            if value not in ('auto', 'home', 'cabin', 'custom'):
                raise ValueError('Invalid weather mode')
            if value == 'custom' and not valid_spot(obj['locations'].get('custom')):
                raise ValueError('Select a place before activating the custom location')
            obj[path] = value
            obj['weatherModeVersion'] = 1
        elif path == 'weatherUnit':
            if value not in ('celsius', 'fahrenheit'):
                raise ValueError('Invalid temperature unit')
            obj[path] = value
        elif path == 'weatherLocation':
            if not isinstance(value, str) or len(value) > 200:
                raise ValueError('Invalid location label')
            obj[path] = value
        else:
            raise ValueError('Unsupported settings path')
        atomic_write(FILE, obj)
    elif action == 'search-place' and len(args) == 2:
        print(json.dumps(search_places(args[1]), ensure_ascii=False))
    elif action == 'save-location' and len(args) == 3:
        if args[1] not in ('home', 'cabin'):
            raise ValueError('Only Home and Cabin coordinates can be edited here')
        print(json.dumps(update_location(args[1], json.loads(args[2]))))
    elif action == 'use-place' and len(args) == 2:
        print(json.dumps(update_location('custom', json.loads(args[1]), select=True)))
    elif action == 'network':
        print(json.dumps(network()))
    elif action == 'weather':
        print(json.dumps(weather()))
    elif action == 'brightness':
        print(json.dumps(brightness()))
    elif action == 'wifi-toggle' and len(args) == 2:
        r = command(['nmcli', 'radio', 'wifi', args[1]])
        if r.returncode: raise ValueError(r.stderr or 'Could not change Wi-Fi radio')
    elif action == 'wifi-disconnect':
        dev = command(['nmcli','-t','-f','DEVICE,TYPE', 'device','status']).stdout
        wifi = next((l.split(':')[0] for l in dev.splitlines() if l.endswith(':wifi')), '')
        if not wifi: raise ValueError('No Wi-Fi interface')
        r = command(['nmcli','device','disconnect',wifi])
        if r.returncode: raise ValueError(r.stderr or 'Could not disconnect')
    elif action == 'wifi-connect' and len(args) == 5:
        ssid, password, bssid, hidden = args[1:]
        if not ssid: raise ValueError('No SSID')
        # Do not pass a plaintext Wi-Fi password on the command line in v0.3.
        # Existing connections can be activated without a password.
        if password: raise ValueError('Password-based Wi-Fi connection is not enabled in this test release; use nmgui')
        r = command(['nmcli', 'connection', 'up', 'id', ssid], timeout=18)
        if r.returncode: raise ValueError(r.stderr or 'Connection not saved; use nmgui')
    else:
        raise ValueError('Invalid command or arguments')


if __name__ == '__main__':
    try:
        main(sys.argv[1:])
    except (ValueError, OSError) as exc:
        print('ARCHRUUD Kairos: ' + str(exc), file=sys.stderr)
        sys.exit(1)
