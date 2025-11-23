# 📌 Personal Health Insights App — **FitMatrix**

A Flutter app that helps users **track, visualize, and analyze personal health metrics** with a clean and modern UI/UX.

---

## 🚀 Features

- 🟢 Dashboard with **health metric cards**
- 🔍 Detailed metric view with **history & trends**
- 📊 Chart visualization using `fl_chart`
- 💾 Local data persistence via `SharedPreferences`
- 🎨 Smooth UI animations
- 🌙 **Light / Dark theme support**
- 🧱 Modular file architecture (Clean structure)
- 🔐 Firebase-ready authentication (future enhancement)

---

## 📂 Updated Project Folder Structure

```

lib/
└── src
├── data
│   ├── models
│   │   ├── metric.dart
│   │   └── data_sample.dart
│   └── repository
│       └── storage_repository.dart
├── domain
│   └── usecases
│       └── metrics_usecase.dart
├── presentation
│   ├── screens
│   │   ├── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── history_screen.dart
│   │   └── details_screen.dart
│   └── widgets
│       ├── history_card.dart
│       └── metric_card.dart
├── provider
│   └── metrics_provider.dart
├── services
│   └── storage_service.dart
└── main.dart

````

---

## 📦 Updated `pubspec.yaml` Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.1

  # Local storage
  shared_preferences: ^2.3.2

  # Charts
  fl_chart: ^0.69.0

  # Date formatting
  intl: ^0.19.0

  # Fonts
  google_fonts: ^6.4.0

  # Responsive UI
  flutter_screenutil: ^5.9.3

  # Firebase (optional for future login enhancement)
  firebase_core: ^3.7.0
  firebase_auth: ^5.5.0
  cloud_firestore: ^5.4.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
````

---

## 🖼 Screenshots

<details>
<summary>🌞 Light Mode</summary>

| Screenshot 1                             | Screenshot 2                             | Screenshot 3                             |
| ---------------------------------------- | ---------------------------------------- | ---------------------------------------- |
| ![WhatsApp Image 2025-11-23 at 9 54 02 PM (1)](https://github.com/user-attachments/assets/cef34f75-cee6-47fe-a172-bbc0cc6fb47f)
 | ![WhatsApp Image 2025-11-23 at 9 54 02 PM (2)](https://github.com/user-attachments/assets/554b104a-149e-4d2c-a7d5-ecdd38b9e35f)
 | ![WhatsApp Image 2025-11-23 at 9 54 03 PM](https://github.com/user-attachments/assets/2fffca69-93ac-4eec-99f1-8ca3ff67e002)
 |

</details>

<details>
<summary>🌙 Dark Mode</summary>

| Screenshot 1                           | Screenshot 2                           | Screenshot 3                           |
| -------------------------------------- | -------------------------------------- | -------------------------------------- |
| ![WhatsApp Image 2025-11-23 at 9 54 01 PM](https://github.com/user-attachments/assets/de99a1e9-3404-4937-a39e-f543312e523a)
 | ![WhatsApp Image 2025-11-23 at 9 54 01 PM (1)](https://github.com/user-attachments/assets/2a307105-1760-4269-b0a6-432d321d9ef2)
 | ![WhatsApp Image 2025-11-23 at 9 54 02 PM](https://github.com/user-attachments/assets/1475c16c-e55f-4e2d-ad61-7f869c833594)
 |

</details>

---

## ▶️ Run the App

```bash
flutter pub get
flutter run
```

---

## 🧰 Tech Overview

| Area                 | Tool              |
| -------------------- | ----------------- |
| State Management     | Riverpod          |
| Persistence          | SharedPreferences |
| Chart Visualization  | fl_chart          |
| Analytics (optional) | Firebase          |
| Architecture         | Clean + Modular   |

---

## 💡 Future Enhancements

* Online sync using Firebase
* Push reminders for health checkups
* Export metrics to PDF

---

### 🏷 License

This project is licensed under the **MIT License**.
