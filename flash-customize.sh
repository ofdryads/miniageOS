#!/bin/bash

# if not already in this directory, change to the build output directory
cd "$LINEAGE_ROOT/out/target/product/$CODENAME"

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

if [[ "$IS_PIXEL" ]]; then
  fastboot flash vendor_boot vendor_boot.img
fi

fastboot reboot recovery

read -p "Go to Apply Update -> Apply from ADB in the recovery menu then hit enter: "

# Look for the zip file just made from build then sideload it
TODAY=$(date +"%Y%m%d")
dumb_build=$(grep -l "$TODAY" *.zip 2>/dev/null)

if [ -n "$dumb_build" ]; then
  echo "'Dirty flashing' the new dumb image..."
  adb sideload "$dumb_build"
else
  echo "Build output not found"
  exit 1
fi

read -p "Is the phone rebooted and unlocked now? Hit Enter when it is"

# Gray phone
if [[ "$GRAYSCALE" ]]; then
# TODO check - adb shell settings get secure accessibility_display_daltonizer_enabled
# check - adb shell settings get secure accessibility_display_daltonizer
  echo "Turning your phone gray..."
  adb shell settings put secure accessibility_display_daltonizer_enabled 1
  adb shell settings put secure accessibility_display_daltonizer 0
fi

if [[ "$NIGHT_MODE" ]]; then
# TODO Check: adb shell settings get secure night_display_activated
  echo "Turning on night mode..."
  adb shell settings put secure night_display_activated 1
fi

echo "Downloading latest Aurora Store APK from f-droid.org for TEMPORARY installation..."
curl -s 'https://f-droid.org/en/packages/com.aurora.store/' | grep -oP 'https://f-droid.org/repo/com\.aurora\.store[^"]+\.apk' | head -1 | xargs -I {} wget -O aurora-store-latest.apk {}

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

  # NOTE: with my edited proprietary-files.txt, com.google.android.as is not part of the system image anyways
if [[ "$IS_PIXEL" ]]; then
  echo "Disabling some unnecessary Google programs on the phone..."
  adb shell pm disable-user --user 0 com.google.android.as # Android System Intelligence
  adb shell pm disable-user --user 0 com.google.android.as.oss # Private Compute Services
fi

# disable built-in lineageOS camera - leave it installed on the phone as a backup
# install Pixel camera
if [[ "$IS_PIXEL" && "$GOOGLE_PIXEL_CAMERA" ]]; then
  adb shell pm disable-user --user 0 org.lineageos.aperture
  adb install $PIXEL_CAMERA_APK 
fi

echo "Phone is dumber now!"