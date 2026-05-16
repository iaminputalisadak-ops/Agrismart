# AgriSmart

Cross-platform farming companion app: live pest scan, crop disease checks, local agri shop, farming Q&A assistant, and admin product management. Built with **Flutter** (primary) and a legacy **native Android** insect camera demo.

**Repository:** [github.com/iaminputalisadak-ops/Agrismart](https://github.com/iaminputalisadak-ops/Agrismart)

---

## Features (Flutter app)

| Area | Description |
|------|-------------|
| **Live scan** | Camera preview, crop context (heuristics + optional TFLite insect model), harm lookup per crop, optional Wikipedia summaries |
| **Crop disease** | Photo-based disease screening (optional TFLite model — see assets README) |
| **Agri shop** | Browse seeds, fertilizers, pesticides, tools; cart and checkout with map-based delivery address |
| **Farming assistant** | Offline Q&A bank with preset topics and free-text keyword matching |
| **Admin panel** | Product CRUD, dashboard metrics (SQLite on device) |
| **Languages** | English, Hindi, Nepali, Russian (in-app language picker) |
| **Accounts** | Farmer registration/sign-in (local demo); admin sign-in for catalogue management |

---

## Quick start (Flutter — recommended)

### Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) stable **≥ 3.19**
- Android: JDK 17 + Android SDK (API 24+)
- iOS: Xcode + CocoaPods (macOS only)
- A physical device with a camera for live scan

### Run

```bash
cd flutter_app
flutter pub get
flutter run
```

Grant **camera** and **location** permissions when prompted.

### Demo admin login

- Email: `admin@agrismart.com`
- Password: `admin123`

After sign-in: **Account → Admin panel** to manage products.

Farmers must **register** on the landing screen before signing in (credentials are stored locally for demo purposes only).

---

## Optional ML models

The app runs without custom models (heuristics + labels). For better accuracy, add TensorFlow Lite files:

| Model | Path | Guide |
|-------|------|--------|
| Insect classifier | `flutter_app/assets/insect_model.tflite` | `flutter_app/assets/README_INSECT_MODEL.txt` |
| Crop disease | per `flutter_app/assets/README_CROP_DISEASE_MODEL.txt` | same folder |

Register new asset files under `flutter: assets:` in `flutter_app/pubspec.yaml`, then rebuild.

---

## Project layout

```
Agrismart/
├── README.md                 ← this file
├── app/                      Legacy native Android insect camera (Java)
├── gradlew, gradlew.bat      Gradle wrapper (for app/)
└── flutter_app/              Main AgriSmart Flutter application
    ├── pubspec.yaml
    ├── assets/               labels, model placeholders, READMEs
    └── lib/
        ├── main.dart
        ├── main_app_shell.dart
        ├── insect_live_scan_screen.dart
        ├── crop_disease_screen.dart
        ├── agri_store_screen.dart
        ├── ai_farming_assistant_screen.dart
        ├── admin_dashboard_screen.dart
        ├── l10n/               UI translations
        └── …
```

---

## Legacy native Android app

The original single-purpose **insect + crop harm** camera app lives under `app/`. It uses the same TFLite + labels idea as the Flutter live scan tab.

```bash
# Windows
gradlew.bat installDebug

# macOS / Linux
./gradlew installDebug
```

Place `insect_model.tflite` in `app/src/main/assets/`. See `app/src/main/assets/README_MODEL.txt`.

More detail: open this repo’s `app/` tree or use Android Studio on the repository root.

---

## Flutter app documentation

Platform permissions, asset setup, and troubleshooting: [`flutter_app/README.md`](flutter_app/README.md).

---

## Security note

Authentication and product data are **stored on the device** for demonstration. Do not use demo admin credentials or local-only auth in production without a proper backend, HTTPS, and secure credential storage.

---

## License

See repository owner for licensing. Third-party packages are listed in `flutter_app/pubspec.yaml`.
