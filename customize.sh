#!/sbin/sh
# liboemcrypto-disabler — install script
# Author: Abdul Moez
# https://github.com/Anonym0usWork1221/liboemcrypto-disabler

ui_print " "
ui_print "*******************************************"
ui_print "      liboemcrypto Disabler v2.0.1         "
ui_print "      by Abdul Moez                        "
ui_print "*******************************************"
ui_print " "
ui_print "- This module neutralizes the OEM Widevine"
ui_print "  library (liboemcrypto.so) wherever your"
ui_print "  device stores it, via a systemless overlay."
ui_print " "

# --- Detect where liboemcrypto.so lives on THIS device --------------------
ui_print "- Scanning for liboemcrypto.so ..."
FOUND=""
ODM_FOUND=""
for d in \
    /vendor/lib64 /vendor/lib \
    /odm/lib64 /odm/lib \
    /vendor/odm/lib64 /vendor/odm/lib \
    /system/odm/lib64 /system/odm/lib \
    /system/vendor/lib64 /system/vendor/lib \
    /product/lib64 /product/lib \
    /system_ext/lib64 /system_ext/lib \
    /my_product/lib64 /my_product/lib
do
    if [ -f "$d/liboemcrypto.so" ]; then
        ui_print "    [+] found: $d/liboemcrypto.so"
        FOUND="yes"
        case "$d" in
            /vendor/lib*) : ;;          # handled by the static /vendor overlay
            *) ODM_FOUND="yes" ;;       # handled at boot by post-fs-data.sh
        esac
    fi
done

if [ -z "$FOUND" ]; then
    ui_print " "
    ui_print "  [!] liboemcrypto.so was not found in any known"
    ui_print "      location. The module is still installed and"
    ui_print "      will cover the standard /vendor path, but it"
    ui_print "      may have no effect on this device."
    ui_print "      Please open an issue and include the output of:"
    ui_print "        find /vendor /odm /product /system_ext \\"
    ui_print "             -name liboemcrypto.so 2>/dev/null"
else
    ui_print " "
    ui_print "  Standard /vendor copies are neutralized by the"
    ui_print "  systemless overlay."
    if [ -n "$ODM_FOUND" ]; then
        ui_print "  Non-standard copies (e.g. /odm on OnePlus,"
        ui_print "  Oppo and Realme) are neutralized at every"
        ui_print "  boot by post-fs-data.sh."
    fi
fi
ui_print " "

ui_print "- WHAT IT FIXES:"
ui_print "    > Crunchyroll EXO-1004 error"
ui_print "    > 'We're having trouble connecting' on video"
ui_print "    > Streaming apps detecting root via Widevine"
ui_print "    > DRM playback failures on rooted devices"
ui_print " "
ui_print "- HOW IT WORKS:"
ui_print "    By disabling OEM Widevine, the system falls back"
ui_print "    to Google's stock Widevine, which does not"
ui_print "    aggressively detect root."
ui_print " "
ui_print "- TRADE-OFF:"
ui_print "    Widevine may drop from L1 to L3, meaning some"
ui_print "    services (Netflix, Disney+) may serve SD instead"
ui_print "    of HD. Crunchyroll, HBO Max, etc. are unaffected."
ui_print " "
ui_print "- This is fully reversible. Disable or remove the"
ui_print "  module to restore the original library."
ui_print " "

set_perm_recursive $MODPATH 0 0 0755 0644

ui_print "- Files installed. Reboot required."
ui_print " "
