#!/sbin/sh
# liboemcrypto-disabler — install script
# Author: Abdul Moez
# https://github.com/Anonym0usWork1221/liboemcrypto-disabler

ui_print " "
ui_print "*******************************************"
ui_print "      liboemcrypto Disabler v1.0.0         "
ui_print "      by Abdul Moez                        "
ui_print "*******************************************"
ui_print " "
ui_print "- This module replaces:"
ui_print "    /vendor/lib64/liboemcrypto.so"
ui_print "    /vendor/lib/liboemcrypto.so"
ui_print "  with empty files via systemless overlay."
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
