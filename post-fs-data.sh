#!/system/bin/sh
# liboemcrypto-disabler — automatic boot-time overlay
# Author: Abdul Moez
# https://github.com/Anonym0usWork1221/liboemcrypto-disabler
#
# WHY THIS EXISTS
# ---------------
# The static overlay shipped in system/vendor/ neutralizes the standard
#   /vendor/lib/liboemcrypto.so   and   /vendor/lib64/liboemcrypto.so
# on devices whose root solution can overlay /vendor (most Magisk setups).
#
# But two things break that on real devices:
#   1. Several OEMs ship liboemcrypto.so OUTSIDE /vendor. The big one is the
#      "oplus" family — Oppo (ColorOS), OnePlus (OxygenOS 11/12/13/14) and
#      Realme (Realme UI) — which put it in /odm. Magisk's magic mount does
#      NOT officially map /odm, so the static overlay never touches it.
#   2. On KernelSU / APatch (OverlayFS backend) the module overlay can fail
#      to apply to /odm at all, depending on the kernel and filesystem.
#
# This script sidesteps BOTH problems automatically. A `mount -o bind` of an
# empty stub over the real library is a low-level, file-level overlay that:
#   * does NOT require the partition to be writable (works on read-only /odm),
#   * does NOT depend on magic mount / OverlayFS mapping the partition,
#   * runs identically on Magisk, KernelSU and APatch (all execute post-fs-data.sh),
#   * is fully systemless & reversible — the mount vanishes on the next reboot
#     once the module is disabled or removed.
#
# The result: OnePlus/Oppo/Realme and other /odm devices are handled with NO
# extra modules and NO manual mounting. (A manual fallback is documented in the
# README for the rare KernelSU setup where even this does not stick.)

MODDIR=${0%/*}
LOG_TAG=liboemcrypto-disabler

# Every known location of liboemcrypto.so across OEMs and layouts, most-common
# first. /vendor is included too (not just the static overlay) so this script
# alone is sufficient on any root solution / mount backend.
TARGETS="
/vendor/lib64/liboemcrypto.so
/vendor/lib/liboemcrypto.so
/odm/lib64/liboemcrypto.so
/odm/lib/liboemcrypto.so
/vendor/odm/lib64/liboemcrypto.so
/vendor/odm/lib/liboemcrypto.so
/system/odm/lib64/liboemcrypto.so
/system/odm/lib/liboemcrypto.so
/system/vendor/lib64/liboemcrypto.so
/system/vendor/lib/liboemcrypto.so
/product/lib64/liboemcrypto.so
/product/lib/liboemcrypto.so
/system_ext/lib64/liboemcrypto.so
/system_ext/lib/liboemcrypto.so
/my_product/lib64/liboemcrypto.so
/my_product/lib/liboemcrypto.so
"

count=0
i=0
for t in $TARGETS; do
    # Act only on a REAL library: a regular file with non-zero size.
    # A 0-byte file is already neutralized (by the static /vendor overlay,
    # an OverlayFS module, or a previous pass) — leave it alone. This makes
    # the script order-independent and safe to run alongside any overlay.
    [ -f "$t" ] && [ -s "$t" ] || continue

    src="$MODDIR/.empty_$i"
    : > "$src"

    # Give the stub the same SELinux context as the original library so the
    # DRM loader opens it exactly as it would the real file — it then fails
    # to load the empty ELF and Android falls back to stock Widevine.
    ctx=$(stat -c %C "$t" 2>/dev/null)
    [ -n "$ctx" ] && chcon "$ctx" "$src" 2>/dev/null

    if mount -o bind "$src" "$t" 2>/dev/null; then
        log -t "$LOG_TAG" "neutralized $t"
        count=$((count + 1))
    else
        rm -f "$src"
        log -t "$LOG_TAG" "FAILED to bind-mount over $t"
    fi

    i=$((i + 1))
done

log -t "$LOG_TAG" "done: neutralized $count copy/copies of liboemcrypto.so"
