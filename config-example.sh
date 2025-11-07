
# RENAME OR COPY THIS FILE TO "config.sh" in this same folder BEFORE RUNNING SCRIPTS

# see https://wiki.lineageos.org/devices/ and click on your phone's vendor
# it should say "codename: {xyz}" below your phone model - that is the value for CODENAME
CODENAME=""
LINEAGE_ROOT="" # the path to the directory where you ran 'repo init' and 'repo sync'

# for MANUFACTURER, usually it's just the manufacturer name in lowercase with no spaces
# like: google, samsung, motorola, oneplus, etc.
MANUFACTURER=""

# number of concurrent jobs ninja should do (to prevent build from failing due to resource exhaustion)
NINJA_JOBS=10

# if these are already enabled or you don't want them, put false
GRAYSCALE=true   # put true or false
NIGHT_MODE=true  # put true or false

# Scale the system font/display elements up to make everything bigger?
BIG_FONT_DISPLAY=true
# Below values applied if BIG_FONT_DISPLAY=true
FONT_MULTIPLIER=1.5
DISPLAY_MULTIPLIER=1.1 # ultimately results in the font being scaled to 1.65 from baseline, since these values stack

# disable transition and other animations in the UI
DISABLE_ANIMATIONS=true

# path to the downloaded latest official lineageos release from https://download.lineageos.org/devices/{CODENAME}/builds
# used for extracting proprietary blobs
OFFICIAL_ZIP=""

# this will install the Google Pixel Camera and disable the LineageOS default camera (Aperture)
GOOGLE_PIXEL_CAMERA=false
# https://www.apkmirror.com/apk/google-inc/camera/ - you probably want arm64-v8a / nodpi / Android 15+ variant
PIXEL_CAMERA_APK="" # path to apk for google pixel camera app

# Option to tweak which things will be included in the proprietary blob extraction step
# You can choose to exclude Google/cell carrier/other packages if they are causing issues w/ extraction or that you are 100% sure your device doesn't need to boot/function
# **If any doubt about above, I wouldn't do this tbh**
TWEAK_BLOBS=false

#Disable saved searches and suggestions of your past searches in Settings
DISABLE_SETTINGS_SEARCHES=true # put true to disable, or false to save past searches (LOS normal behavior)
PATH_TO_ORIGINAL="$LINEAGE_ROOT/packages/apps/SettingsIntelligence/src/com/android/settings/intelligence/search/savedqueries/SavedQueryRecorder.java"

THIS_FOLDER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # not to be changed
# path to custom hosts file - you don't need to change this unless you move the file or rename it
HOSTS="$THIS_FOLDER/replace/hosts"