# Ritu

A private journal for your cycle.

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) (stable)
- Xcode (for the iOS Simulator on macOS)

## Run on the iOS Simulator

```bash
flutter pub get
open -a Simulator
flutter devices
flutter run
```

If more than one device is listed, pick the simulator explicitly:

```bash
flutter run -d <device-id>
```

Example:

```bash
flutter run -d 5C36231B-583A-4814-B04B-A907111C331E
```

You can also launch a specific simulator first:

```bash
xcrun simctl list devices available
open -a Simulator --args -CurrentDeviceUDID <simulator-udid>
flutter run
```

While the app is running: `r` hot reload, `R` hot restart, `q` quit.
