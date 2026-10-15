"""Offline unit/integration tests for ARCHRUUD Kairos 0.4.0 weather."""
import datetime as dt
import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest import mock

BACKEND = Path(__file__).resolve().parents[1] / 'config/quickshell/archruud-kairos-original/scripts/backend.py'
spec = importlib.util.spec_from_file_location('archruud_weather_backend', BACKEND)
backend = importlib.util.module_from_spec(spec)
spec.loader.exec_module(backend)


def met_sample():
    base = dt.datetime.now(dt.timezone.utc).replace(minute=0, second=0, microsecond=0)
    return {'properties': {'timeseries': [
        {'time': (base + dt.timedelta(hours=i)).isoformat().replace('+00:00', 'Z'),
         'data': {'instant': {'details': {'air_temperature': 2+i/4, 'wind_speed': 3}},
                  'next_1_hours': {'summary': {'symbol_code': 'cloudy_day'},
                                   'details': {'precipitation_amount': 0.0}}}}
        for i in range(0, 7*24)
    ]}}


class WeatherTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.configdir = Path(self.tmp.name) / 'config'
        self.statedir = Path(self.tmp.name) / 'cache'
        backend.CONFIG = self.configdir
        backend.STATE = self.statedir
        backend.FILE = self.configdir / 'settings.json'

    def test_default_is_auto_and_coordinates(self):
        d = backend.read_config()
        self.assertEqual(d['weatherSpot'], 'auto')
        self.assertAlmostEqual(d['locations']['home']['lat'], 59.546666)
        self.assertAlmostEqual(d['locations']['cabin']['lon'], 11.840253)

    def test_legacy_home_becomes_auto_while_preserving_padding(self):
        backend.atomic_write(backend.FILE, {'weatherSpot': 'home', 'kairos': {'padLeft': 39, 'padBottom': 55}})
        d = backend.read_config()
        self.assertEqual(d['weatherSpot'], 'auto')
        self.assertEqual(d['kairos']['padLeft'], 39)
        self.assertEqual(d['kairos']['padBottom'], 55)

    def test_new_explicit_home_remains_selected(self):
        backend.atomic_write(backend.FILE, {'weatherSpot': 'home', 'weatherModeVersion': 1})
        self.assertEqual(backend.read_config()['weatherSpot'], 'home')

    def test_three_modes_forecast_and_settings_survive(self):
        with mock.patch.object(backend, '_fetch_json', return_value=met_sample()):
            backend.atomic_write(backend.FILE, {'weatherSpot': 'cabin', 'weatherModeVersion': 1,
                             'kairos': {'padLeft': 51, 'padRight': 47, 'padTop': 12, 'padBottom': 31}})
            result = backend.weather()
            self.assertTrue(result['available'])
            self.assertEqual(result['city'], 'Hytta')
            self.assertEqual(result['selectedSpot'], 'cabin')
            self.assertGreater(len(result['hourly']), 0)
            self.assertEqual(len(result['daily']), 8)
            self.assertEqual(backend.read_config()['kairos']['padLeft'], 51)
            self.assertEqual(backend.read_config()['kairos']['padBottom'], 31)

    def test_ip_autolocation_and_cache(self):
        ip_json = {'success': True, 'latitude': 59.42, 'longitude': 10.36, 'city': 'Horten', 'country': 'Norway'}
        with mock.patch.object(backend, '_fetch_json', return_value=ip_json) as request:
            loc = backend._auto_location()
            self.assertEqual(loc['name'], 'Horten')
            loc2 = backend._auto_location()
            self.assertEqual(loc2, loc)
            request.assert_called_once()

    def test_invalid_ip_geo_is_not_accepted(self):
        with mock.patch.object(backend, '_fetch_json', return_value={'success': False}):
            self.assertIsNone(backend._auto_location())

    def test_network_fallback_does_not_guess_home(self):
        with mock.patch.object(backend, '_fetch_json', side_effect=OSError('offline')):
            d = backend.weather()
            self.assertFalse(d['available'])
            self.assertEqual(d['selectedSpot'], 'auto')


if __name__ == '__main__': unittest.main()
