#!/system/bin/sh
# liboemcrypto-disabler — boot-time overlay for non-/vendor partitions
# Author: Abdul Moez
# https://github.com/Anonym0usWork1221/liboemcrypto-disabler
#
# The static overlay shipped in system/vendor/ already neutralizes
#   /vendor/lib/liboemcrypto.so   and   /vendor/lib64/liboemcrypto.so
# through the standard Magisk / KernelSU / APatch mount.
#
# Several OEMs ship liboemcrypto.so OUTSIDE /vendor, where that overlay
# cannot reach it. The most common case is the "oplus" family — Oppo
# (ColorOS), OnePlus (OxygenOS 11/12+) and Realme (Realme UI) — which
# place the library in /odm instead. Magisk's magic mount only officially
# maps system/vendor, system/product and system/system_ext, so /odm needs
# an explicit bind mount.
#
# This script bind-mounts an empty stub over any such copy on every boot.
# Because it is a runtime mount, it is fully systemless and reversible:
# disable or remove the module and the original library returns on the
# next reboot.

MODDIR=${0%/*}
LOG_TAG=liboemcrypto-disabler

# Every known non-/vendor location of liboemcrypto.so across OEMs.
# /vendor/lib and /vendor/lib64 are intentionally omitted here — the
# static system/vendor overlay already owns those two paths.
TARGETS="
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

i=0
for t in $TARGETS; do
    # Act only on a REAL library: a regular file with non-zero size.
    # A 0-byte file is already neutralized (e.g. by the /vendor overlay
    # or a previous run) — leave it alone.
    [ -f "$t" ] && [ -s "$t" ] || continue

    src="$MODDIR/.empty_$i"
    : > "$src"

    # Give the stub the same SELinux context as the original library so
    # the DRM loader can open it exactly as it would the real file (it
    # then fails to load the empty ELF and falls back to stock Widevine).
    ctx=$(stat -c %C "$t" 2>/dev/null)
    [ -n "$ctx" ] && chcon "$ctx" "$src" 2>/dev/null

    if mount -o bind "$src" "$t" 2>/dev/null; then
        log -t "$LOG_TAG" "overlaid empty stub onto $t"
    else
        rm -f "$src"
    fi

    i=$((i + 1))
done
