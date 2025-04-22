# Flutter Text Detect Area

A Flutter plugin that enables text detection from **specific areas** of an image or live camera preview. Just drag/select the area you want to scan, and let it extract the text using ML Kit.

Perfect for scanning:
- 🧾 Receipts image
- 📄 Documents image
- 📘 PDFs image
- 🧠 Custom fields in images

---

## 🚀 Features

- 📸 Supports both **live camera** and **gallery image** input
- ✍️ Manual area selection (drag, resize, pan)
- 🔁 Detect text once or continuously
- 📱 Android & iOS support
- ✅ Simple integration

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_text_detect_area: <latest-version>
```

Import in your Dart file:

```dart
import 'package:flutter_text_detect_area/flutter_text_detect_area.dart';
```

---

## 📸 Screenshots

| Pick Image | Live Camera    | Single Text Detection   |
|------------|----------------|-------------------------|
| ![Pick](https://raw.githubusercontent.com/techvootsolutions/flutter_text_detect_area/main/images/android.gif) | ![Camera](https://raw.githubusercontent.com/techvootsolutions/flutter_text_detect_area/main/images/camera.gif) | ![Single Text Detection](https://raw.githubusercontent.com/techvootsolutions/flutter_text_detect_area/main/images/3.png) |

---

## 📂 Image Picker Setup

Use the `image_picker` package to choose an image:

```dart
final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
```

---

## ✨ Example Usage

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => SelectImageAreaTextDetect(
      detectOnce: true, // Set to false for continuous scan
      enableImageInteractions: true,
      imagePath: pickedFile?.path ?? '',
      onDetectText: (value) {
        if (value is String) {
          print("Detected: $value");
        } else if (value is List<String>) {
          for (int i = 0; i < value.length; i++) {
            print("${i + 1}. ${value[i]}");
          }
        }
      },
      onDetectError: (error) {
        if (error is PlatformException &&
            (error.message?.contains("InputImage width and height should be at least 32!") ?? false)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Selected area must be at least 32x32 pixels.")),
          );
        }
      },
    ),
  ),
);
```

---

## 🔐 Permissions

### Android (`AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### iOS (`Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>Need camera access for live scanning</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Need photo access to pick images</string>
```

---

## ✅ Platform Support

| Platform | Supported |
|----------|-----------|
| Android  | ✅         |
| iOS      | ✅         |
| Web      | ❌         |

---

## 🔍 Output Format

- If detecting once: returns `String`
- If detecting multiple areas: returns `List<String>`

---

## 💡 Use Cases

- Scan receipts for expenses
- Extract fields from identity cards
- Detect table content from scanned documents
- Select and extract from academic papers or books

---

## 👨‍💻 Contributors

- [Tushar Chovatiya](https://github.com/tusharchovatiya)
- [Princy Varsani](https://github.com/princy-varsani)
- [Kevin Baldha](https://github.com/Kevinbaldha)

---

## 📄 License

This project is licensed under the [GNU GPLv3](LICENSE).
