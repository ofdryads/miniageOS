#!/bin/bash

script_in_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_in_here/config.sh"

# if not already in this directory, change to the build output directory
output_folder="$LINEAGE_ROOT/out/target/product/$CODENAME"

echo "Make sure your phone is plugged into the computer, and that USB debugging on this computer has been enabled and authorized (in developer settings)"
echo ""
device_list=$(adb devices)
echo "$device_list"

echo "If you see your device listed above, that is good and you can continue"
echo ""
echo "If you do not see any device listed, do NOT press Enter yet. Leave this terminal window open, troubleshoot, then come back and when running 'adb devices' in another terminal window shows your device and says 'device', not 'unauthorized'."
echo ""
echo "Press Enter to continue to flash the new system image and recovery:"
read -r _

adb -d reboot bootloader

if [[ "$IS_PIXEL,,}" == "true" ]]; then
  fastboot flash vendor_boot vendor_boot.img
fi

fastboot reboot recovery
sleep 5 # 5 seconds before next prompt

echo "In the phone recovery menu (where you should be now - it might take a second), go to 'Apply Update' -> 'Apply from ADB', then hit enter:"
read -r _

# identify most recent build by searching output folder for zip files w/ names containing "lineage" and sorting by most recently modified
dumb_build=$(ls -t "$output_folder"/*.zip| grep "lineage" | head -n 1)

if [ -n "$dumb_build" ]; then
  echo "'Dirty flashing' the new dumb image..."
  adb sideload "$dumb_build"
else
  echo "Build output zip file not found"
  exit 1
fi

echo "Is the phone rebooted and unlocked now? Hit Enter when it is."
read -r _

# set olauncher as default launcher
if [[ "${OLAUNCHER,,}" == "true" ]]; then
  if adb shell pm list packages | grep -q "olauncher"; then
    adb shell pm grant com.tanujnotes.olauncher android.permission.SET_PREFERRED_APPLICATIONS
    adb shell cmd package set-home-activity com.tanujnotes.olauncher/.MainActivity
  fi
fi

# Gray phone
if [[ "$GRAYSCALE,,}" == "true" ]]; then
  echo "Turning your phone gray..."
  adb shell settings put secure accessibility_display_daltonizer_enabled 1
  adb shell settings put secure accessibility_display_daltonizer 0
fi

if [[ "$NIGHT_MODE,,}" == "true" ]]; then
  echo "Turning on night mode..."
  adb shell settings put secure night_display_activated 1
fi

if [[ "$BIG_FONT_DISPLAY,,}" == "true" ]]; then
  adb shell settings put system font_scale "$FONT_MULTIPLIER"
  echo "Increased system font size by ${FONT_MULTIPLIER}"

  PHYSICAL_DENSITY=$(adb shell wm density | grep -o 'Physical density: [0-9]*' | awk '{print $3}') # get only the native physical density, not the current override value
  BIG_DISPLAY=$(echo "$PHYSICAL_DENSITY * $DISPLAY_MULTIPLIER" | bc | cut -d'.' -f1) # apply multiplier, then truncate to make int
  adb shell wm density "$BIG_DISPLAY"
  echo "Increased display size by ${DISPLAY_MULTIPLIER}"
fi

echo "Downloading latest Aurora Store APK from f-droid.org for TEMPORARY installation..."
curl -s 'https://f-droid.org/en/packages/com.aurora.store/' \
  | grep -oP 'https://f-droid.org/repo/com\.aurora\.store[^"]+\.apk' \
  | head -1 \
  | xargs -I {} wget -O aurora-store-latest.apk {}

echo "Temporarily installing the Aurora Store on your phone..."
adb install aurora-store-latest.apk

echo "Update any third party apps you have installed or add any apps you need (e.g. maps, secure messaging, notes, minimalist launcher)"
echo "Warning: Some apps like Venmo, bank apps, and certain Google apps will not work."
echo "Hit Enter when you are done installing/updating what you need:"
read -r _

# Clean up downloaded apk from pc
echo "Deleting the Aurora Store .apk from your computer..."
rm -f aurora-store-latest.apk

echo "Uninstalling the Aurora Store app from your phone..."
adb shell am force-stop com.aurora.store
adb uninstall com.aurora.store

if [[ "$IS_PIXEL,,}" == "true" ]]; then
  echo "Disabling some unnecessary Google programs on the phone..."
  if adb shell pm list packages | grep -q "com.google.android.as"; then
    adb shell pm disable-user --user 0 com.google.android.as # Android System Intelligence
  fi

  if adb shell pm list packages | grep -q "com.google.android.as.oss"; then
    adb shell pm disable-user --user 0 com.google.android.as.oss # Private Compute Services
  fi
fi

# disable built-in lineageOS camera - leave it installed on the phone as a backup
# install Google's Pixel camera app, where path to apk is provided by user in config.sh

#TODO since the APK is user-provided it is not actually bound to pixel phones
# make it a replace camera option more generally
if [[ "$IS_PIXEL,,}" == "true" && "$GOOGLE_PIXEL_CAMERA,,}" == "true" ]]; then
  if [[ -n "$PIXEL_CAMERA_APK" && "$PIXEL_CAMERA_APK" == *.apk ]]; then
    adb shell pm disable-user --user 0 org.lineageos.aperture
    adb install "$PIXEL_CAMERA_APK"
  else
    echo "The Pixel Camera APK was not found or the path was malformed"
  fi
fi

echo "Phone is dumber now!"