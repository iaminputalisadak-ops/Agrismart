# AgriSmart — Flutter app

Main application for the [Agrismart](https://github.com/iaminputalisadak-ops/Agrismart) repository.

## Prerequisites

1. Flutter stable **≥ 3.19** — [install guide](https://docs.flutter.dev/get-started/install)
2. Run `flutter doctor` and fix any reported issues
3. Physical phone or emulator with camera (live scan)

## Setup and run

```bash
cd flutter_app
flutter pub get
flutter devices
flutter run
```

Platform folders (`android/`, `ios/`, …) are already in the repo. If you regenerate them with `flutter create .`, your `lib/` and `assets/` are preserved.

## Permissions

Camera and location are required for live scan and delivery address. They are declared in:

- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

## ML assets (optional)

| File | Purpose |
|------|---------|
| `assets/labels.txt` | Insect class names (shipped) |
| `assets/insect_model.tflite` | Optional TFLite insect model |
| `assets/README_INSECT_MODEL.txt` | Training / export notes |
| `assets/README_CROP_DISEASE_MODEL.txt` | Crop disease model notes |

Add `insect_model.tflite` to `pubspec.yaml` under `flutter: assets:` when you have a real model.

## App structure

| Screen / module | Role |
|-----------------|------|
| `landing_screen.dart` | Sign-in, registration entry, language picker |
| `main_app_shell.dart` | Bottom navigation (home, scan, shop, assistant, account) |
| `insect_live_scan_screen.dart` | Live camera pest scan |
| `crop_disease_screen.dart` | Disease photo check |
| `agri_store_screen.dart` | Shop catalogue and cart |
| `ai_farming_assistant_screen.dart` | Offline farming Q&A |
| `admin_dashboard_screen.dart` | Admin metrics and product management |
| `l10n/app_localizations.dart` | EN / HI / NE / RU strings |
| `agri_product_repository.dart` | SQLite product database |

## Demo accounts

**Admin:** `admin@agrismart.com` / `admin123`

**Farmer:** register on the landing screen, then sign in with the email and password you chose.

## Build release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Parent README

Repository overview and legacy Android app: [`../README.md`](../README.md).
