# GitHub-ready Kairos package

Place this extracted folder in your `quickshell-modules` repository (for example `modules/archruud-kairos-original/`) and commit as source code, **not only as a ZIP**.

This stable package includes all Quickshell QML and Python files from the visually tested v0.4.2 named-places package, an independent Hyprland Lua import, previewable/autobacked startup installer and rollback, dependency report, and reboot checklist. No source font binaries are included: Arch packages supply the icons.

Example repository workflow:

```bash
git status
git add modules/archruud-kairos-original
git commit -m "Add ARCHRUUD Kairos Original v1.0 Stable"
git push
```

Do not overwrite a working local config directly with `git` without a backup. The package's install scripts make backups on local install; they are not a full system backup.
