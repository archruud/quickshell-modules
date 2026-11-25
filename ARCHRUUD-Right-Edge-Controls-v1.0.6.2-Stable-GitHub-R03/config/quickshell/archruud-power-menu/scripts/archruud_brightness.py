#!/usr/bin/env python3
"""ARCHRUUD Kairos monitor brightness.

Unprivileged, read-first DDC/CI or backlight interface; no system changes.
Usage: status | set N | up | down | diagnose
JSON output for status and set/up/down, human-readable diagnose.
"""
from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

CONF = Path.home() / '.config/archruud/kairos-brightness.json'


def config():
    data = {'backend': 'auto', 'ddc_display': 1, 'ddc_bus': None, 'min_percent': 10}
    try:
        supplied = json.loads(CONF.read_text()) if CONF.is_file() else {}
        if isinstance(supplied, dict):
            for key in data:
                if key in supplied:
                    data[key] = supplied[key]
    except (OSError, ValueError):
        pass
    if data['backend'] not in ('auto', 'ddcutil', 'brightnessctl'):
        data['backend'] = 'auto'
    try:
        data['ddc_display'] = max(1, min(16, int(data['ddc_display'])))
    except (TypeError, ValueError):
        data['ddc_display'] = 1
    try:
        data['ddc_bus'] = (None if data['ddc_bus'] is None
                           else max(0, min(1024, int(data['ddc_bus']))))
    except (TypeError, ValueError):
        data['ddc_bus'] = None
    try:
        data['min_percent'] = max(5, min(40, int(data['min_percent'])))
    except (TypeError, ValueError):
        data['min_percent'] = 10
    return data


def run(args, timeout=10):
    try:
        return subprocess.run(args, capture_output=True, text=True, timeout=timeout,
                              check=False)
    except (OSError, subprocess.TimeoutExpired):
        return None


def compact_error(proc):
    if proc is None:
        return 'Command not accessible or timed out'
    message = (proc.stderr or proc.stdout or '').strip().replace('\n', ' ')
    return ' '.join(message.split())[:190] or f'Exit code {proc.returncode}'


def read_backlight():
    if not shutil.which('brightnessctl'):
        return None, 'brightnessctl not installed'
    cur = run(['brightnessctl', '-c', 'backlight', 'get'], 3)
    upper = run(['brightnessctl', '-c', 'backlight', 'max'], 3)
    if not cur or not upper or cur.returncode or upper.returncode:
        return None, 'No usable internal backlight found'
    try:
        raw, maximum = int(cur.stdout.strip()), int(upper.stdout.strip())
        if maximum <= 0:
            return None, 'Backlight reports invalid maximum'
    except (ValueError, TypeError):
        return None, 'Invalid brightnessctl result'
    return {'backend': 'brightnessctl', 'percent': round(raw/maximum*100),
            'available': True, 'detail': 'Internal backlight'}, ''


def ddc_selector(settings):
    bus = settings.get('ddc_bus')
    if bus is not None:
        return ['--bus', str(bus)]
    return ['--display', str(settings['ddc_display'])]


def parse_vcp(text):
    # ddcutil --brief: 'VCP 10 C 50 100' (decimal current/max).
    m = re.search(r'\bVCP\s+(?:0x)?10\s+C\s+(\d+)\s+(\d+)\b', text, re.I)
    if not m:
        # Normal ddcutil formatting: 'current value = 50, max value = 100'
        m = re.search(r'current\s+value\s*=\s*(\d+).*?max\s+value\s*=\s*(\d+)', text, re.I | re.S)
    if not m:
        return None
    cur, maximum = map(int, m.groups())
    if maximum <= 0 or cur < 0:
        return None
    return cur, maximum


