# liboemcrypto Disabler

> A Magisk / KernelSU module that disables OEM Widevine to bypass root detection in DRM-protected streaming apps.

[![GitHub release](https://img.shields.io/github/v/release/Anonym0usWork1221/liboemcrypto-disabler?style=flat-square)](https://github.com/Anonym0usWork1221/liboemcrypto-disabler/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
[![Magisk](https://img.shields.io/badge/Magisk-v20.4%2B-00B39B?style=flat-square)](https://github.com/topjohnwu/Magisk)
[![KernelSU](https://img.shields.io/badge/KernelSU-supported-red?style=flat-square)](https://github.com/tiann/KernelSU)
[![Android](https://img.shields.io/badge/Android-10%2B-3DDC84?style=flat-square)](https://www.android.com/)

---

## What it does

This module replaces `liboemcrypto.so` with an empty file using a systemless overlay. With the OEM Widevine library disabled, Android's DRM framework falls back to **Google's stock Widevine implementation**, which doesn't perform aggressive root detection.

The result: streaming apps that previously refused to play video on rooted devices start working.

Different OEMs ship `liboemcrypto.so` in different partitions, and the module handles all of them:

- **`/vendor/lib{,64}`** (standard AOSP/Qualcomm layout — most brands) is neutralized by a static systemless overlay.
- **`/odm/lib{,64}`** (OnePlus, Oppo, Realme — ColorOS / OxygenOS 11+ / Realme UI) and other non-`/vendor` locations (`/vendor/odm`, `/system/vendor`, `/product`, `/system_ext`, `/my_product`) are neutralized at every boot by a bind mount in `post-fs-data.sh`.

> **OnePlus / Oppo / Realme note:** on these devices `liboemcrypto.so` lives in
> `/odm/lib64/` (the ODM partition) instead of `/vendor/lib64/`. Magisk's magic
> mount does not officially map `/odm`, so **v2.0.0+** covers it with a boot-time
> bind mount that works identically on Magisk, KernelSU and APatch.

## Problems it fixes

- **Crunchyroll error EXO-1004** ("We're having trouble connecting")
- **"Unable to play video" / DRM errors** in various streaming apps on rooted devices
- **Playback failures** after a successful login (UI works but video doesn't)
- **Root detection** at the Widevine level (different from Play Integrity / SafetyNet)
- **Custom ROM playback issues** where OEM Widevine HAL is broken or missing

## Apps known to be fixed

| App | Status | Notes |
|---|---|---|
| Crunchyroll | ✅ Fixed | EXO-1004 resolved |
| HBO Max / Max | ✅ Works | No quality change |
| Hulu | ✅ Works | No quality change |
| Paramount+ | ✅ Works | |
| Peacock | ✅ Works | |
| Apple TV+ | ✅ Works | |

## Apps that may downgrade

| App | Behavior |
|---|---|
| Netflix | Plays in SD instead of HD (requires hardware Widevine L1 for HD) |
| Disney+ | May serve SD |
| Amazon Prime Video | May serve SD |
| DAZN | May drop to lower quality |

> **Why:** Disabling OEM Widevine often drops the hardware security level from L1 to L3. Some services strictly enforce L1 for HD/4K streams. If you need HD on these apps, disable this module before watching, then re-enable.

## How it works

```
┌─────────────────────────┐         ┌─────────────────────────┐
│   Streaming App         │         │   Streaming App         │
│   (Crunchyroll, etc.)   │         │   (Crunchyroll, etc.)   │
└───────────┬─────────────┘         └───────────┬─────────────┘
            │                                   │
            ▼                                   ▼
┌─────────────────────────┐         ┌─────────────────────────┐
│   Widevine CDM          │         │   Widevine CDM          │
│   (Android Framework)   │         │   (Android Framework)   │
└───────────┬─────────────┘         └───────────┬─────────────┘
            │                                   │
            ▼                                   ▼
┌─────────────────────────┐         ┌─────────────────────────┐
│   OEM liboemcrypto.so   │         │   ✗ (empty / disabled)  │
│   (detects root → fails)│         │                         │
└─────────────────────────┘         └───────────┬─────────────┘
                                                 │ fallback
                                                 ▼
                                    ┌─────────────────────────┐
                                    │  Google's stock Widevine│
                                    │  (no root detection)    │
                                    └─────────────────────────┘
        BEFORE                              AFTER
```

## Installation

### Method 1: Magisk

1. Download the latest [release zip](https://github.com/Anonym0usWork1221/liboemcrypto-disabler/releases/latest)
2. Open **Magisk** → **Modules** → **Install from storage**
3. Select the downloaded zip
4. Reboot
5. Force-stop and clear data on your streaming app
6. Open the app and test playback

### Method 2: KernelSU

1. Download the latest [release zip](https://github.com/Anonym0usWork1221/liboemcrypto-disabler/releases/latest)
2. Open **KernelSU Manager** → **Modules** → **Install**
3. Select the downloaded zip
4. Reboot
5. Force-stop and clear data on your streaming app

### Method 3: APatch

1. Download the latest [release zip](https://github.com/Anonym0usWork1221/liboemcrypto-disabler/releases/latest)
2. Open **APatch** → **APModule** → **Install from storage**
3. Reboot

## Using on OnePlus / Oppo / Realme (`/odm` devices)

On the **oplus family** — OnePlus (OxygenOS 11/12/13/14), Oppo (ColorOS) and
Realme (Realme UI) — `liboemcrypto.so` lives in **`/odm/lib64/`**, not
`/vendor/lib64/`. This is why v1.x had no effect on these phones.

**As of v2.0.0 this is handled automatically.** On boot, the module's
`post-fs-data.sh` bind-mounts an empty stub over the real library wherever it
finds it (including `/odm`). This works on **Magisk, KernelSU and APatch**
without any extra modules or manual mounting.

> ✅ **Confirmed working — OnePlus 11R, OxygenOS 14.**
> A user reported from the XDA
> [EXO-1004 thread](https://xdaforums.com/t/fixed-error-exo-1004-with-the-crunchyroll-app-and-system-ro2rw-tutoral.4690132/):
> *"Yep, it's working now."* They noted that on **KernelSU** they had to enable
> **Magic Mount** and add the `/odm` mount manually — the automatic bind mount in
> v2.0.0 is designed to remove that manual step.

### Steps

1. Flash the zip via Magisk / KernelSU / APatch (any method above).
2. **Reboot.**
3. Verify the library is now empty:
   ```bash
   su
   ls -la /odm/lib64/liboemcrypto.so     # size should be 0
   logcat -d -s liboemcrypto-disabler    # should log "neutralized /odm/lib64/liboemcrypto.so"
   ```
4. Force-stop and **clear data** on your streaming app, then test playback.

### If it still doesn't take effect on KernelSU

A small number of KernelSU setups (certain kernels / `f2fs` `/odm`) won't let a
module touch `/odm` through the default OverlayFS backend. If the automatic fix
above doesn't stick, use one of these fallbacks:

- **Switch KernelSU's mount backend to Magic Mount** (available in recent
  KernelSU / KernelSU-Next builds) and reboot. Magic Mount applies module
  overlays the Magisk way, which lets `/odm` be replaced.
- **Or install [HuskyDG's `magic_overlayfs`](https://github.com/HuskyDG/magic_overlayfs)**,
  make `/odm` read-write (add `/odm` in its mount list / WebUI), reboot, then
  reflash this module.

If you had to use a fallback, please
[open an issue](https://github.com/Anonym0usWork1221/liboemcrypto-disabler/issues)
with your device model, ROM version and root solution so the automatic path can
be improved — include the output of
`find /vendor /odm /product /system_ext -name liboemcrypto.so 2>/dev/null`.

## Verification

After reboot, confirm the module is active:

```bash
su
# Standard devices:
ls -la /vendor/lib64/liboemcrypto.so
# OnePlus / Oppo / Realme:
ls -la /odm/lib64/liboemcrypto.so
# Size should be 0 bytes on whichever path your device uses

ls /data/adb/modules/liboemcrypto_disabler/
# Should show module files

# Confirm the /odm bind mount is active (OnePlus/Oppo/Realme):
logcat -d -s liboemcrypto-disabler
# Should show "overlaid empty stub onto /odm/lib64/liboemcrypto.so"
```

You can also install [**DRM Info**](https://play.google.com/store/apps/details?id=com.androidcentral.app.drminfo) from the Play Store. Before/after comparison:

- **Before module:** Widevine Security Level → `L1`
- **After module:** Widevine Security Level → `L3` (expected — this is the fallback path)

This level change is expected and is what enables Crunchyroll-style apps to play.

## Compatibility

| Component | Compatibility |
|---|---|
| **Android** | 10, 11, 12, 13, 14, 15, 16+ |
| **Architecture** | arm64-v8a, armeabi-v7a |
| **Root solutions** | Magisk v20.4+, KernelSU, APatch |
| **Partitions** | `/vendor`, `/odm`, `/vendor/odm`, `/system/vendor`, `/product`, `/system_ext`, `/my_product` (lib + lib64) |
| **OEMs** | Standard `/vendor` brands (Samsung, Xiaomi, Sony, Pixel, Motorola, Asus, Nothing, Vivo) **and** `/odm` brands (OnePlus, Oppo, Realme) |

Tested on:
- Snapdragon 8 Gen 2 (RedMagic 8S Pro / NX729J)
- Snapdragon 8 Gen 3 devices
- MediaTek Dimensity series

> **OnePlus / Oppo / Realme (`/odm`) support landed in v2.0.0**, confirmed
> working on **OnePlus 11R (OxygenOS 14)**. More `/odm` device reports are
> welcome — if it works (or doesn't) on yours, please open an issue with the
> output of `find /vendor /odm /product /system_ext -name liboemcrypto.so 2>/dev/null`.

If your device works, please open an issue with the `device-confirmed` label so others know.

## Pros and Cons

### Pros
- ✅ Fixes the most common DRM-related playback failure on rooted devices
- ✅ Systemless — no permanent modifications to `/vendor`
- ✅ One-tap reversible: disable or remove the module
- ✅ No keyboxes, no fingerprints to maintain
- ✅ Survives OTA updates (just re-flash if `/vendor` changes)
- ✅ Auto-update support via Magisk/KSU
- ✅ Works alongside Play Integrity Fix, Tricky Store, Shamiko

### Cons
- ⚠️ Drops Widevine to L3 → HD streaming breaks on Netflix, Disney+, etc.
- ⚠️ Not a fix for *every* DRM issue (some apps check beyond Widevine)
- ⚠️ Doesn't bypass Play Integrity API — pair with PIF if needed
- ⚠️ A rare custom ROM may relocate the `.so` to an unlisted path — if so, open an issue with the `find` output and it can be added

## Toggling

To temporarily disable (e.g., to watch Netflix in HD):

1. Magisk → Modules → toggle off `liboemcrypto_disabler`
2. Reboot
3. Watch Netflix
4. Toggle back on, reboot, return to using Crunchyroll

## Recommended companion modules

This module fixes Widevine-level root detection. For full streaming-on-root coverage, combine with:

- **[Play Integrity Fix (Fork)](https://github.com/osm0sis/PlayIntegrityFork)** — passes Play Integrity DEVICE verdict
- **[Tricky Store](https://github.com/5ec1cff/TrickyStore)** — keystore attestation spoofing (with a valid keybox)
- **[Shamiko](https://github.com/LSPosed/LSPosed.github.io/releases)** — hides root from apps in the DenyList

## FAQ

**Q: Will this affect banking apps?**
A: Only if the banking app relies on Widevine for root detection (rare). Most banking apps use Play Integrity / SafetyNet, which this module doesn't touch. Pair with PIF for those.

**Q: Does it work on KernelSU?**
A: Yes. Module format is compatible with Magisk, KSU, and APatch.

**Q: Why is my Widevine showing L3 now?**
A: That's expected. Disabling OEM Widevine forces the fallback to Google's software-based path, which reports as L3. This is exactly what makes Crunchyroll work — L1 was the path that detected root.

**Q: Is this safe?**
A: Yes. The module is systemless — nothing on your physical `/vendor` partition is modified. Disabling the module instantly restores the original library. Safe to flash, safe to remove.

**Q: Will Google detect this?**
A: Disabling `liboemcrypto.so` is a local change. It doesn't communicate with Google, so there's nothing for Google to detect server-side. However, your Play Integrity verdict won't change — for that, use PIF.

**Q: Can I cherry-pick — only disable for 64-bit?**
A: Yes. Edit the module to remove `system/vendor/lib/liboemcrypto.so` if you only run 64-bit apps. The full bundle is safest.

**Q: My app still doesn't work.**
A: Try clearing the app's data, not just cache. Some apps cache DRM session tokens that need to be reset. If still broken, the issue isn't Widevine-level — check Play Integrity status with [Play Integrity API Checker](https://play.google.com/store/apps/details?id=gr.nikolasspyr.integritycheck).

## Uninstall

- **Magisk:** Modules → tap Remove on `liboemcrypto_disabler` → reboot
- **KernelSU:** Modules → uninstall → reboot
- **APatch:** APModule → uninstall → reboot

Original `liboemcrypto.so` restored on next boot.

## Credits

- Original fix discovery: XDA community ([thread](https://xdaforums.com/t/fixed-error-exo-1004-with-the-crunchyroll-app-and-system-ro2rw-tutoral.4690132/))
- Magisk module packaging: **Abdul Moez** ([@Anonym0usWork1221](https://github.com/Anonym0usWork1221))
- Magisk module framework: [topjohnwu](https://github.com/topjohnwu/Magisk)

## License

MIT — see [LICENSE](LICENSE) for full text.

## Disclaimer

This module is provided as-is for educational and personal use. The author is not responsible for any DRM violations, account bans, or service disruptions resulting from its use. You are responsible for complying with the terms of service of any streaming platform you use. Pirated content is not condoned.

---

If this saved you hours of keybox-hunting and ROM-flashing, consider starring the repo ⭐
