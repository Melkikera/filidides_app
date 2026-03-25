# filidides_app

Flutter application for the Filidides project.

## App Description

Filidides is a route planning and journey tracking app built with Flutter.
It helps users search places, plan trips on Google Maps, draw routes with
travel-time estimates, and manage journey sessions. The app includes Firebase
authentication, onboarding flow, and profile/settings support for a complete
mobile-first navigation experience.

## Quick Launch Commands

Run these from the project root.

### 1) Verify toolchain

```bash
flutter --version
flutter doctor -v
```

### 2) Install dependencies

```bash
flutter pub get
```

### 3) List available devices

```bash
flutter devices
```

### 4) Launch app (recommended debug run)

```bash
flutter run
```

## Platform-Specific Launch

### Android (emulator or USB device)

```bash
flutter run -d android
```

### iOS (macOS + Xcode only)

```bash
flutter run -d ios
```

### Web (Chrome)

```bash
flutter run -d chrome
```

### Windows desktop

```bash
flutter run -d windows
```

### Linux desktop

```bash
flutter run -d linux
```

### macOS desktop

```bash
flutter run -d macos
```

## Useful Development Commands

```bash
# Clean and rebuild dependencies
flutter clean
flutter pub get

# Run static analysis
flutter analyze

# Run tests
flutter test
```

## Build Commands (release)

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# Web build
flutter build web --release

# Windows release build
flutter build windows --release
```
