#!/usr/bin/env python3
"""Lightweight package consistency checks, not a live Wayland integration test."""
import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
QML = (ROOT / 'config/quickshell/archruud-open-software/shell.qml').read_text()


def test_single_click():
    assert 'root.activate(modelData)' in QML
    assert 'onDoubleClicked:' not in QML
    assert 'onClicked: {' in QML


def test_power_menu_style():
    assert 'implicitWidth: 142' in QML
    assert 'property int rowHeight: 73' in QML
    assert 'radius: 13' in QML
    assert '#080F1B' in QML and '#38B7FF' in QML
    assert 'c.bezierCurveTo(4, 27, 13, top, 40, top)' in QML
    assert 'ARCHRUUD OPEN' not in QML
    assert 'SUPER+O · click / arrows · Enter · Esc' not in QML
    assert 'Button {' not in QML


def test_dynamic_list():
    assert 'ListView {' in QML
    assert 'GridView {' not in QML
    assert 'model: root.windows' in QML
    assert 'implicitHeight: root.panelHeight(screen.height)' in QML
    assert '94 + count * rowHeight + (count - 1) * rowSpacing' in QML
    assert 'ToolTip.text:' in QML


def test_existing_backend():
    scripts = ROOT / 'config/quickshell/archruud-open-software/scripts'
    for filename in ('list-windows.py', 'focus-window.py'):
        ast.parse((scripts / filename).read_text())
    assert 'hl.dsp.focus(' in (scripts / 'focus-window.py').read_text()
    assert 'openSoftware' in QML


if __name__ == '__main__':
    test_single_click()
    test_power_menu_style()
    test_dynamic_list()
    test_existing_backend()
    print('Static release checks passed (live visual testing still required).')
