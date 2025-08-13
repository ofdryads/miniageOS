#!/bin/bash

# if not already in this directory
# Change to the build output directory
cd "$lineage_root"/out/.....finish this path 

echo "Make sure your phone is plugged into the computer, and that USB debugging on this computer has been enabled and authorized (in developer settings)"
echo ""
device_list=$(adb devices)
echo "$device_list"

echo "If you see your device listed above, that is good and you can continue"
echo ""
echo "If you do not see any device listed, do NOT press Enter yet. Leave this terminal window open, troubleshoot, then come back and when running 'adb devices' in another terminal window shows your device and says 'device', not 'unauthorized'."
echo ""
read -p "Press Enter to continue to flash the new system image and recovery:"

adb -d reboot bootloader

fastboot flash vendor_boot vendor_boot.img

fastboot reboot recovery

read -p "Go to Apply Update -> Apply from ADB in the recovery menu then hit enter: "

# Sideload the zip file just made
echo "'Dirty flashing' the new dumb image..."
# if ("lineage-"$codename"-{today's date like one below}-UNOFFICIAL.zip" in pwd)
# adb sideload "lineage-"$codename"-{today's date like one below}-UNOFFICIAL.zip" #FIX pattern
adb sideload lineage-22.2-20250812-UNOFFICIAL-lynx.zip

# else error, ask for the path to the zip explicitly

read -p "Is the phone rebooted and unlocked now? Hit Enter when it is"

# Gray phone
if [$GRAYSCALE]; then
  echo "Turning your phone gray..."
  adb shell settings put secure accessibility_display_daltonizer_enabled 1
  adb shell settings put secure accessibility_display_daltonizer 0
fi

if [$NIGHT_MODE]; then
  echo "Turning on night mode..."
  adb shell settings put secure night_display_activated 1
fi

echo "Downloading latest Aurora Store APK from f-droid.org for TEMPORARY installation..."
curl -s 'https://f-droid.org/en/packages/com.aurora.store/' | grep -oP 'https://f-droid.org/repo/com\.aurora\.store[^"]+\.apk' | head -1 | xargs -I {} wget -O aurora-store-latest.apk {}

#TODO verify PGP signature

#ONLY RUN if it passes PGP test - but delete the file either way
echo "Temporarily installing the Aurora Store on your phone..."
adb install aurora-store-latest.apk

echo "Update any third party apps you have installed or add any apps you need (e.g. maps, secure messaging, notes, minimalist launcher)"
echo "Warning: Some apps like Venmo, bank apps, and many (but not all) 2FA apps will not work with an unlocked bootloader."
read -p "Press Enter when you are done installing/updating what you need: "

# Clean up
echo "Deleting the Aurora Store .apk from your computer..."
rm -f aurora-store-latest.apk

echo "Uninstalling the Aurora Store app from your phone..."
adb shell am force-stop com.aurora.store
adb uninstall com.aurora.store

#TODO make it only for pixel!
# disable built-in lineageOS camera - leave it installed on the phone as a backup
adb shell pm disable-user --user 0 org.lineageos.aperture

# install pixel camera - replace hardcoded path with a config variable or pull from apkmirror
# We want android 15+ (NOT 16+), arm64-v8a, nodpi
# Get the latest one - handle bundle vs 1 apk, also check signature
# https://www.apkmirror.com/apk/google-inc/camera/variant-%7B%22arches_slug%22%3A%5B%22arm64-v8a%22%5D%2C%22dpis_slug%22%3A%5B%22nodpi%22%5D%2C%22minapi_slug%22%3A%22minapi-35%22%7D/
# there is also a record/notifications of updates here: https://www.pushbullet.com/channel-popup?tag=am-677523121
adb install "{my downloads folder - PLACEHOLDER}/com.google.android.GoogleCamera_9.8.102.738511538.14-68281438_minAPI35(arm64-v8a)(nodpi)_apkmirror.com.apk"

# TODO should only attempt if pixel
echo "Disabling some unnecessary Google programs on the phone..."
# NOTE: with my edited proprietary-files.txt, the 1st one is not part of the system image anyways
adb shell pm disable-user --user 0 com.google.android.as # Android System Intelligence
adb shell pm disable-user --user 0 com.google.android.as.oss # Private Compute Services

echo "Phone is dumber now!"