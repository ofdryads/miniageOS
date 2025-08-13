# miniageOS (mini-LineageOS)

Create a stripped-down "dumbphone" version of LineageOS for your Android phone without giving up the camera quality and touchscreen of a smartphone.
> dumbphone *(noun)*: A phone that is actually just a phone and only does what you need it to do for day-to-day life.

## What is this project?
Scripts, and resources used by those scripts to do what it does (see "What it does")

## What is it *not*?
- A launcher
- "Screen time"-like restrictions
- Temporary, reversible commands that disable user-facing apps which are trivially re-enabled in Settings or when the phone gets an update
- A fork of LineageOS

## What it does
- Builds the system image without the default browser *or* the fallback browser
- Compiles with a custom hosts file so that your phone will "hard-block" any domains you choose
- Optionally sets the phone to grayscale and night mode (blue light filter)
- Pulls the most recent LineageOS updates and device-specific vendor updates from their official sources before building each time, so the phone stays up to date
- Preserves all existing apps, settings, and other user data on phones that already have LineageOS installed
- Does not include any app store or Google Play Services in the system image
- Builds without the user-facing "Updater" so that you will not overwrite changes made to the operating system with OTA updates
- After the modified LineageOS image is built and flashed to your phone, it auto-installs the Aurora Store temporarily from a reputable APK source (F-droid), waits for you to update or install any apps you need (like secure messaging, notes, and maps), then auto-uninstalls the store when you are done
- For Pixel phones:
    - Replaces the default LineageOS camera app with the higher-quality Google Pixel camera app, without needing GApps, Google Play Services, or microG
    - Selectively excludes certain Google/carrier software from the build by preventing their "blobs" from being extracted, such as the "OK Google" listening software and Verizon apps
    - Disables unnecessary machine learning-based apps that use excessive cellular data and battery power (Android System Intelligence and Private Compute Services)

### Other benefits
- No need for root access to make any of these changes
- Your battery will last for days

## Where to run
- Yes: Linux (Ubuntu/Mint/Debian-based is best)
- Maybe: macOS or WSL (possibly, may cause issues that need workarounds)
- No: Windows (will not work)

## Instructions
  - TBA, it is a work in progress, but the base scripts (sync-mod-build.sh, flash-customize.sh) are very close to finished
  - it still has some pseudocode and commented out parts in the scripts, but all the individual commands in them, as well as the "replace" files, work as intended and preserve the system's normal functions

## What will *not* work when using a phone running this build?
- Banking apps, Venmo, NFC/contactless pay (like Google Pay, Apple Pay, or Samsung Pay)
- Many popular 2FA apps (Microsoft, Google, Authy, etc.). However, open-source alternatives like Aegis *will* work perfectly fine.
  *(The points above apply to any phone with an unlocked bootloader, including ones running official LineageOS builds. It even applies to many other custom ROMs that allow re-locking the bootloader)*
- Opening links (URL or QR code) in a browser will not work, since there is no browser to open the links


## Important note
This is meant to be repeated every 2 to 4 months or so. Running this script/flashing the image *is* the update mechanism. It replaces the OTA system to avoid the modifications being undone by LineageOS official releases. Going 6+ months without updating creates security risks. This goes for any 3rd party apps you add as well.
