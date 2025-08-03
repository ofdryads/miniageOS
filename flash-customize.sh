#!/bin/bash

# Change to the build output directory
cd "$lineage_root"/out/

echo "Make sure your phone is plugged into the computer, and that USB debugging on this computer has been enabled and authorized (in developer settings)"

device_list=$(adb devices)
echo "$device_list"

echo "If you see your device listed, that is good and you can continue"
echo "If you do not see any device listed, do NOT press Enter yet. Leave this terminal window open, troubleshoot, then come back and when running 'adb devices' in another terminal window shows your device and says 'device', not 'unauthorized'."
read -p "Press Enter to continue to recovery and flash the new system image..."

fastboot reboot recovery

read -p "Go to the update option in the menu recovery menu then hit enter: "

# Sideload the zip file just made
echo "'Dirty flashing' the new dumb image..."
if ("lineage-"$codename"-{today's date like }-UNOFFICIAL.zip" in pwd)
adb sideload "lineage-"$codename"-{today's date like }-UNOFFICIAL.zip" #FIX pattern
else error, ask for the path

adb reboot

read -p "Is the phone on and unlocked now?"

# Gray phone
echo "Turning your phone gray..."
adb shell settings put secure accessibility_display_daltonizer_enabled 1
adb shell settings put secure accessibility_display_daltonizer 0

read -p "Do you also want night mode (blue light filter) on? (y/n): " yn
if [[ "$yn" =~ ^[Yy] ]]; then
  adb shell settings put secure night_display_activated 1
fi

echo "Downloading latest Aurora Store APK from f-droid.org for TEMPORARY installation..."
curl -s 'https://f-droid.org/en/packages/com.aurora.store/' | grep -oP 'https://f-droid.org/repo/com\.aurora\.store[^"]+\.apk' | head -1 | xargs -I {} wget -O aurora-store-latest.apk {}

#TODO verify PGP signature

#ONLY RUN if it passes PGP test - but delete the file either way
echo "Temporarily installing the Aurora Store on your phone..."
adb install aurora-store-latest.apk

echo "Update any third party apps you have installed or add any apps you need (e.g. maps, secure messaging, notes)"
echo "Warning: Some apps like Venmo, bank apps, and many (but not all) 2FA apps will not work with an unlocked bootloader."
read -p "Press Enter when you are done installing/updating what you need: "

# Clean up
echo "Deleting the Aurora Store .apk from your computer..."
rm -f aurora-store-latest.apk

echo "Uninstalling the Aurora Store app from your phone..."
adb shell am force-stop com.aurora.store
#perhaps a wait buffer/retry here?
adb uninstall com.aurora.store

echo "Disabling some unnecessary Google programs on the phone..."
adb shell pm disable-user --user 0 com.google.android.as #Android System Intelligence

echo "Phone is dumber now!"