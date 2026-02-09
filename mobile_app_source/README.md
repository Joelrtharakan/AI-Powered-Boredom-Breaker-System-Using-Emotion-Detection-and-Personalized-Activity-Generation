# Boredom Breaker Mobile App

This is the Flutter source code for the Boredom Breaker application.

## Prerequisites
- Flutter SDK installed
- Android Studio / VS Code with Flutter extensions
- Android Emulator or Physical Device

## How to Run

1. **Create a new Flutter project**:
   ```bash
   flutter create boredom_breaker_mobile
   ```

2. **Copy Source Code**:
   Copy the `lib` folder from this directory and overwrite the `lib` folder in your new project.

3. **Add Dependencies**:
   Open `pubspec.yaml` in your new project and add these under `dependencies`:
   ```yaml
   flutter_riverpod: ^2.4.9
   dio: ^5.4.0
   google_fonts: ^6.1.0
   ```
   Then run `flutter pub get`.

4. **Android Configuration**:
   Open `android/app/src/main/AndroidManifest.xml` and add inside the `<application>` tag:
   ```xml
   android:usesCleartextTraffic="true"
   ```

5. **Run**:
   Ensure the backend is running on your computer.
   ```bash
   flutter run
   ```
