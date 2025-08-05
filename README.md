```markdown
# miniageOS (mini-LineageOS)

Create a stripped-down "dumbphone" version of LineageOS for your Android phone without giving up the camera quality and touchscreen of a smartphone

## What is it?

Scripts, and resources used by those scripts to do what it does (see "What it does")

## What it does

- Builds the system image without the default browser OR the fallback browser
- Compiles with a custom hosts file so that your phone will "hard-block" any domains you choose
- Preserves all existing apps, settings, and other user data on phones that already have LineageOS installed
- Pulls the most recent LineageOS updates and device-specific vendor updates from their official sources before building so the phone stays up to date
- Allows you to extract only the "proprietary blobs" you want AND need for your device
- Does not include any app store or Google Play Services in the system image
- For Pixels, replaces the default LineageOS camera app with the higher-quality Google camera app, without needing GApps, Google Play Services, or microG
- Optionally sets the phone to grayscale and night mode (blue light filter)
- For Pixels, disables unneeded machine learning-based apps that use excessive network data and battery power (Android System Intelligence and Private Compute Services)
- Builds without the user-facing "Updater" so that you will not overwrite changes made to the operating system with OTA updates
- After the modified LineageOS image is built and flashed to your phone, it auto-installs the Aurora Store temporarily from a reputable APK source (F-droid), waits for you to update or install any apps you need (like secure messaging, notes, and maps), then auto-uninstalls the store when you are done
- No need for root access to make any of these changes

## Where to run

🟢 Linux (Ubuntu/Mint/Debian-based is best)
🟡 macOS or WSL (possibly, may cause some issues that need workarounds)
🔴 Windows (will not work)

## Backstory and "mission statement"

???

## What will NOT work when using a phone running this build

- Banking apps, Venmo, NFC/contactless pay (like Google Pay, Apple Pay, or Samsung Pay)
- Many popular proprietary 2FA apps (Microsoft, Google, Authy, etc.). However, open-source alternatives like Aegis *will* work

(The points above apply to any phone with an unlocked bootloader, including ones running official LineageOS builds. It even applies to many other custom ROMs that allow re-locking the bootloader)

- Opening links (URL or QR code) in a browser will not work, since there is no browser to open the links

## Important note

This process is meant to be repeated at least every 3-6 months. Running this script/flashing the image *is* the update mechanism. It replaces the OTA system to avoid the modifications being undone by LineageOS official releases. Going 6+ months without updating creates security risks. This goes for any 3rd party apps you add as well.

## Maybe also add:

- Separate music adding/playlist script
    - spotdl -> twelve script
    - yt-dlp -> twelve script

- React Native UI or launcher
```
