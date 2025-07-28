# MiniageOS
Create a stripped-down "dumbphone" version of LineageOS (mini-LineageOS)
(For Linux and macOS)

- Builds a system image that includes neither the default browser nor the fallback browser
- Compiles with any additions to the hosts file that you want
- It also builds without the user-facing "Updater", so that OTA updates will not overwrite the changes made

- After LineageOS is built and flashed to the phone, the script will install the Aurora Store, wait for you to update/install any apps you need (like secure messaging, notes, and maps), after which Aurora store will uninstall itself

What will NOT work when using a phone running this build:
- Banking apps, Venmo, 2FA apps etc. (as with base LineageOS, or any phone w/ an unlocked bootloader)
- Opening links (URL or QR code) in a browser

I would like to develop for it:
- A mechanism to store passkeys locally that can be used to log into accounts on desktop by scanning a QR code (use FIDO2) without opening a browser

Maybe also: 
- Have different versions that set settings for different personal preferences
- Separate music adding script
- Grayscale
- Night light
- Big icons, no text/labels
