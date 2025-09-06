# miniageOS (mini-LineageOS)

Create a stripped-down "dumbphone" version of LineageOS for your Android phone without giving up the camera quality and touchscreen of a smartphone.

> dumbphone _(noun)_: A phone that is actually just a phone and only does what you need it to do for day-to-day life.

<p align="center">
  <img src="https://github.com/user-attachments/assets/610abed4-f7a7-40e7-82b7-b2491f2bd7f1" alt="app-list" width="60%" />
</p>

_<p align="center">Launcher shown is Olauncher</p>_

## What is this?

Scripts, and resources used by those scripts to do what it does (see "What it does")

## What is it _not_?

- A launcher
- "Screen time"-like restrictions
- Temporary, reversible commands that disable certain apps which are trivially re-enabled in Settings or when the phone gets an update
- A fork of LineageOS (it builds the official, up-to-date LineageOS, with modifications being made at build time)

## What it does

- Builds the system image without any browser
- Compiles with a custom hosts file so that your phone will "hard-block" any domains you choose
- Sets the phone to grayscale and night mode (blue light filter)
- Applies a magnifier to text and UI elements on the phone
- Builds without the user-facing "Updater" so that you will not overwrite changes made to the operating system with OTA updates
- Does not include any app store or Google Play Services in the system image (like official LineageOS)
- Pulls the most recent LineageOS updates and device-specific vendor updates from their official sources before building each time, so the phone stays up to date
- Preserves all existing apps, settings, and other user data on phones that already have LineageOS installed
- After the modified LineageOS image is built and flashed to your phone, it auto-downloads and installs the Aurora Store temporarily from a reputable source (F-droid), waits for you to update or install any apps you need (like secure messaging, notes, and maps), then auto-uninstalls the store when you are done
- For Pixel phones:
  - Replaces the default LineageOS camera app with the higher-quality Google Pixel camera app, without needing GApps, Google Play Services, or microG
  - Disables unnecessary machine learning-based apps that use excessive data and battery power (Android System Intelligence and Private Compute Services)
  - Option to selectively exclude certain Google/carrier software from the build by preventing their "blobs" from being extracted, such as the "OK Google" listening software and Verizon apps
- No need for root access to make any of these changes
- Your battery will last for days

## Disclaimer

- As of now, these scripts have only been tested on a Google Pixel 7a. While they are likely compatible with other Pixel models, I cannot guarantee this, and it is less certain for non-Pixel phones. In theory, the scripts are device-agnostic since the manufacturer and device are specified manually in config.sh, but this is **untested** and could have **destructive results**, or, more likely, simply fail before completing the build due to differences in build processes, file locations, etc.
- At this point in time, I do _not_ recommend trying to run these scripts for a phone that is not some sort of Google Pixel.

## Prerequisites

- A computer running Unix/Linux (either natively or in a VM)
  - ✅ Yes: Linux
  - ⚠ Maybe: macOS or WSL (may require workarounds)
  - ❌ No: Windows
- At least 16GB RAM (adjust SWAP accordingly)
- At least 300GB storage, either on your regular SSD or an external USB one
- _Add note about temp EC2 to fulfill above reqs_
- Have official LineageOS already installed on your phone
  - Note: installing LineageOS for the first time will wipe your phone
  - Guide at https://wiki.lineageos.org/devices/{your-device-code-name}/install/
- Have followed the LineageOS "Build for {your-device-code-name}" guide on their wiki, up to the "Preparing the build environment" section, and have run "repo sync" at least once before
  - Guide at https://wiki.lineageos.org/devices/{your-device-code-name}/build/

## Instructions

1. Clone this repo:

```bash
git clone https://github.com/ofdryads/miniageOS.git
cd miniageOS
```

2. Configure:

- Enter the correct values in config-example.sh, then rename or copy config-example.sh to a file called "config.sh" in that same folder
- Put any and all domains you want to block in the hosts file at replace/hosts

3. Make the scripts executable:

```bash
chmod +x sync-mod-build.sh flash-customize.sh
```

4. Run

```bash
./sync-mod-build.sh
```

5. Once the build has completed, run:

```bash
./flash-customize.sh
```

## What things will _not_ work when using a phone running this build?

- Banking apps, Venmo, NFC/contactless pay (like Google Pay, Apple Pay, or Samsung Pay)
- RCS messaging
  - However, regular SMS, most messaging apps (Signal, WhatApp), and iMessage-via-Mac services (BlueBubbles) _will_ work just fine
- _(The points above apply to any phone with an unlocked bootloader, including ones running official LineageOS builds)_
- Opening links (URL or QR code) in a browser will not work, since there is no browser to open the links.

## Important note

This is meant to be repeated every few months or so. Running this script/flashing the image _is_ the update mechanism. It replaces the OTA system to avoid the modifications being undone by official LineageOS releases. Going 6+ months without updating creates security risks. This goes for any 3rd party apps you add as well.
