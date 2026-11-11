#!/usr/bin/env python3
"""Static regression coverage for v1.0.1; runtime requires a real Wayland/PipeWire session."""
from pathlib import Path
import importlib.util
import tempfile
import unittest
from unittest import mock

BASE = Path(__file__).resolve().parents[1]
Q = BASE / 'config/quickshell/archruud-kairos-original'

class AudioNotificationPatchTests(unittest.TestCase):
    def test_default_sink_and_source_explicitly_tracked(self):
        audio = (Q/'services/Audio.qml').read_text()
        self.assertIn('PwObjectTracker { objects: [root.sink, root.source] }', audio)
        self.assertIn('PwObjectTracker { objects: root.all }', audio)

    def test_slider_commit_wiring(self):
        home = (Q/'quicksettings/pages/HomePage.qml').read_text()
        sound = (Q/'quicksettings/pages/SoundPage.qml').read_text()
        self.assertIn('onCommitted: (v) => Audio.commitOutputVolume(v)', home)
        self.assertIn('onCommitted: (v) => Audio.commitOutputVolume(v)', sound)
        self.assertIn('onCommitted: (v) => Audio.commitInputVolume(v)', sound)
        self.assertIn('function toggleOut() { Audio.toggleOutputMute(); }', sound)

    def test_transient_notification_conflicts_retry_safely(self):
        s=(Q/'services/Notifs.qml').read_text()
        self.assertIn('running: root.status === "conflict" || root.status === "error"',s)
        self.assertIn('if (!probeProcess.running) probeProcess.running = true;',s)
        self.assertIn('active: root.status === "active"',s)

    def test_idempotent_enable_for_kairos_owner_only(self):
        p=Q/'scripts/notifications_control.py'
        spec=importlib.util.spec_from_file_location('notifyctlv101',p)
        n=importlib.util.module_from_spec(spec); spec.loader.exec_module(n)
        with tempfile.TemporaryDirectory() as td:
            with (mock.patch.object(n,'FLAG',Path(td)/'notifications.enabled'),
                  mock.patch.object(n,'dbus_owner',return_value=True)):
                with mock.patch.object(n,'owner_is_kairos',return_value=True):
                    self.assertEqual(n.main(['ctl','enable']),0)
                    self.assertTrue(n.FLAG.exists())
                n.FLAG.unlink()
                with mock.patch.object(n,'owner_is_kairos',return_value=False):
                    self.assertEqual(n.main(['ctl','enable']),2)
                    self.assertFalse(n.FLAG.exists())

if __name__=='__main__':unittest.main()
