#!/usr/bin/env python3
"""Optional reversible integration for the ARCHRUUD v1.0.1 Power Menu shell."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import sys
import tempfile
from datetime import datetime

BASE_HASH = '65408563e5c8339ce5ee6864905d23ca3a858e7dfc622c9952bfde4b501652fe'
NEW_HASH = '8d8cf4394ed94808ae5fa4b2faffc87097b0e8da52e25d13c4be66b9ec64f585'
ROOT = Path(__file__).resolve().parent
REL = Path('.config/quickshell/archruud-power-menu/shell.qml')
BACKUPS = Path('.local/state/archruud/backups/kairos-github-power-companion')

def digest(b): return hashlib.sha256(b).hexdigest()

def safe_file(path):
    if not path.is_file() or path.is_symlink():
        raise ValueError(f'Missing, non-regular or symlinked file: {path}')
    return path.read_bytes()

def atomic_write(path, data):
    with tempfile.NamedTemporaryFile(mode='wb', prefix=f'.{path.name}.archruud-', dir=path.parent, delete=False) as f:
        temp=Path(f.name)
        f.write(data); f.flush(); os.fsync(f.fileno())
    try:
        os.chmod(temp, path.stat().st_mode & 0o777)
        os.replace(temp,path)
    finally:
        if temp.exists(): temp.unlink()

def deploy(home, dry_run):
    target=home/REL
    current=safe_file(target)
    new=safe_file(ROOT/'integration/archruud-power-menu-shell-v1.0.5.4.qml')
    if digest(new)!=NEW_HASH:
        raise ValueError('Package integration source mismatch; release file edited.')
    if digest(current)==NEW_HASH:
        print('Power Menu companion is already installed; no changes.')
        return
    if digest(current)!=BASE_HASH:
        raise ValueError('Unknown Power Menu shell version. STOP: no files changed. Backup your custom shell for review.')
    print('Verified original Power Menu shell v1.0.1.')
    print('Only changes:',target)
    print('No changes to Power Menu actions, Hyprland Lua, Kairos or services.')
    if dry_run:
        print('DRY RUN: no files changed.')
        return
    base=home/BACKUPS
    folder=base/datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    folder.mkdir(parents=True, exist_ok=False)
    (folder/'shell.before.qml').write_bytes(current)
    (folder/'manifest.json').write_text(json.dumps({'path':str(REL),'before':BASE_HASH,'after':NEW_HASH},indent=2)+'\n')
    atomic_write(target,new)
    (base/'latest').write_text(str(folder.resolve())+'\n')
    print('Installed companion. Backup:',folder)
    print('Log out and back in to load the updated Power Menu.')

def rollback(home):
    target=home/REL
    now=safe_file(target)
    if digest(now)!=NEW_HASH:
        raise ValueError('Installed Power Menu has changed; STOP without rollback.')
    base=(home/BACKUPS).resolve()
    pointer=base/'latest'
    if not pointer.is_file():
        raise ValueError('No backup was created by this optional integrator.')
    folder=Path(pointer.read_text().strip()).resolve()
    if folder.parent!=base:
        raise ValueError('Unexpected backup pointer. STOP.')
    meta=json.loads((folder/'manifest.json').read_text())
    old=safe_file(folder/'shell.before.qml')
    if meta!={'path':str(REL),'before':BASE_HASH,'after':NEW_HASH} or digest(old)!=BASE_HASH:
        raise ValueError('Backup integrity check failed. STOP.')
    atomic_write(target,old)
    pointer.unlink()
    print('Original Power Menu shell restored. Log out/in once.')

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    args=parser.add_mutually_exclusive_group(required=True)
    args.add_argument('--dry-run',action='store_true')
    args.add_argument('--install',action='store_true')
    args.add_argument('--rollback',action='store_true')
    parser.add_argument('--home',type=Path,default=Path.home(),help=argparse.SUPPRESS)
    opt=parser.parse_args()
    if os.geteuid()==0 and opt.home==Path.home():
        print('STOP: run as your normal desktop user, not root.',file=sys.stderr); return 2
    try:
        if opt.rollback: rollback(opt.home)
        else: deploy(opt.home,opt.dry_run)
    except (OSError,UnicodeError,ValueError,KeyError) as exc:
        print('STOP:',exc,file=sys.stderr); return 2
    return 0
if __name__=='__main__': raise SystemExit(main())
