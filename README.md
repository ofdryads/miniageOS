# miniageOS (mini-LineageOS)

Create a stripped-down "dumbphone" version of LineageOS for your Android phone without giving up the camera quality and touchscreen of a smartphone.
> dumbphone *(noun)*: A phone that is actually just a phone and only does what you need it to do for day-to-day life.

## What is this?
Scripts, and resources used by those scripts to do what it does (see "What it does")

## What is it *not*?
- A launcher
- "Screen time"-like restrictions
- Temporary, reversible commands that disable certain apps which are trivially re-enabled in Settings or when the phone gets an update
- A fork of LineageOS (it builds the official, up-to-date LineageOS, with modifications being made at build time)

## What it does
- Builds the system image without the default browser *or* the fallback browser
- Compiles with a custom hosts file so that your phone will "hard-block" any domains you choose
- Optionally sets the phone to grayscale and night mode (blue light filter)
- Pulls the most recent LineageOS updates and device-specific vendor updates from their official sources before building each time, so the phone stays up to date
- Preserves all existing apps, settings, and other user data on phones that already have LineageOS installed
- Does not include any app store or Google Play Services in the system image
- Builds without the user-facing "Updater" so that you will not overwrite changes made to the operating system with OTA updates
- After the modified LineageOS image is built and flashed to your phone, it auto-downloads and installs the Aurora Store temporarily from a reputable source (F-droid), waits for you to update or install any apps you need (like secure messaging, notes, and maps), then auto-uninstalls the store when you are done
- For Pixel phones:
    - Replaces the default LineageOS camera app with the higher-quality Google Pixel camera app, without needing GApps, Google Play Services, or microG
    - Disables unnecessary machine learning-based apps that use excessive data and battery power (Android System Intelligence and Private Compute Services)
    - Option to selectively exclude certain Google/carrier software from the build by preventing their "blobs" from being extracted, such as the "OK Google" listening software and Verizon apps

### Other benefits
- No need for root access to make any of these changes
- Your battery will last for days

## Where to run
- Yes: Linux
- Maybe: macOS or WSL (possibly, may cause issues that need workarounds)
- No: Windows (will not work)

## Instructions
  - TBA - section needs improving!
  - git clone this repo
  - cd miniageOS
  - enter values in config-example.sh and rename or copy to config.sh in that same folder
  - run chmod +x sync-mod-build.sh flash-customize.sh
  - run ./sync-mod-build.sh

## What things will *not* work when using a phone running this build?
- Banking apps, Venmo, NFC/contactless pay (like Google Pay, Apple Pay, or Samsung Pay)
- RCS messaging (not without significant configuration, and may not even work consistently then). Regular SMS, most messaging apps, and iMessage-via-Mac services *will* work.
- Apple Music official client
- *(The points above apply to any phone with an unlocked bootloader, including ones running official LineageOS builds. It even applies to many other custom ROMs that allow re-locking the bootloader)*
- Opening links (URL or QR code) in a browser will not work, since there is no browser to open the links.

## Important note
This is meant to be repeated every few months or so. Running this script/flashing the image *is* the update mechanism. It replaces the OTA system to avoid the modifications being undone by official LineageOS releases. Going 6+ months without updating creates security risks. This goes for any 3rd party apps you add as well.
