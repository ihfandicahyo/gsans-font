#!/usr/bin/env pwsh

param(
    [switch]$reboot = $false,
    [switch]$use_remount = $false
)

adb wait-for-device root
adb wait-for-device shell "mount | grep -q ^tmpfs\ on\ /system && umount -fl /system/{bin,etc} 2>/dev/null"
if ($use_remount) {
    adb wait-for-device shell "remount"
} elseif ((adb shell stat -f --format %a /system) -eq "0") {
    Write-Error "ERROR: /system has 0 available blocks, consider using -use_remount" -ErrorAction Stop
} else {
    adb wait-for-device shell "stat --format %m /system | xargs mount -o rw,remount"
}
adb wait-for-device push 88-gsans.sh /system/addon.d/
adb wait-for-device push GoogleSans-Italic.ttf /system/fonts/
adb wait-for-device push GoogleSans-Regular.ttf /system/fonts/
adb wait-for-device push GoogleSansFlex-Regular.ttf /system/fonts/
adb wait-for-device push font_fallback.xml /system/etc/
adb wait-for-device push fonts.xml /system/etc/

if ($reboot) {
    adb wait-for-device reboot
}
