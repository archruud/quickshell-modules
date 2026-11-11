#!/usr/bin/env python3
"""Safe activation checks for native Quickshell notifications."""
import importlib.util
import os
from pathlib import Path
import tempfile
import unittest
from unittest import mock

MODULE = (Path(__file__).resolve().parents[1] / "config" / "quickshell" /
          "archruud-kairos-original" / "scripts" / "notifications_control.py")
spec = importlib.util.spec_from_file_location("notifyctl", MODULE)
n = importlib.util.module_from_spec(spec)
spec.loader.exec_module(n)


class NotificationControlTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.flag = Path(self.tmp.name) / "notifications.enabled"
        self.flagpatch = mock.patch.object(n, "FLAG", self.flag)
        self.flagpatch.start()
        self.addCleanup(self.flagpatch.stop)

    def test_disabled_default(self):
        self.assertEqual(n.mode(), "disabled")

    def test_opt_in_denied_when_bus_owned(self):
        with mock.patch.object(n, "dbus_owner", return_value=True):
            self.assertEqual(n.main(["ctl", "enable"]), 2)
        self.assertFalse(self.flag.exists())

    def test_opt_in_denied_when_bus_unavailable(self):
        with mock.patch.object(n, "dbus_owner", return_value=None):
            self.assertEqual(n.main(["ctl", "enable"]), 2)
        self.assertFalse(self.flag.exists())

    def test_enable_disable_cycle(self):
        with mock.patch.object(n, "dbus_owner", return_value=False):
            self.assertEqual(n.main(["ctl", "enable"]), 0)
            self.assertEqual(n.mode(), "active")
        self.assertEqual(self.flag.stat().st_mode & 0o777, 0o600)
        self.assertEqual(n.main(["ctl", "disable"]), 0)
        self.assertEqual(n.mode(), "disabled")

    def test_conflict_if_owner_appears(self):
        self.flag.write_text("on")
        with mock.patch.object(n, "dbus_owner", return_value=True):
            self.assertEqual(n.mode(), "conflict")


    def test_status_recognizes_own_kairos_bus_name(self):
        self.flag.write_text("on")
        with (mock.patch.object(n, "dbus_owner", return_value=True),
              mock.patch.object(n, "owner_is_kairos", return_value=True)):
            self.assertEqual(n.mode(), "conflict")  # Startup probe must remain safe.
            self.assertEqual(n.status_mode(), "running")

    def test_status_other_daemon_is_conflict(self):
        self.flag.write_text("on")
        with (mock.patch.object(n, "dbus_owner", return_value=True),
              mock.patch.object(n, "owner_is_kairos", return_value=False)):
            self.assertEqual(n.status_mode(), "conflict")

    def test_owner_pid_and_cmdline(self):
        class Result:
            def __init__(self, stdout):
                self.stdout = stdout
                self.returncode = 0
        with mock.patch.object(n.subprocess, "run", side_effect=[Result("(':1.87',)"), Result("(uint32 927,)")]):
            self.assertEqual(n.notification_owner_pid(), 927)
        with (mock.patch.object(n, "notification_owner_pid", return_value=927),
              mock.patch.object(n.Path, "read_bytes", return_value=b"/usr/bin/qs\0-c\0archruud-kairos-original\0")):
            self.assertTrue(n.owner_is_kairos())
        with (mock.patch.object(n, "notification_owner_pid", return_value=927),
              mock.patch.object(n.Path, "read_bytes", return_value=b"/usr/bin/dunst\0")):
            self.assertFalse(n.owner_is_kairos())

    def test_gdbus_result_parser(self):
        class Result:
            def __init__(self, text):
                self.stdout = text
                self.returncode = 0
        with mock.patch.object(n.subprocess, "run", return_value=Result("(true,)\n")):
            self.assertIs(n.dbus_owner(), True)
        with mock.patch.object(n.subprocess, "run", return_value=Result("(false,)\n")):
            self.assertIs(n.dbus_owner(), False)
        with mock.patch.object(n.subprocess, "run", return_value=Result("junk")):
            self.assertIsNone(n.dbus_owner())

if __name__ == "__main__":
    unittest.main()
