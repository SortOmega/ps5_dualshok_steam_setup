# Steam Input Setup

Flutter desktop installer for configuring PS5 DualSense and DualSense Edge
controllers for Steam Input on Linux.

## What it does

- Checks that Steam is installed.
- Checks both `60-steam-input.rules` and `70-steam-input.rules` in the standard
  udev rules directories (`/usr/lib/udev/rules.d` and `/etc/udev/rules.d`).
- Shows which files already exist and which are missing before changing anything.
- Requests administrator authorization through `pkexec` only when rules need to
  be added.
- Writes the PS5 USB and Bluetooth rules from
  [`lib/SETUP-README.md`](lib/SETUP-README.md).
- Creates `70-steam-input.rules` only after `60-steam-input.rules` is present.
- Reloads and triggers udev after installation, then reminds the user to restart
  Steam.

The interface starts in English and can be switched to Spanish from the
language selector.

## Run

On a Linux system with Flutter installed:

```bash
flutter pub get
flutter run -d linux
```

The desktop session must provide `pkexec` for the administrator prompt.
