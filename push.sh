#!/bin/bash

while getopts ":-:" o; do
    case "${OPTARG}" in
        reboot)
            REBOOT=1
            ;;
        use_remount)
            USE_REMOUNT=1
            ;;
    esac
done

adb wait-for-device root
adb wait-for-device shell "mount | grep -q ^tmpfs\ on\ /system && umount -fl /system/{bin,etc} 2>/dev/null"
if [[ "${USE_REMOUNT}" = "1" ]]; then
    adb wait-for-device shell "remount"
elif [[ "$(adb shell stat -f --format %a /system)" = "0" ]]; then
    echo "ERROR: /system has 0 available blocks, consider using --use_remount"
    exit -1
else
    adb wait-for-device shell "stat --format %m /system | xargs mount -o rw,remount"
fi
adb wait-for-device push 88-gsans.sh /system/addon.d/
adb wait-for-device push GoogleSans-Italic.ttf /system/fonts/
adb wait-for-device push GoogleSans-Regular.ttf /system/fonts/
adb wait-for-device push GoogleSansFlex-Regular.ttf /system/fonts/
adb wait-for-device push font_fallback.xml /system/etc/
adb wait-for-device push fonts.xml /system/etc/

if [[ "${REBOOT}" = "1" ]]; then
    adb wait-for-device reboot
fi
