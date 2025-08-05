# see https://wiki.lineageos.org/devices/ and click on your phone's vendor
# it should say "codename: {xyz}" below your phone model - that is the value for CODENAME
CODENAME=""
LINEAGE_ROOT="" # the path to the directory where you ran 'repo init' and 'repo sync'

# for MANUFACTURER, usually it's just the manufacturer name in lowercase with no spaces
# Some known manufacturer names: google, samsung, motorola, oneplus, fairphone, nokia
MANUFACTURER=""

# if these are already enabled or you don't want them, put false
GRAYSCALE=true   # put true or false
NIGHT_MODE=true  # put true or false

# Is the phone a Google Pixel?
IS_PIXEL=false

# If you have a Pixel, this will install the Google Pixel Camera and disable the LineageOS default camera (Aperture)
GOOGLE_PIXEL_CAMERA=false

# Option to tweak which things will be included in the proprietary blob extraction step
# You can choose to exclude "blobs" if they are causing issues w/ extraction or that you are 100% sure your device doesn't need to boot/function
# **If any doubt about above, I wouldn't do this tbh**
TWEAK_BLOBS=false

#Disable saved searches and suggestions of your past searches in Settings
DISABLE_SETTINGS_SEARCHES=false # put true to disable, or false to save past searches (LOS normal behavior)
NO_SETTINGS_SEARCH_FILE="./replace/NoSavedSettingsSearches.java"

# path to custom hosts file - you don't need to change this unless you move the file or rename it
HOSTS="./replace/hosts"

# Are you me?
ARE_YOU_ME=false
# You will not have the files the script will reference if this is set to true and you are not me