# miniageOS
Create a stripped-down "dumbphone" version of LineageOS (mini-LineageOS)
(For Linux and macOS)

- Builds a system image that includes neither the default browser nor the fallback browser
- Compiles with any additions to the hosts file that you want
- It also builds without the user-facing "Updater", so that you will not overwrite the changes made with OTA updates

- After LineageOS is built and flashed to the phone, the script will install the Aurora Store, wait for you to update/install any apps you need (like secure messaging, notes, and maps), after which Aurora store will uninstall itself

What will NOT work when using a phone running this build:
- Banking apps, Venmo, 2FA apps etc. (as with base LineageOS, or any phone w/ an unlocked bootloader)
- Opening links (URL or QR code) in a browser

WARNING: this process is meant to be repeated regularly - every 3-6 months *at a minimum*. Running this script/flashing the image *is* the update mechanism. It replaces the OTA system to avoid the modifications being undone. Going 6+ months without updating (manually or OTA) creates security risks. This goes for any 3rd party apps you add as well.

I would like to develop for it:
- A mechanism to store passkeys locally that can be used to log into accounts on desktop by scanning a QR code (use FIDO2) without opening a browser

Maybe also: 
- Have different versions that set settings for different personal preferences
- Separate music adding script
- Grayscale
- Night light
- Big icons, no text/labels
