# Ritu

A private journal for your cycle.

For how on-device data is stored and how the schema is laid out, see [docs/DATA.md](docs/DATA.md).

For a browsable catalog of Ritu's reusable widgets and screens, see [widgetbook/](widgetbook/README.md).

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

## Generate an iOS test build (TestFlight)

You need an [Apple Developer Program](https://developer.apple.com/programs/) membership and an app record in [App Store Connect](https://appstoreconnect.apple.com) with bundle ID `care.ritu.ritu`.

1. **Bump the build number** in `pubspec.yaml` before each upload (marketing version can stay the same):

   ```yaml
   version: 0.1.0+2
   ```

   Format is `x.y.z+build`. Apple requires the `+build` number to increase on every upload.

2. **Build the IPA**:

   ```bash
   flutter pub get
   flutter build ipa
   ```

   The IPA lands in `build/ios/ipa/`.

3. **Upload to App Store Connect** (pick one):

   - Open `ios/Runner.xcworkspace` in Xcode → **Product → Archive** → **Distribute App** → **App Store Connect** → **Upload**
   - Or open **Transporter** / Xcode Organizer and upload the IPA from `build/ios/ipa/`

4. In App Store Connect → your app → **TestFlight**, wait for processing, then invite internal testers (fastest) or external testers (first build needs Beta App Review).

Testers install the free **TestFlight** app, accept the invite, and install Ritu from there. Builds expire after 90 days.
