# Changelog

## v1.0.6.2 Stable — R03 (2026-11-25)

- Captured the **actual running** Power Menu source after the owner confirmed everything works after reboot.
- Preserved its single, unified Power / Volume / Monitor Light panel, common hover handling and timer without rewriting the source.
- Included the existing Kairos `Scene.qml` that disables the redundant legacy Volume OSD instantiation.
- Added public GitHub documentation, source SHA-256 hashes, dependency notes, safe upgrade and rollback scripts.
- Deliberately excluded the other Quickshell modules, recorder, private locations and runtime state.
- No untested UI changes; this is a source/publishing snapshot, not a new visual update.
