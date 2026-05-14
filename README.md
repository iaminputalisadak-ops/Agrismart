# Insect Crop Harm Camera Detector

Two versions of the same app live in this repo. Pick whichever you prefer:

| Version | Folder | Language | Builds for |
|---|---|---|---|
| **Native Android** | `app/` (this folder uses root `gradlew`) | Java | Android |
| **Flutter (cross-platform)** | `flutter_app/` | Dart | Android **and** iOS |

Both versions:

- Open a live camera preview
- Let you pick the crop (Rice, Wheat, Tomato, ...)
- Classify the insect in view with a TensorFlow Lite model
- Show **DANGER** (red + beep + vibration) if the insect is harmful for that crop
- Show **SAFE** (green) otherwise

You only need to supply your own trained `insect_model.tflite` — see
`app/src/main/assets/README_MODEL.txt` or `flutter_app/assets/README_MODEL.txt`
for a 5-minute training walkthrough using Teachable Machine.

---

## A. Running the native Android version

### Requirements

- [Android Studio](https://developer.android.com/studio) (Hedgehog or newer), **or** just
  - JDK **17**
  - Android SDK (commandline tools + platform 35 + build-tools 34/35)
- A physical Android phone with USB debugging enabled

The Gradle wrapper (`gradlew`, `gradlew.bat`, `gradle/wrapper/`) is already
included, so you don't need a global Gradle install.

### Option 1 — Android Studio (easiest)

1. Open this folder in Android Studio.
2. Let it sync Gradle (first run may take ~5 min).
3. Drop your trained model into `app/src/main/assets/insect_model.tflite`.
4. Click **Run** ▶.

### Option 2 — Command line

```bash
# Windows
gradlew.bat installDebug

# macOS / Linux
./gradlew installDebug
```

Set `ANDROID_HOME` to your Android SDK path first, and `JAVA_HOME` to a JDK 17
install (the bundled JDK inside Android Studio works:
`%LOCALAPPDATA%\Programs\Android Studio\jbr` on Windows).

---

## B. Running the Flutter version

See [`flutter_app/README.md`](flutter_app/README.md) for the full walkthrough.

Short version:

```bash
cd flutter_app
flutter create .          # fills in the android/, ios/, ... folders
flutter pub get
flutter run               # build + install on the connected device
```

After `flutter create .`, you also need to add the camera permission to
`android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`
(snippets in `flutter_app/README.md`).

---

## Project layout

```
insect_crop_harm_camera_app/
├── build.gradle              top-level Gradle config (Android)
├── settings.gradle           Android project settings
├── gradle.properties         JVM args + AndroidX flags
├── gradlew  / gradlew.bat    Gradle wrapper scripts
├── gradle/wrapper/
│   ├── gradle-wrapper.jar          (binary, downloaded from gradle.org)
│   └── gradle-wrapper.properties   pins Gradle 8.7
│
├── app/                      Native Android app (Java)
│   ├── build.gradle
│   └── src/main/
│       ├── AndroidManifest.xml
│       ├── assets/           labels.txt + model placeholder
│       ├── java/com/example/insectcropcamera/
│       │   ├── MainActivity.java
│       │   ├── InsectClassifier.java
│       │   ├── CropRiskDatabase.java
│       │   ├── ImageUtils.java
│       │   └── InsectResult.java
│       └── res/              layout + styles
│
└── flutter_app/              Flutter app (Dart, Android + iOS)
    ├── pubspec.yaml
    ├── assets/               labels.txt + model placeholder
    └── lib/
        ├── main.dart
        ├── insect_classifier.dart
        └── crop_risk_database.dart
```

## Insect classes (defined in both `labels.txt` files)

aphid, whitefly, grasshopper, beetle, caterpillar, fall armyworm, stem borer,
leaf miner, thrips, bollworm, termite, rice bug, brown planthopper, cutworm,
potato tuber moth, fruit borer.
