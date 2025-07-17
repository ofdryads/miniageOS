# MineageOS
A stripped-down "dumbphone" mod of LineageOS

It does not have:
- A browser
- A browser engine (WebView)
- Any form of app store

It has bundled with it:
- Signal (encrypted messaging as alternative to SMS)
- Magic Earth (navigation)
...along with the other apps LineageOS ships with

Additionally:
- "Reading Mode" (B/W color filter) persists on reboot
- It does not save past searches in "Settings"

Hardcore/Dumbest version:
- lacks Bluetooth and WiFi drivers for full dumbphone experience and reduced tracking

What will NOT work:
- Banking apps, Venmo, etc. (as with base LineageOS, or any phone w/ an unlocked bootloader)
- Opening links (URL or QR code) in a browser

I would like to develop for it:
- A standalone e-reader app that renders .epubs without a browser engine
- A mechanism to store passkeys locally that can be used to log into accounts on desktop by scanning a QR code (use FIDO2)
