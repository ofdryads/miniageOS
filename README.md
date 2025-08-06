# miniageOS (mini-LineageOS)

Create a stripped-down "dumbphone" version of LineageOS for your Android phone without giving up the camera quality and touchscreen of a smartphone

## What is it?

Scripts, and resources used by those scripts to do what it does (see "What it does")

## What is it *not*?
- A launcher
- "Screen time"-like restrictions
- Temporary, reversible commands that disable user-facing apps until they are either re-enabled in Settings or the phone is updated
- A fork of LineageOS

## What it does

- Builds the system image without the default browser *or* the fallback browser
- Compiles with a custom hosts file so that your phone will "hard-block" any domains you choose
- Optionally sets the phone to grayscale and night mode (blue light filter)
- Pulls the most recent LineageOS updates and device-specific vendor updates from their official sources before building each time, so the phone stays up to date
- Preserves all existing apps, settings, and other user data on phones that already have LineageOS installed
- Allows you to extract only the "proprietary blobs" you want *and* need for your device
- Does not include any app store or Google Play Services in the system image
- Builds without the user-facing "Updater" so that you will not overwrite changes made to the operating system with OTA updates
- After the modified LineageOS image is built and flashed to your phone, it auto-installs the Aurora Store temporarily from a reputable APK source (F-droid), waits for you to update or install any apps you need (like secure messaging, notes, and maps), then auto-uninstalls the store when you are done
- For Pixels:
    - Replaces the default LineageOS camera app with the higher-quality Google Pixel camera app, without needing GApps, Google Play Services, or microG
    - Disables unnecessary machine learning-based apps that use excessive cellular data and battery power (Android System Intelligence and Private Compute Services)

### Other benefits
- No need for root access to make any of these changes
- Your battery will last for days - you will hardly ever have to charge it

## Where to run

- ✅  Linux (Ubuntu/Mint/Debian-based is best)
- 🟡 macOS or WSL (possibly, may cause some issues that need workarounds)
- ❌ Windows (will not work)

## Instructions

## Backstory and "mission statement" (or, "why would anyone do this?")

???

## What will *not* work when using a phone running this build?

- Banking apps, Venmo, NFC/contactless pay (like Google Pay, Apple Pay, or Samsung Pay)
- Many popular proprietary 2FA apps (Microsoft, Google, Authy, etc.). However, open-source alternatives like Aegis *will* work perfectly fine.
  *(The points above apply to any phone with an unlocked bootloader, including ones running official LineageOS builds. It even applies to many other custom ROMs that allow re-locking the bootloader)*
- Opening links (URL or QR code) in a browser will not work, since there is no browser to open the links


## Important note

This is meant to be repeated at least every 3-6 months. Running this script/flashing the image *is* the update mechanism. It replaces the OTA system to avoid the modifications being undone by LineageOS official releases. Going 6+ months without updating creates security risks. This goes for any 3rd party apps you add as well.

## (My notes) Maybe also add:

- Separate music adding/playlist script
    - spotdl -> twelve script
    - yt-dlp -> twelve script

- React Native UI or launcher a la light phone
- e-reader app with "infinite scroll", dark mode, etc.

- I also want to try to build for pixel w/o Android System Intelligence and Private Compute Services and see if it boots instead of just going the adb disable route
