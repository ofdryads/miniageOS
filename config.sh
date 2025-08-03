# see https://wiki.lineageos.org/devices/ and click on your phone's vendor
# it should say "codename: {xyz}" below your phone model - that is the value for CODENAME
CODENAME=""
LINEAGE_ROOT="" # the path to the directory where you ran 'repo init' and 'repo sync'

# for MANUFACTURER, usually it's just the manufacturer name in lowercase with no spaces
# Known names: google, samsung, motorola, nokia, asus, oneplus, fairphone, lenovo
MANUFACTURER=""

GRAYSCALE=true   # put true or false
NIGHT_MODE=true  # put true or false

#Disable saved searches and suggestions of past searches in Settings
DISABLE_SETTINGS_SEARCHES=false # put true to disable, or false to save past searches (LOS normal behavior)

# Option to tweak which things will be included in the proprietary blob extraction
TWEAK_PROPRIETARY=false

# path to custom hosts file - you don't need to change this unless you move it
HOSTS="./hosts"

# Are you me?
ARE_YOU_ME=false
# You will not have the files the script will reference if this is set to true and you are not me!
