# Changelog

All notable changes to this project will be documented in this file.

## [v2.0.0] - 2026-07-08

### Added
- **Multi-OEM partition support.** The module now neutralizes `liboemcrypto.so`
  wherever the device stores it, not just under `/vendor`:
  - `/odm/lib{,64}` — **OnePlus, Oppo, Realme** (ColorOS / OxygenOS 11+ / Realme UI)
  - `/vendor/odm/lib{,64}`, `/system/odm/lib{,64}`
  - `/system/vendor/lib{,64}` — legacy pre-Treble layout
  - `/product/lib{,64}`, `/system_ext/lib{,64}`, `/my_product/lib{,64}` — fallbacks
- `post-fs-data.sh` boot script that bind-mounts an empty stub (with the
  original SELinux context) over any `liboemcrypto.so` outside `/vendor`.
  This is the mechanism-independent path that works on Magisk, KernelSU and
  APatch even though magic mount does not officially map `/odm`.
- Install-time device scan: `customize.sh` now reports exactly where
  `liboemcrypto.so` was found and how each copy will be handled.

### Fixed
- Module had no effect on **OnePlus / Oppo / Realme** devices, where
  `liboemcrypto.so` lives in `/odm` instead of `/vendor`.

### Changed
- `/vendor/lib{,64}` copies continue to be handled by the existing static
  systemless overlay (unchanged behaviour on standard devices).

## [v1.0.0] - 2026-05-12

### Added
- Initial release
- Disables `/vendor/lib64/liboemcrypto.so` (64-bit)
- Disables `/vendor/lib/liboemcrypto.so` (32-bit)
- Magisk, KernelSU, and APatch compatibility
- Auto-update support via `updateJson`
- Comprehensive install messages explaining the fix and tradeoffs