def read_ddc(settings):
    if not shutil.which('ddcutil'):
        return None, 'ddcutil is not installed; install with: sudo pacman -S --needed ddcutil'
    selector = ddc_selector(settings)
    proc = run(['ddcutil', 'getvcp', '10', *selector, '--brief'], 12)
    if not proc or proc.returncode:
        reason = compact_error(proc)
        if not list(Path('/dev').glob('i2c-*')):
            reason += ' | /dev/i2c-* absent (i2c-dev module/driver?)'
        return None, f'DDC/CI unavailable: {reason}'
    vals = parse_vcp(proc.stdout)
    if not vals:
        return None, 'Monitor did not return readable brightness (VCP 0x10)'
    current, maximum = vals
    where = f'bus {settings["ddc_bus"]}' if settings['ddc_bus'] is not None else f'display {settings["ddc_display"]}'
    return {'backend': 'ddcutil', 'percent': round(current/maximum*100),
            'available': True, 'detail': f'DDC/CI monitor {where}',
            'max_raw': maximum}, ''


def read(settings):
    reasons = []
    if settings['backend'] in ('auto', 'brightnessctl'):
        info, reason = read_backlight()
        if info:
            return info
        reasons.append(reason)
    if settings['backend'] in ('auto', 'ddcutil'):
        info, reason = read_ddc(settings)
        if info:
            return info
        reasons.append(reason)
    return {'available': False, 'percent': 0, 'backend': 'none',
            'detail': '; '.join(reasons) or 'No available brightness backend'}


def write(percent, settings, info):
    if not info.get('available'):
        return False, 'No backend'
    percent = max(settings['min_percent'], min(100, int(percent)))
    if info['backend'] == 'brightnessctl':
        cmd = ['brightnessctl', '-c', 'backlight', 'set', f'{percent}%']
    else:
        maximum = int(info.get('max_raw', 100))
        raw = max(1, min(maximum, round(maximum * percent / 100)))
        cmd = ['ddcutil', 'setvcp', '10', str(raw), *ddc_selector(settings)]
    proc = run(cmd, 16)
    return bool(proc is not None and proc.returncode == 0), compact_error(proc)


def diagnose(settings):
    print('ARCHRUUD Monitor Light diagnostics (read-only)')
    print('Configuration:', CONF)
    print('Requested backend:', settings['backend'])
    print('Selector:', ' '.join(ddc_selector(settings)))
    print('brightnessctl:', shutil.which('brightnessctl') or 'not installed')
    print('ddcutil:', shutil.which('ddcutil') or 'not installed')
    print('i2c-dev:', 'available' if Path('/sys/module/i2c_dev').exists() else 'not detected')
    dev = sorted(Path('/dev').glob('i2c-*'))
    print('I2C devices:', ', '.join(str(x) for x in dev) if dev else 'none')
    for path in dev:
        print(' ', path, 'readable=', os.access(path, os.R_OK), 'writable=', os.access(path, os.W_OK))
    if shutil.which('ddcutil'):
        proc = run(['ddcutil', 'detect', '--brief'], 20)
        print('ddcutil detect --brief:',
              (proc.stdout.strip() if proc and proc.returncode == 0 else compact_error(proc)))
        proc = run(['ddcutil', 'getvcp', '10', *ddc_selector(settings), '--brief'], 12)
        print('ddcutil VCP 0x10:',
              (proc.stdout.strip() if proc and proc.returncode == 0 else compact_error(proc)))
    info = read(settings)
    print('Kairos status:', json.dumps(info, ensure_ascii=False))
    print('No monitor settings were changed.')


def main(args):
    settings = config()
    if len(args) == 1 and args[0] == 'diagnose':
        diagnose(settings)
        return 0
    if not args or args[0] not in ('status', 'set', 'up', 'down'):
        print('Usage: archruud_brightness.py status|set N|up|down|diagnose', file=sys.stderr)
        return 2
    if args[0] == 'set' and (len(args) != 2 or not re.fullmatch(r'\d{1,3}', args[1])):
        print('Brightness must be an integer 0..100', file=sys.stderr)
        return 2
    info = read(settings)
    if args[0] == 'status':
        print(json.dumps(info))
        return 0
    if not info['available']:
        print(json.dumps(info))
        return 1
    target = (int(args[1]) if args[0] == 'set' else
              info['percent'] + (5 if args[0] == 'up' else -5))
    target = max(settings['min_percent'], min(100, target))
    ok, error = write(target, settings, info)
    result = {'available': ok, 'backend': info['backend'],
              'percent': target if ok else info['percent'],
              'detail': 'Brightness set' if ok else 'Could not set brightness: ' + error}
    print(json.dumps(result))
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
