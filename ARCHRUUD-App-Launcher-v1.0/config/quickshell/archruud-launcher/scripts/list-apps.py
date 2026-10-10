#!/usr/bin/env python3
"""List desktop applications without changing the user's system."""
import configparser
import json
import os
from pathlib import Path

home = Path.home()
roots = [home / ".local/share/applications"]
roots += [Path(x) / "applications" for x in os.environ.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share").split(":") if x]
seen = set()
apps = []
for directory in roots:
    if not directory.is_dir():
        continue
    for file in sorted(directory.rglob("*.desktop")):
        key = str(file.relative_to(directory))
        if key in seen:
            continue
        seen.add(key)
        cp = configparser.ConfigParser(interpolation=None, strict=False)
        cp.optionxform = str
        try:
            cp.read(file, encoding="utf-8")
            entry = cp["Desktop Entry"]
            if entry.get("Type", "Application") != "Application":
                continue
            if entry.get("Hidden", "false").lower() == "true" or entry.get("NoDisplay", "false").lower() == "true":
                continue
            desktop = os.environ.get("XDG_CURRENT_DESKTOP", "Hyprland").lower().split(":")
            only = [x.lower() for x in entry.get("OnlyShowIn", "").split(";") if x]
            not_in = [x.lower() for x in entry.get("NotShowIn", "").split(";") if x]
            if only and not any(x in only for x in desktop):
                continue
            if any(x in not_in for x in desktop):
                continue
            if not entry.get("Exec", "").strip() and not entry.get("DBusActivatable", "false").lower() == "true":
                continue
            name = entry.get("Name", "").strip()
            if name:
                apps.append({"name": name, "icon": entry.get("Icon", "application-x-executable"), "path": str(file)})
        except (OSError, UnicodeError, configparser.Error, KeyError):
            continue
apps.sort(key=lambda a: a["name"].casefold())
print(json.dumps(apps, ensure_ascii=False))
