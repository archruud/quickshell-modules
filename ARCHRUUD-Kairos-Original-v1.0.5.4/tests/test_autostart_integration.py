import importlib.util
from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parent.parent
SPEC=importlib.util.spec_from_file_location('kairos_autostart',ROOT/'install-autostart.py')
mod=importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(mod)
class AutostartTest(unittest.TestCase):
    def test_basic_real_hyprland_layout(self):
        initial='require("module-config.quickshell-clock")\nrequire("module-config.archruud-power-menu")\n\nhl.on("hyprland.start", function()\n  hl.exec_cmd("dunst")\nend)\n'
        result=mod.patch(initial)
        self.assertIn(mod.REQUIRE,result)
        self.assertIn('-- ARCHRUUD Kairos: legacy clock disabled',result)
        self.assertIn('-- ARCHRUUD Kairos: Dunst autostart disabled',result)
        self.assertIn('require("module-config.archruud-power-menu")',result)
        self.assertEqual(result,mod.patch(result))
    def test_inserts_before_start_if_no_require(self):
        sample='hl.on("hyprland.start", function()\n  hl.exec_cmd("kitty")\nend)\n'
        s=mod.patch(sample)
        self.assertLess(s.index(mod.REQUIRE),s.index('hl.on('))
    def test_does_not_touch_comments_or_rofi(self):
        sample='-- hl.exec_cmd("dunst")\nlocal menu = "rofi -show drun"\nrequire("module-config.quickshell-wallpaper")\n'
        s=mod.patch(sample)
        self.assertIn('-- hl.exec_cmd("dunst")',s)
        self.assertIn('rofi -show drun',s)
    def test_fails_closed(self):
        with self.assertRaises(ValueError): mod.patch('print("no hooks")\n')
    def test_module_consistent(self):
        module=(ROOT/'config/hypr/module-config/archruud-kairos-original.lua').read_text()
        self.assertIn('hl.on("hyprland.start"',module)
        self.assertIn('qs -c archruud-kairos-original',module)
if __name__=='__main__':unittest.main()
