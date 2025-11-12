#!/bin/bash

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOSTS="${project_root}/replace/hosts"

prebuild_checks() {
    exec > >(tee -a build.log) 2>&1 # log progress/errors to this file

    if [ ! -d "$project_root/replace" ]; then
        echo "Error: Volume mount missing expected directory structure"
        exit 1
    fi

    if [ ! -d "$LINEAGE_ROOT/.repo" ] || [ ! -d "$LINEAGE_ROOT/packages" ]; then
        echo "Error: LineageOS source not found"
        exit 1
    fi

    if [[ -n ${CODENAME} ]] || [[ -n ${MANUFACTURER} ]]; then
        echo "Device variables (name and vendor) not defined in Dockerfile"
        exit 1
    fi
}

build_setup() {
    # set up the build environment
    cd "$LINEAGE_ROOT" || exit 1
    source build/envsetup.sh
    croot || { echo "Build environment could not be set up, exiting..."; exit 1; }
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

# use the lineageOS api to pull the latest official nightly zip for a device
pull_latest_lineage() {
    curl -s "https://download.lineageos.org/api/v2/devices/${CODENAME}/builds" \
        | python3 -c "import sys, json; data=json.load(sys.stdin); print([f['url'] for b in data for f in b.get('files', []) if 'signed.zip' in f.get('filename', '')][0])" \
        | xargs wget -O "lineage-${CODENAME}-latest.zip"
    echo "$(pwd)/lineage-${CODENAME}-latest.zip"
}

# TODO check for proprietary-files.txt in replace/proprietary-files.txt, copy to 
# "$LINEAGE_ROOT/device/$MANUFACTURER/$CODENAME" only if the file is in replace/proprietary-files.txt

extract_blobs() {
    echo "Extracting the latest proprietary blobs for your device from the official LOS build..."

    # find the extract script (could be .py or .sh)
    extract_script=$(find "$LINEAGE_ROOT/device/$MANUFACTURER/$CODENAME" -type f -name "extract-files*" | head -n1)

    if [ -f "$extract_script" ]; then
        chmod a+x "$extract_script"
        echo "Extracting proprietary blobs..."
        ./"$extract_script" "$OFFICIAL_ZIP"
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
    prebuild_checks
    build_setup
    device_prep # run first time to populate device folder
    OFFICIAL_ZIP=$(pull_latest_lineage)
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