#!/bin/bash

cat <<'EOF'
===== Checklist Before Running This Script =====

1. You already have LineageOS installed on your phone
2. You have gotten up to the 'Preparing the build environment' section of the LineageOS Wiki build guide, including having installed all dependencies and run 'repo init'
3. Have adb and fastboot are installed on your computer
4. (Optional) Edited the hosts file in the "replace" folder
5. Enabled USB debugging and authorized your computer
6. Added the correct values to the config.sh file in the same folder as this script

Notes:
- Keep computer awake - first build may take several hours but should only be 30-90 mins after the initial build
- 'repo sync --force-sync' will overwrite any changes you made to the LineageOS code
EOF

read -rp "Continue? (y/n): " yn
[[ $yn =~ ^[Yy]$ ]] || { echo "Exiting."; exit 1; }

# directory where the dumbphone scripts and files live
script_in_here="$(dirname "$0")"

exec > >(tee -a build.log) 2>&1 # log to this file

source "$script_in_here/config.sh" # load variables that will be used to differentially execute commands

if [[ "${ARE_YOU_ME,,}" == "true" ]]; then
  source "$script_in_here/ignore/config.sh"
fi

if ! command -v adb &> /dev/null; then
    echo "Error: adb not installed or not found"
    exit 1
fi

if [ ! -d "$LINEAGE_ROOT/.repo" ] || [ ! -d "$LINEAGE_ROOT/packages" ]; then
    echo "Error: directory contents not found - maybe you entered the wrong path to the LineageOS directory, or you have not run the original 'repo init' and 'repo sync' for base LineageOS yet"
    exit 1
fi

cd "$LINEAGE_ROOT"
echo "Re-syncing repository to get any updates..."
repo sync --force-sync

# set up the build environment
source build/envsetup.sh
croot || { echo "Exiting..."; exit 1; }

echo "Running device-specific prep before building..."
# even for devices where this will fail without proprietary blobs, it needs to run in order to populate lineage/device w/ the manufacturer and device
breakfast "$CODENAME"

#afaik this will always exit if the 'device' subdirectory selected is not the manufacturer - none of the others should ever contain a folder called *CODENAME* 
cd device/"$MANUFACTURER"/"$CODENAME" || { echo "Can't find directory for this manufacturer and device"; exit 1; }

# take the proprietary things to be included and remove problematic/unwanted ones 
# DO NOT DO THIS CARELESSLY
# NEEDS FIXING / TESTING
if [[ "$CODENAME" == "lynx" ]]; then
    # TODO search vendor/device for proprietary-files.txt recursively since not all devices have this same structure as the pixels
    cp "$LINEAGE_ROOT"/device/google/lynx/lynx/proprietary-files.txt $script_in_here
fi

#TODO if device is lynx, just replace the original file with new based on which things should be excluded

# extract proprietary blobs, or overwrite previous blobs with updated ones
echo "Extracting the latest proprietary blobs for your device from the official LOS build..."

# remove past blobs for clean slate
# check for the folder and contents first then:
rm -rf "$LINEAGE_ROOT/vendor/$MANUFACTURER/$CODENAME"

# TODO pull the latest LOS nightly signed zip
#PLACEHOLDER
latest_off_zip="{MYDOWNLOADSFOLDER-PLACEHOLDER}/lineage-22.2-20250801-nightly-lynx-signed.zip"
./extract-files.py "$latest_off_zip"

# for phones where it didnt work the first time bc it needed the proprietary blobs first (no harm in running twice either way)
breakfast "$CODENAME"

# Check for dumbphone manifest file, create if it doesn't exist yet
local_manif_file="$LINEAGE_ROOT/.repo/local_manifests/dumbphone.xml"

if [ ! -f "$local_manif_file" ]; then
    touch $local_manif_file                       
    cat > "$local_manif_file" <<EOF
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
    echo "Error: Custom hosts file not found - did you move it/rename it/change the HOSTS value in config.sh?"
fi

# Nerf the saved searches in settings by removing DB stuff and leaving skeleton
# have it fail gracefully and continue building if the file structure changes somehow
# confirmed this behaves as expected when file swapped
if [[ "${DISABLE_SETTINGS_SEARCHES,,}" == "true" ]] && [ -f "$PATH_TO_ORIGINAL" ]; then
    cp "$NO_SETTINGS_SEARCH_FILE" "$PATH_TO_ORIGINAL"
    echo "Disabled saving past searches in settings"
fi

echo "Building the dumb LineageOS image..."
source build/envsetup.sh
croot
brunch "$CODENAME"

echo "DUMBPHONE: build process complete"
cd $OUT # go to build output folder when done

if [ -f "$script_in_here/flash-customize.sh" ]; then
    echo "Running flash and customization script..."
    source "$script_in_here/flash-customize.sh"
else
    echo "Flashing/customization script not found in root - flash build manually or run flash-customize.sh manually"
fi