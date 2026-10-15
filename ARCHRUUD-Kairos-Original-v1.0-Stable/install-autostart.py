#!/usr/bin/env python3
"""Install a standalone Hyprland Lua module with preview and automatic backup."""
from __future__ import annotations
import argparse
import datetime as dt
import difflib
import os
from pathlib import Path
import re
import shutil
import sys
import tempfile

HERE = Path(__file__).resolve().parent
HOME = Path.home()
CONFIG = HOME / ".config/hypr/hyprland.lua"
DEST = HOME / ".config/hypr/module-config/archruud-kairos-original.lua"
SOURCE = HERE / "config/hypr/module-config/archruud-kairos-original.lua"
BACKUPS = HOME / ".local/state/archruud/backups/kairos-autostart"
REQUIRE = 'require("module-config.archruud-kairos-original")'
OLD_CLOCK_REQUIRE = re.compile(r'^(\s*)(require\(\s*["\']module-config\.(?:quickshell-clock|archruud-clock)["\']\s*\)\s*(?:--[^\n]*)?)$', re.M)
OLD_CLOCK_EXEC = re.compile(r'^(\s*)(hl\.exec_cmd\(\s*["\']qs -c archruud-clock["\']\s*\)\s*(?:--[^\n]*)?)$', re.M)
DUNST_EXEC = re.compile(r'^(\s*)(hl\.exec_cmd\(\s*["\']dunst["\']\s*\)\s*(?:--[^\n]*)?)$', re.M)
REQUIRE_PATTERN = re.compile(r'^[ \t]*require\([ \t]*["\']module-config\.[^"\']+["\'][ \t]*\)[ \t]*(?:--[^\n]*)?$', re.M)
START_PATTERN = re.compile(r'^\s*hl\.on\(\s*["\']hyprland\.start["\']', re.M)
ACTIVE = re.compile(r'^\s*require\(\s*["\']module-config\.archruud-kairos-original["\']\s*\)', re.M)

def comment_exact(pattern, text, label):
    return pattern.sub(lambda m: m.group(1) + '-- ARCHRUUD Kairos: ' + label + ': ' + m.group(2).lstrip(), text)

def patch(content):
    result = comment_exact(OLD_CLOCK_REQUIRE, content, 'legacy clock disabled')
    result = comment_exact(OLD_CLOCK_EXEC, result, 'legacy clock disabled')
    result = comment_exact(DUNST_EXEC, result, 'Dunst autostart disabled (no package removed)')
    if ACTIVE.search(result): return result
    anchors = list(REQUIRE_PATTERN.finditer(result))
    if anchors:
        pos = result.find('\n', anchors[-1].end())
        if pos < 0: pos = len(result)
        result = result[:pos] + '\n' + REQUIRE + result[pos:]
    else:
        match = START_PATTERN.search(result)
        if match is None:
            raise ValueError('No safe module require or hyprland.start hook found; nothing changed.')
        result = result[:match.start()] + REQUIRE + '\n\n' + result[match.start():]
    return result

def atomic_text(path, contents):
    path.parent.mkdir(parents=True,exist_ok=True)
    fd,tmp = tempfile.mkstemp(prefix='.archruud-',dir=path.parent)
    try:
        with os.fdopen(fd,'w',encoding='utf-8') as f: f.write(contents)
        os.chmod(tmp,0o644)
        os.replace(tmp,path)
    finally:
        if os.path.exists(tmp): os.unlink(tmp)

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--dry-run',action='store_true')
    args=ap.parse_args()
    if not CONFIG.is_file(): sys.exit(f'ERROR: {CONFIG} does not exist.')
    if not (HOME/'.config/quickshell/archruud-kairos-original/shell.qml').is_file():
        sys.exit('ERROR: First install Kairos with bash install.sh.')
    original=CONFIG.read_text(encoding='utf-8')
    try: revised=patch(original)
    except ValueError as e: sys.exit('ERROR: '+str(e))
    mod=SOURCE.read_text(encoding='utf-8')
    previous=DEST.read_text(encoding='utf-8') if DEST.is_file() else None
    if args.dry_run:
        print('DRY RUN: Existing Hyprland config remains unchanged.\n')
        print(''.join(difflib.unified_diff(original.splitlines(True),revised.splitlines(True),fromfile='hyprland.lua (before)',tofile='hyprland.lua (proposed)')) or '(hyprland.lua already configured)')
        print('Lua module destination:',DEST, '(replace)' if previous is not None else '(new)')
        print('No packages, running services or other module files are touched.')
        return
    if revised==original and previous==mod:
        print('Kairos autostart already installed; no changes needed.')
        return
    stamp=dt.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    backup=BACKUPS/stamp
    backup.mkdir(parents=True,exist_ok=False)
    shutil.copy2(CONFIG,backup/'hyprland.lua')
    if DEST.is_file(): shutil.copy2(DEST,backup/'archruud-kairos-original.lua')
    (backup/'had_module.txt').write_text('yes\n' if DEST.is_file() else 'no\n',encoding='utf-8')
    atomic_text(DEST,mod)
    if revised!=original: atomic_text(CONFIG,revised)
    print('Lua module installed:',DEST)
    print('Import:',REQUIRE)
    print('Backup:',backup)
    print('Existing other Quickshell modules have not been changed.')
    print('Log out/in or reboot to test automatic startup.')
    print('NOTE: If Dunst has other autostart paths, disable them separately (see CLEANUP.md).')

if __name__=='__main__': main()
