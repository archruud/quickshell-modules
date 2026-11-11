# ARCHRUUD Kairos v1.0.5.4 — release notes

## Provenance

This **complete snapshot** was composed only from the previously published
ARCHRUUD versioned packages. No on-device files were remotely edited.

1. `ARCHRUUD-Kairos-Original-v1.0.1-Audio-Notifications-Test.zip`:
   Kairos core, fixed audio service and notifications.
2. `ARCHRUUD-Kairos-Volume-OSD-v1.0.3-Interactive-Test.zip`:
   interactive volume component/volume-key script and Scene integration.
3. `ARCHRUUD-Kairos-Volume-Brightness-v1.0.5.1-Vertical-Fix.zip`:
   vertical Volume/Monitor Light cards and initial brightness backend.
4. `ARCHRUUD-Kairos-Side-Controls-v1.0.5.3-Monitor-Test.zip`:
   coordinated Power Menu IPC, revised brightness backend and cards.
5. `ARCHRUUD-Kairos-Side-Controls-v1.0.5.4-Alignment-Test.zip`:
   exact +20-QML-pixel vertical adjustment, no brightness/volume changes.

Version v1.0.5.2 was an intermediate alternative; the v1.0.5.3 source
explicitly accepts v1.0.5.1 and produces the same IPC-integrated result.

## Exact source checksums (SHA-256)

- VolumeOSD.qml: `483e58c1e950cb53250594a46a798fca081a8ed0f17015c3ceb8834a3f30056b`
- archruud_brightness.py: `89cca6ca778059cf2e91ed59bc77c204781f30d31730619d5a3a61a9f1c9cf22`
- Scene.qml: `cf050c0d4830ec6c8cbe69e9174b4a6823c44be7c4e3a66d4ec7337dc4835ed0`
- Kairos shell.qml: `e789f5ed58e106fd8bedfb3d61b229918f1fa7beb541fb9ff4bc9a36f1e2b23d`
- Companion-enabled Power shell: `8d8cf4394ed94808ae5fa4b2faffc87097b0e8da52e25d13c4be66b9ec64f585`

This package changes neither keyboard firmware nor the existing Hyprland bindings.
Monitor Light depends on an external monitor/brightness backend and does not
map to the Pulsar keyboard by itself. Whether the display physically dims
must be checked on the target machine.
