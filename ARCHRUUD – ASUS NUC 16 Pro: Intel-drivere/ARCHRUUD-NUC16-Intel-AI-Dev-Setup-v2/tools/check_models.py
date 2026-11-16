#!/usr/bin/env python3
"""Locate chosen GGUF models without downloads or modifications."""
import json
import os
from pathlib import Path
import re
import sys


def classify(name: str):
    s = name.lower()
    if not s.endswith('.gguf'):
        return None
    q4 = re.search(r'q4[_\-.]?k[_\-.]?m', s) is not None
    q8 = re.search(r'q8[_\-.]?0', s) is not None
    if 'mmproj' in s and re.search(r'qwen3[-_]?vl.*30b.*a3b', s) and 'f16' in s:
        return 'VISION_PROJECTOR'
    if re.search(r'qwen3[-_]?vl.*30b.*a3b', s) and q4 and 'mmproj' not in s:
        return 'VISION'
    if 'qwen3' in s and 'embedding' in s and '4b' in s and q8:
        return 'EMBEDDING'
    if re.search(r'qwen3[-_]?coder.*30b.*a3b', s) and q4:
        return 'CODER'
    if re.search(r'qwen3[-_]?30b[-_]?a3b', s) and q4 and not any(x in s for x in ('coder', 'vl', 'embedding')):
        return 'MAIN'
    return None


def main():
    if len(sys.argv) < 3:
        raise SystemExit('usage: check_models.py output.json root [root...]')
    out = Path(sys.argv[1])
    roots = [Path(p).expanduser() for p in sys.argv[2:]]
    expected = ('MAIN', 'CODER', 'EMBEDDING', 'VISION', 'VISION_PROJECTOR')
    found = {}
    print('SØKEMAPPER:')
    for root in roots:
        print(' -', root, 'FINNES' if root.is_dir() else 'FINNES IKKE')
        if not root.is_dir():
            continue
        for dirname, dirs, filenames in os.walk(root, followlinks=False):
            current = Path(dirname)
            try:
                depth = len(current.relative_to(root).parts)
            except ValueError:
                depth = 0
            if depth >= 4:
                dirs[:] = []
            for name in filenames:
                kind = classify(name)
                if kind is None:
                    continue
                path = current / name
                if not path.is_file():
                    continue
                size = path.stat().st_size
                if size < 100 * 1024 * 1024:
                    print('[FOR LITEN FIL / MULIG UFERDIG]', path, size)
                    continue
                old = found.get(kind)
                if old is None or size > old['bytes']:
                    found[kind] = {'path': str(path.resolve()), 'bytes': size}
    print('\nMODELLSTATUS:')
    for kind in expected:
        item = found.get(kind)
        if item:
            print(f'[OK] {kind}: {item["path"]} ({item["bytes"] / 1024**3:.2f} GiB)')
        else:
            print(f'[MANGLER] {kind}')
    out.write_text(json.dumps(found, indent=2, ensure_ascii=False), encoding='utf-8')
    print(f'\nMODEL_FOUND={len(found)}')
    print(f'MODEL_REQUIRED={len(expected)}')
    if len(found) != len(expected):
        print('MODEL_CHECK_PASS=0')
        return 2
    print('MODEL_CHECK_PASS=1')
    return 0


if __name__ == '__main__':
    sys.exit(main())
