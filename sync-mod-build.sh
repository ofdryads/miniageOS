#!/bin/bash

cat <<'EOF'
===== Checklist before running this script =====

1. You already have LineageOS installed on your phone
2. You have gotten up to the 'Preparing the build environment' section of the LineageOS Wiki build guide, including having installed all dependencies and run 'repo init'
3. Have adb and fastboot are installed on your computer
4. (Optional) Edited the hosts file in the "replace" folder
5. Enabled USB debugging and authorized your computer
6. Added the correct values to the config.sh file in the same folder as this script

Notes:
- Keep computer awake - first build may take many hours but will probably only take 30-90 mins for subsequent builds
- This will overwrite any changes you made to the LineageOS code on your computer
EOF

read -rp "Continue? (y/n): " yn
[[ $yn =~ ^[Yy]$ ]] || { echo "Exiting."; exit 1; }

script_in_here="$(dirname "$0")" # project folder root

exec > >(tee -a build.log) 2>&1 # log progress/errors to this file

if [ ! -f "$script_in_here/config.sh" ]; then
    echo "No file named config.sh found in this project's root folder - you may still need to rename or copy config-example.sh to config.sh (after entering the right values)"
    exit 1
fi

source "$script_in_here/config.sh" # load config variables used to differentially execute commands

# several early checks for issues to exit early
if ! command -v adb &> /dev/null; then
    echo "Error: adb not installed or not found"
    exit 1
fi

if [ ! -d "$LINEAGE_ROOT/.repo" ] || [ ! -d "$LINEAGE_ROOT/packages" ]; then
    echo "Error: directory contents not found - maybe you entered the wrong path to the LineageOS directory, or you have not run the original 'repo init' and 'repo sync' for base LineageOS yet"
    exit 1
fi

if [ -z "$OFFICIAL_ZIP" ]; then
    echo "Error: OFFICIAL_ZIP (path to lineageos official release zip) is not set in config.sh"
    echo "The device's proprietary blobs will not be extracted... exiting"
    exit 1
fi

cd "$LINEAGE_ROOT"
echo "Re-syncing repository to get any updates..."
repo sync --force-sync

# set up the build environment
source build/envsetup.sh
croot || { echo "Exiting..."; exit 1; }

echo "Running device-specific prep before building..."
# even for devices where this will fail without proprietary blobs, it needs to run in order to populate lineage/device w/ the manufacturer and device folders
breakfast "$CODENAME"

if [ ! -d "device/$MANUFACTURER/$CODENAME" ]; then
    echo "Expected path to device folder not found, exiting..."
    exit 1
fi

cd device/"$MANUFACTURER"/"$CODENAME"

# take the proprietary things to be included and remove problematic/unwanted ones 
# DO NOT DO THIS CARELESSLY, brick risk if the wrong things are removed from the file
if [[ $IS_PIXEL && $TWEAK_BLOBS ]]; then
    echo "Searching device folder for proprietary-files.txt..."

    #FIX THIS
    blobs_txt=$(find "$LINEAGE_ROOT/device/$MANUFACTURER/$CODENAME" -type f -name "proprietary-files.txt" | head -n1)
    
    if [ -z "$blobs_txt" ]; then
        echo "Error: Could not find proprietary-files.txt under device/$MANUFACTURER/$CODENAME"
        exit 1
    fi

    cp "$blobs_txt" "$script_in_here/replace/proprietary-files.txt"

    echo "Edit and save the file at miniageos/replace/proprietary-files.txt, commenting out or deleting any unnecessary blobs."
    read -rp "Press Enter when done to continue..."

    cp "$script_in_here/replace/proprietary-files.txt" "$blobs_txt"
fi

echo "Extracting the latest proprietary blobs for your device from the official LOS build..."

# remove past blobs for clean slate
# check for the folder and contents first then:
if [ -d "$LINEAGE_ROOT/vendor/$MANUFACTURER/$CODENAME" ]; then
    rm -rf "$LINEAGE_ROOT/vendor/$MANUFACTURER/$CODENAME"
else
    echo "Did not find device directory, skipping delete"
fi

# NOTE: it is NOT always a python script for all devices and is not always in this pwd (device/"$MANUFACTURER"/"$CODENAME")
# for some devices it is a shell script. 
# need to accomodate for this, or the build will fail for all where extract script is not named this, and in this location
if [ ! -x "./extract-files.py" ]; then
    echo "Extract-files.py not found or not executable. Proprietary blobs cannot be extracted. Exiting..."
    exit 1
fi

# TODO pull the latest LOS nightly signed zip for the device instead of having path to downloaded zip in config
./extract-files.py "$OFFICIAL_ZIP" # blob extract script

# for phones where it didnt work the first time bc it needed the proprietary blobs first (no harm in running twice either way)
breakfast "$CODENAME"

# Check for dumbphone manifest file, create if it doesn't exist yet
local_manif_file="$LINEAGE_ROOT/.repo/local_manifests/dumbphone.xml"

if [ ! -f "$local_manif_file" ]; then                
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

#-----THIS SECTION HERE IS WHERE ALL PREBUILD SYSTEM CUSTOMIZATION that diverges from official LOS SHOULD HAPPEN-----#

if [ -f "$HOSTS" ]; then
    cp "$HOSTS" "$LINEAGE_ROOT/system/core/rootdir/etc/hosts"
    echo "Replaced LineageOS hosts file with your modified version."
    echo "If you didn't modify it, this will have no effect."
else
    echo "Error: Custom hosts file not found - did you move it/rename it/change the HOSTS value in config.sh?"
fi

# Disables saving past searches in settings
if [[ "${DISABLE_SETTINGS_SEARCHES,,}" == "true" ]] && [ -f "$PATH_TO_ORIGINAL" ]; then
    cp "$NO_SETTINGS_SEARCH_FILE" "$PATH_TO_ORIGINAL"
    echo "Disabled saving past searches in settings"
fi

if [[ "${OLAUNCHER,,}" == "true" ]]; then
    echo "Downloading latest version of Olauncher..."
    # non-"landscape" version olauncher APK
    curl -s https://api.github.com/repos/tanujnotes/Olauncher/releases/latest \
        | grep "browser_download_url" \
        | grep -i "Olauncher-v.*\.apk" \
        | grep -v "\-L" \
        | head -n1 \
        | sed -E 's/.*"([^"]+)".*/\1/' \
        | xargs -r wget -O olauncher-latest.apk

    # start w/ clean new app directory
    if [ -d "$LINEAGE_ROOT/packages/apps/Olauncher" ]; then
        rm -rf "$LINEAGE_ROOT/packages/apps/Olauncher"
    fi
    mkdir -p "$LINEAGE_ROOT/packages/apps/Olauncher"

    if [ -f "olauncher-latest.apk" ]; then
        mv olauncher-latest.apk "$LINEAGE_ROOT/packages/apps/Olauncher/"
    else
        echo "Failed to download Olauncher APK, it will not be included in the build"
    fi
fi

#----- END SECTION -----#

echo "Building the dumb LineageOS image..."
croot
brunch "$CODENAME"

cd $OUT # go to build output folder when done

if [[ "$(pwd)" == "$LINEAGE_ROOT/out/target/product/$CODENAME" ]]; then
    echo "DUMBPHONE: build process complete"
fi

# if [ -f "$script_in_here/flash-customize.sh" ]; then
#    echo "Running flash and customization script..."
#    source "$script_in_here/flash-customize.sh"
#else
#    echo "Flashing/customization script not found in root - flash build manually or run flash-customize.sh manually"
#fi