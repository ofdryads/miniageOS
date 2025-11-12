#!/bin/bash

# source config variables
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

confirm_run() {
    cat <<-'EOF'
	===== Checklist before running this script =====
	
	1. You already have LineageOS installed on your phone
	2. You have gotten up to the 'Preparing the build environment' section
	3. (Optional) Edited the hosts file in the "replace" folder
	4. Added the correct values to the config.sh file
	
	Notes:
	- Keep computer awake - first build may take many hours
	- This will overwrite any changes you made to the LineageOS code
	EOF
    
    read -rp "Continue? (y/n): " yn
    [[ $yn =~ ^[Yy]$ ]] || { echo "Exiting."; exit 1; }
}

prebuild_checks() {
    exec > >(tee -a build.log) 2>&1 # log progress/errors to this file

    if [ ! -f "$project_root/config.sh" ]; then
        echo "No file named config.sh found in this project's root folder - you may still need to rename or copy config-example.sh to config.sh (after entering the right values)"
        exit 1
    fi

    source "$project_root/config.sh" || exit # load config variables used to differentially execute commands

    if [ ! -d "$LINEAGE_ROOT/.repo" ] || [ ! -d "$LINEAGE_ROOT/packages" ]; then
        echo "Error: directory contents not found - maybe you entered the wrong path to the LineageOS directory, or you have not run the original 'repo init' and 'repo sync' for base LineageOS yet"
        exit 1
    fi

    if [ -z "$OFFICIAL_ZIP" ]; then
        echo "Error: OFFICIAL_ZIP (path to lineageos official release zip) is not set in config.sh"
        echo "The device's proprietary blobs will not be extracted... exiting"
        exit 1
    fi
}

force_sync() {
    cd "$LINEAGE_ROOT" || exit
    echo "Re-syncing repository to get any updates..."
    repo sync --force-sync
}

build_setup() {
    # set up the build environment
    cd "$LINEAGE_ROOT" || exit 1
    source build/envsetup.sh
    croot || { echo "Build environment could not be set up, exiting..."; exit 1; }

    if [[ "$NINJA_JOBS" =~ ^[0-9]+$ ]]; then
        export NINJA_ARGS="-j${NINJA_JOBS}" # prevent ninja/soong crashing by limiting jobs
    fi
}

device_prep() {
    echo "Running device-specific prep before building..."
    # even for devices where this will fail without proprietary blobs, it needs to run in order to populate lineage/device w/ the manufacturer and device folders
    breakfast "$CODENAME"

    if [ ! -d "device/$MANUFACTURER/$CODENAME" ]; then
        echo "Expected path to device folder not found, exiting..."
        exit 1
    fi
}

extract_blobs() {
    # take the proprietary things to be included and remove problematic/unwanted ones 
    if [[ "${TWEAK_BLOBS,,}" == "true" ]]; then
        echo "Searching device folder for proprietary-files.txt..."

        blobs_txt=$(find "$LINEAGE_ROOT/device/$MANUFACTURER/$CODENAME" -type f -name "proprietary-files.txt" | head -n1)
        
        if [ -z "$blobs_txt" ]; then
            echo "Error: Could not find proprietary-files.txt under ${LINEAGE_ROOT}/device/${MANUFACTURER}/${CODENAME}"
            exit 1
        fi

        if [ -d "$project_root/replace" ]; then
            temp_location="$project_root/replace/proprietary-files.txt"
            cp "$blobs_txt" "$temp_location"
            echo "Edit and save the file at miniageos/replace/proprietary-files.txt, commenting out or deleting any unnecessary blobs."
            echo "Press Enter when done to continue..."
            read -r _ < /dev/tty
            cp "$temp_location" "$blobs_txt"
        else
            echo "Replace folder not found, cannot use files in it"
        fi
    fi

    echo "Extracting the latest proprietary blobs for your device from the official LOS build..."

    # find the extract script (could be .py or .sh)
    extract_script=$(find "$LINEAGE_ROOT/device/$MANUFACTURER/$CODENAME" -type f -name "extract-files*" | head -n1)

    if [ -x "$extract_script" ]; then
        echo "Extracting proprietary blobs..."
        "$extract_script" "$OFFICIAL_ZIP"
    else
        echo "Extract-files.py not found or not executable. Proprietary blobs cannot be extracted. Exiting..."
        exit 1
    fi
}

# Check for dumbphone manifest file, create if it doesn't exist yet
dumb_manifest() {
    local_manif_file="$LINEAGE_ROOT/.repo/local_manifests/dumbphone.xml"

    if [ ! -f "$local_manif_file" ]; then                
        cat > "$local_manif_file" <<'EOF'
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
}

normal_sync() {
    cd "$LINEAGE_ROOT" || exit
    echo "Re-syncing repo to apply manifest changes to the source code..."
    repo sync
}

custom_hosts() {
    if [ -f "$HOSTS" ]; then
        cp "$HOSTS" "$LINEAGE_ROOT/system/core/rootdir/etc/hosts"
        echo "Replaced LineageOS hosts file with your modified version."
        echo "If you didn't modify it, this will have no effect."
    else
        echo "Error: Custom hosts file not found - did you move it/rename it/change the HOSTS value in config.sh?"
    fi
}

no_saved_settings_searches() {
    # Disables saving past searches in settings
    if [[ "${DISABLE_SETTINGS_SEARCHES,,}" == "true" ]] && [ -f "$PATH_TO_ORIGINAL" ]; then
        cp "$project_root/replace/NoSavedSettingsSearches.java" "$PATH_TO_ORIGINAL"
        echo "Disabled saving past searches in settings"
    fi
}

build() {
    echo "Building the dumb LineageOS image..."
    echo "This may take 1-4 hours depending on your hardware and if you have built on this computer before"
    
    local build_start
    build_start=$(date +%s)
    brunch "$CODENAME" || {
        echo "Error: Build failed"
        exit 1
    }

    local build_end
    build_end=$(date +%s)
    local build_time=$((build_end - build_start))
    local build_hours=$((build_time / 3600))
    local build_minutes=$(((build_time % 3600) / 60))
    
    echo "Built for ${build_hours}h ${build_minutes}m"
    
    # go to output directory
    cd "$LINEAGE_ROOT/out/target/product/$CODENAME" || exit 1
}

main() {
    confirm_run
    prebuild_checks
    force_sync
    build_setup
    device_prep # run first time to populate device folder
    extract_blobs
    device_prep # run again after blobs extracted
    dumb_manifest
    normal_sync
    no_saved_settings_searches
    custom_hosts
    build
}

# execute main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi