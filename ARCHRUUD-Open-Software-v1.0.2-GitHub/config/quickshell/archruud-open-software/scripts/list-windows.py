#!/usr/bin/env python3
"""Read actual Hyprland clients, without changing windows or workspaces."""
import json, subprocess, sys
try:
    result = subprocess.run(["hyprctl", "-j", "clients"], capture_output=True, text=True, timeout=4, check=True)
    clients = json.loads(result.stdout)
    output = []
    for client in clients:
        address = client.get("address", "")
        workspace = client.get("workspace") or {}
        wid = workspace.get("id", -1)
        if not address or not isinstance(wid, int) or wid == -1:
            continue
        title = str(client.get("title") or "Untitled window")
        klass = str(client.get("class") or client.get("initialClass") or "application-x-executable")
        output.append({"address": address, "name": klass, "title": title, "workspace": wid,
                       "workspaceName": str(workspace.get("name") or wid), "icon": klass.lower()})
    output.sort(key=lambda c: (c["workspace"], c["name"].lower(), c["title"].lower()))
    print(json.dumps(output, ensure_ascii=False))
except Exception as exc:
    print(str(exc), file=sys.stderr)
    print("[]")
    sys.exit(1)
