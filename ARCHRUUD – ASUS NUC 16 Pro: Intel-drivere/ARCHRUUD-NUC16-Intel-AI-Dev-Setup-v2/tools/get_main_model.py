#!/usr/bin/env python3
import json
import sys
from pathlib import Path


def main():
    data = json.loads(Path(sys.argv[1]).read_text(encoding='utf-8'))
    item = data.get('MAIN')
    if not item or not Path(item['path']).is_file():
        raise SystemExit('Main model is missing')
    print(item['path'])


if __name__ == '__main__':
    main()
