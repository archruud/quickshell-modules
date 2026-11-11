#!/usr/bin/env python3
"""Offline source-snapshot and optional integration safety checks."""
from pathlib import Path
import hashlib
import subprocess
import tempfile
import sys
import shutil
import json

ROOT=Path(__file__).resolve().parents[1]
EXPECTED={
    'config/quickshell/archruud-kairos-original/components/VolumeOSD.qml':'483e58c1e950cb53250594a46a798fca081a8ed0f17015c3ceb8834a3f30056b',
    'config/quickshell/archruud-kairos-original/scripts/archruud_brightness.py':'89cca6ca778059cf2e91ed59bc77c204781f30d31730619d5a3a61a9f1c9cf22',
    'config/quickshell/archruud-kairos-original/Scene.qml':'cf050c0d4830ec6c8cbe69e9174b4a6823c44be7c4e3a66d4ec7337dc4835ed0',
    'config/quickshell/archruud-kairos-original/shell.qml':'e789f5ed58e106fd8bedfb3d61b229918f1fa7beb541fb9ff4bc9a36f1e2b23d',
    'integration/archruud-power-menu-shell-v1.0.5.4.qml':'8d8cf4394ed94808ae5fa4b2faffc87097b0e8da52e25d13c4be66b9ec64f585',
    'integration/reference-power-shell-v1.0.1.qml':'65408563e5c8339ce5ee6864905d23ca3a858e7dfc622c9952bfde4b501652fe',
}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for rel,expected in EXPECTED.items():
    actual=sha(ROOT/rel)
    assert actual==expected,(rel,actual)
scene=(ROOT/'config/quickshell/archruud-kairos-original/Scene.qml').read_text()
assert scene.count('C.VolumeOSD {')==1
assert 'powerCompanionOpen: scene.powerCompanionOpen' in scene
shell=(ROOT/'config/quickshell/archruud-kairos-original/shell.qml').read_text()
assert 'target: "kairosPowerCompanion"' in shell
assert 'Scene { powerCompanionOpen: root.powerCompanionOpen }' in shell
v=(ROOT/'config/quickshell/archruud-kairos-original/components/VolumeOSD.qml').read_text()
assert 'powerCompanionOpen' in v and 'ddcutil' not in v # commands are delegated to Python backend
assert 'osd.sideCardHeight' in v
with tempfile.TemporaryDirectory(prefix='archruud-release-test-') as temp:
    home=Path(temp)
    target=home/'.config/quickshell/archruud-power-menu/shell.qml'
    target.parent.mkdir(parents=True)
    shutil.copy2(ROOT/'integration/reference-power-shell-v1.0.1.qml',target)
    def run(mode):
        return subprocess.run([sys.executable,str(ROOT/'install-power-companion.py'),mode,'--home',str(home)],capture_output=True,text=True)
    p=run('--dry-run');assert p.returncode==0,p.stderr
    assert sha(target)==EXPECTED['integration/reference-power-shell-v1.0.1.qml']
    p=run('--install');assert p.returncode==0,p.stderr
    assert sha(target)==EXPECTED['integration/archruud-power-menu-shell-v1.0.5.4.qml']
    p=run('--install');assert p.returncode==0 and 'already' in p.stdout.lower(),(p.stdout,p.stderr)
    p=run('--rollback');assert p.returncode==0,p.stderr
    assert sha(target)==EXPECTED['integration/reference-power-shell-v1.0.1.qml']
    target.write_text('custom Power Menu code\n')
    p=run('--install');assert p.returncode!=0
    assert target.read_text()=='custom Power Menu code\n'
print('PASS: source provenance, QML coordination, optional install, idempotence, rollback, safe stop.')
