# Power Menu integration: one hover trigger, two companion cards

The user-tested layout pairs two narrow, vertically stacked controls immediately
**left of** the standalone ARCHRUUD Power Menu. Volume is above Monitor Light.
Both cards open when the existing Power Menu opens (right-side mouse trigger or
`SUPER+P`), then close with it. The volume knob can also show them briefly
without opening the Power Menu.

Power Menu is a **different Quickshell module**. To avoid bundling the entire
separate module or damaging its six actions, this release contains only an
optional prevalidated shell replacement.

Expected installed file:
`~/.config/quickshell/archruud-power-menu/shell.qml`

```bash
python3 install-power-companion.py --dry-run
python3 install-power-companion.py --install
```

Safety behavior:
- Original published v1.0.1 Power shell => installs the integration, makes a backup.
- Matching already-integrated shell => reports already installed, no changes.
- Any other/missing/symlinked shell => STOP, no changes.
- No other Power Menu files, scripts, services, Hyprland imports or startup
  configuration are edited.

The Power Menu's own `scripts/power-action.sh` and optional screen lock setup
remain the responsibility of the Power Menu package.

Rollback, only after installation by this helper:

```bash
python3 install-power-companion.py --rollback
```

After installing or reverting, log out and back in; don't launch duplicate
Quickshell instances. Live physical monitor and hover behavior must be checked
in the desktop session.
