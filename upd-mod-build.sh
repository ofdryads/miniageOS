#!/bin/bash

echo "Checklist before running this script:"
echo "1. You should already have LineageOS installed on your phone. If you do not, you can use their official version and do a clean flash (*that process WILL wipe all data from your phone! Running this script will not)"
echo "   Installing the official version is fairly quick and simple if you follow their guide."
echo "2. You should have gotten up to the 'Preparing the build environment' section of the LineageOS Wiki build guide, including having installed all dependencies and run 'repo init', then 'repo sync' at least once"
echo "   *Step 2 only needs to be done ONCE. If you've EVER done those steps before, you don't need to do them again."
echo "3. You should have adb/fastboot installed on your computer"
echo "4. You should have added any websites you want permanently blocked on your phone to the hosts file you downloaded with this script. If you do not want any blocked, ignore this step."
echo "5. You should have enabled USB debugging in Developer Settings and authorized it for the computer you are working on"
echo "6. Add the appropriate values in the config.sh file, keeping it in the same folder as this script"
echo ""
echo "Additional note: please make sure your computer will stay on and not sleep or shut down while this is running!"
echo "The first time it builds, it may take many hours, and you can leave it running overnight. Subsequent runs should only take 30-90 mins, depending on your hardware (for build), network (for sync), etc."
echo ""
echo "Another note: This script, specifically 'repo sync --force-sync --detach', will destroy any changes you have made on your computer to the LineageOS code that are not re-injected by this script."
echo "If you do not want that, you can modify the script or not run it."
echo ""
echo "If you have done all these things and want to continue, press 'y'"
echo "Otherwise, you can press 'n', go do them, and come back later to run the script"
read -p "Continue? (y/n): " yn
case $yn in
    [Yy]* ) ;;
    * ) exit 1;;
esac

exec > >(tee -a build.log) 2>&1 # log to this file

source ./config.sh # load variables that will be used

if [[ "${ARE_YOU_ME,,}" == "true" ]]; then
  source ./ignore/config.sh
fi

# directory where the dumbphone scripts and files live
script_in_here="$(dirname "$0")"

if ! command -v adb &> /dev/null; then
    echo "Error: adb not installed or not found"
    exit 1
fi

if [ ! -d "$LINEAGE_ROOT/.repo" ] || [ ! -d "$LINEAGE_ROOT/packages" ]; then
    echo "Error: directory contents not found - maybe you entered the wrong path to the LineageOS directory, or you have not run the original 'repo init' and 'repo sync' for base LineageOS yet"
    exit 1
fi

cd "$LINEAGE_ROOT"
# set up the build environment
source build/envsetup.sh
croot || { echo "Exiting..."; exit 1; }

echo "Re-syncing repository to get any updates..."
repo sync --force-sync --detach

echo "Running device-specific prep before building..."
# even for devices where this will fail without proprietary blobs, it needs to run in order to populate lineage/device w/ the manufacturer and device
breakfast "$CODENAME"
cd device || { echo "No device directory found - try the 'breakfast' command with your device's CODENAME again"; exit 1; }

#afaik this will always exit if the 'device' subdirectory selected is not the manufacturer - none of the others will contain a folder called *CODENAME* 
cd "$MANUFACTURER"/"$CODENAME" || { echo "Can't find directory for this manufacturer and device"; exit 1; }

# take the proprietary things to be included and remove problematic/unwanted ones 
# DO NOT DO THIS CARELESSLY
# NEEDS FIXING / TESTING
if [[ "$CODENAME" == "lynx" ]]; then
    cp "$LINEAGE_ROOT"/device/google/lynx/lynx/proprietary_files.txt $script_in_here
    # TODO have user modify file, get input when done, and cp back to "$LINEAGE_ROOT"/device/google/lynx/lynx/proprietary_files.txt
fi

# extract proprietary blobs, or overwrite previous blobs with updated ones
echo "Extracting the latest proprietary blobs for your device from the official LOS build..."

# remove past blobs for clean slate
check for the folder and contents first then:
rm -rf "$LINEAGE_ROOT/vendor/$MANUFACTURER"

# TODO pull the latest LOS nightly signed zip
#PLACEHOLDER
latest_off_zip="/home/aph/Downloads/lineage-22.2-20250801-nightly-lynx-signed.zip"
./extract-files.py "$latest_off_zip"

# for if it didnt work the first time bc it needed the proprietary blobs first
# no harm in running twice
breakfast "$CODENAME"

# Check for dumbphone manifest file, create if it doesn't exist
local_manifest="$LINEAGE_ROOT/.repo/local_manifests/dumbphone.xml"
if [ ! -f "$local_manifest" ]; then
    mkdir -p "$LINEAGE_ROOT/.repo/local_manifests"
    cat > "$local_manifest" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <!-- Remove default browser -->
  <remove-project name="LineageOS/android_packages_apps_Jelly" />

  <!-- Remove fallback browser -->
  <remove-project name="platform/packages/apps/Browser2" />

  <!-- Prevent OTA updates from coming to the phone that will overwrite changes made -->
  <remove-project name="LineageOS/android_packages_apps_Updater" />
</manifest>
EOF
fi

echo "Re-syncing repo to apply the dumbphone manifest changes to the source code..."
repo sync

if [ -f "$HOSTS" ]; then
    cp "$HOSTS" "$LINEAGE_ROOT/system/core/rootdir/etc/hosts"
    echo "Replaced LineageOS hosts file with your modified version."
    echo "If you didn't modify it, this will have no effect."
else
    echo "Error: Custom hosts file not found - is it in the same folder as this script and named "hosts"?"
fi

# Nerf the saved searches in settings by removing DB accessing stuff - here
# have it fail gracefully and continue building if the file structure changes somehow
(if the original file is in that location and config set to true: )
  cp "$script_in_here/NoSavedSettingsSearches.java" "$lineage_root/packages/apps/SettingsIntelligence/src/com/android/settings/intelligence/search/savedqueries/SavedQueryRecorder.java"

echo "Building the dumb LineageOS image..."
source build/envsetup.sh
croot
brunch "$CODENAME"

cd $OUT # go to build output folder when done

. ./flash-customize.sh # invoke the other script to finish the dumbphone