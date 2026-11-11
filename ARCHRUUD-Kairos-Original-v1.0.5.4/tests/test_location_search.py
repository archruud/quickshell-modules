"""Offline tests for ARCHRUUD Kairos v0.4.2 location search and persistence."""
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

BACKEND = Path(__file__).resolve().parents[1] / 'config/quickshell/archruud-kairos-original/scripts/backend.py'
spec = importlib.util.spec_from_file_location('archruud_places_backend', BACKEND)
backend = importlib.util.module_from_spec(spec)
spec.loader.exec_module(backend)


class PlacesTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        backend.CONFIG = Path(self.tmp.name) / 'config'
        backend.STATE = Path(self.tmp.name) / 'state'
        backend.FILE = backend.CONFIG / 'settings.json'

    def test_pasted_google_maps_coordinates_are_local(self):
        with mock.patch.object(backend.urllib.request, 'urlopen', side_effect=AssertionError('network')):
            result = backend.search_places('59.546666, 11.626059')
        self.assertEqual(len(result['results']), 1)
        self.assertAlmostEqual(result['results'][0]['lat'], 59.546666)
        self.assertAlmostEqual(result['results'][0]['lon'], 11.626059)

    def test_invalid_coordinate_rejected(self):
        with self.assertRaises(ValueError):
            backend.search_places('91.5, 11.5')
        with self.assertRaises(ValueError):
            backend.update_location('home', {'name': 'Home', 'lat': -200, 'lon': 10})

    def test_save_home_without_losing_clock_padding(self):
        backend.atomic_write(backend.FILE, {'weatherSpot': 'cabin', 'weatherModeVersion': 1,
                                           'kairos': {'padLeft': 57, 'padTop': 30}})
        saved = backend.update_location('home', {'name':'Home','lat': 60.4, 'lon': 9.1})
        config = backend.read_config()
        self.assertEqual(saved['key'], 'home')
        self.assertEqual(config['weatherSpot'], 'cabin')
        self.assertEqual(config['kairos']['padLeft'], 57)
        self.assertAlmostEqual(config['locations']['home']['lat'], 60.4)
        self.assertAlmostEqual(config['locations']['cabin']['lat'], 59.367511)

    def test_selection_creates_custom_mode_and_persists(self):
        data = backend.update_location('custom', {'name': 'Sarpsborg, Norway', 'lat': 59.28, 'lon':11.12}, select=True)
        cfg = backend.read_config()
        self.assertEqual(data['spot'], 'custom')
        self.assertEqual(cfg['weatherSpot'], 'custom')
        self.assertAlmostEqual(cfg['locations']['custom']['lat'], 59.28)
        self.assertEqual(cfg['weatherModeVersion'], 1)

    def test_coordinate_custom_name_orje_persists_without_changing_home_or_cabin(self):
        # Exact example from Google Maps, including Norway's Ø character.
        raw = backend.search_places('59.480096431827846, 11.660505265497692')['results'][0]
        raw['name'] = 'Ørje'
        result = backend.update_location('custom', raw, select=True)
        after = backend.read_config()
        self.assertEqual(result['place']['name'], 'Ørje')
        self.assertEqual(after['locations']['custom']['name'], 'Ørje')
        self.assertEqual(after['weatherSpot'], 'custom')
        self.assertAlmostEqual(after['locations']['custom']['lat'], 59.480096, places=6)
        self.assertAlmostEqual(after['locations']['custom']['lon'], 11.660505, places=6)
        self.assertEqual(after['locations']['home']['name'], 'Hjemme')
        self.assertEqual(after['locations']['cabin']['name'], 'Hytta')
        # Renaming coordinates does not change their saved position.
        raw['name'] = 'Ørje sentrum'
        backend.update_location('custom', raw, select=True)
        renamed = backend.read_config()['locations']['custom']
        self.assertEqual(renamed['name'], 'Ørje sentrum')
        self.assertAlmostEqual(renamed['lat'], 59.480096, places=6)

    def test_optional_name_is_only_applied_to_coordinate_result_in_qml(self):
        qml = (Path(__file__).resolve().parents[1] /
               'config/quickshell/archruud-kairos-original/settings/LocationSearch.qml').read_text()
        self.assertIn('visible: search.coordinateQuery', qml)
        self.assertIn('Optional place name', qml)
        self.assertIn('selected.name = labelInput.text.trim()', qml)
        self.assertIn('Weather.usePlace(selected)', qml)

    def test_bad_custom_mode_falls_back_safely(self):
        backend.atomic_write(backend.FILE, {'weatherSpot':'custom', 'weatherModeVersion':1,
                                           'locations': {'custom': {'lat': 'nan', 'lon': 0}}})
        self.assertEqual(backend.read_config()['weatherSpot'], 'auto')

    def test_geocoder_search_returns_short_list_and_caches(self):
        sample = [{'display_name':'Sarpsborg, Østfold, Norge', 'lat':'59.284', 'lon':'11.109'},
                  {'display_name':'Sarpsborg, Norway', 'lat':'59.281', 'lon':'11.11'}]
        from io import BytesIO
        class JsonResponse(BytesIO):
            def __enter__(self): return self
            def __exit__(self, *args): self.close()
        with mock.patch.object(backend.urllib.request, 'urlopen', return_value=JsonResponse(json.dumps(sample).encode())) as urlopen:
            first = backend.search_places('Sarpsborg')
            second = backend.search_places('Sarpsborg')
        self.assertEqual(first['results'], second['results'])
        self.assertEqual(len(first['results']), 2)
        urlopen.assert_called_once()
        self.assertIn('© OpenStreetMap contributors', Path(__file__).resolve().parents[1].joinpath('LOCATION-SEARCH.md').read_text())

    def test_nonascii_city_name_roundtrip(self):
        backend.update_location('custom', {'name': 'Åmål, Sverige', 'lat':59.05, 'lon':12.7}, select=True)
        self.assertEqual(backend.read_config()['locations']['custom']['name'], 'Åmål, Sverige')


if __name__ == '__main__':
    unittest.main()
