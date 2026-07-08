# Changelog

All notable changes to this project will be documented in this file.

## [v2.0.1] - 2026-07-08

### Changed
- `post-fs-data.sh` now also covers `/vendor/lib{,64}` (not just the non-`/vendor`
  paths), making it a self-healing fallback for the rare KernelSU / OverlayFS
  setup where the static overlay does not apply. `/vendor` and `/odm` are now
  handled by one uniform, root-solution-independent bind mount. Confirmed
  working on **OnePlus 11R (OxygenOS 14)**.

### Added
- README: dedicated **"Using on OnePlus / Oppo / Realme (`/odm`) devices"** guide
  with verification steps and a KernelSU fallback (switch to Magic Mount, or use
  [HuskyDG's `magic_overlayfs`](https://github.com/HuskyDG/magic_overlayfs) and
  add `/odm`) for setups where the automatic overlay does not stick.
- Clearer `post-fs-data.sh` logging (per-file `neutralized` / `FAILED` lines plus
  a final count), visible via `logcat -s liboemcrypto-disabler`.

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
