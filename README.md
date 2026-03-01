# 🎯 Đố Vui (DoVui) – Flutter Quiz Application

> A scalable and real-time quiz application built with Flutter & Firebase.

Đố Vui là ứng dụng trắc nghiệm được xây dựng nhằm kiểm tra và nâng cao kiến thức người dùng thông qua nhiều chủ đề khác nhau.  
Dự án tập trung vào kiến trúc rõ ràng, khả năng mở rộng và đồng bộ dữ liệu realtime.

---

## 📱 Features

- 🔹 Multiple quiz categories  
- 🔹 Level-based progression system  
- 🔹 Multiple question types (MCQ, word answer)  
- 🔹 Real-time data synchronization (Firebase)  
- 🔹 Responsive UI for multiple screen sizes  
- 🔹 Clean and scalable project structure  

---

## 🏗 Architecture Overview

- Organized project structure (models / services / UI separation)
- Firebase Realtime Database integration
- Centralized theme & color management
- Reusable UI components
- Optimized state management using Flutter best practices

---

## 🛠 Tech Stack

- Flutter
- Dart
- API
- Firebase Realtime Database
- Firebase Authentication
- Material Design

---

## 📂 Project Structure

```
lib/
 ├── models/          # Data models
 ├── pages/           # UI screens
 │    ├── category/
 │    ├── question/
 │    └── level/
 ├── services/        # Business logic & Firebase handling
 ├── resources/       # Theme & color manager
 └── main.dart
```

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/ThanhHai2911/DoVui.git
cd dovui
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

1. Create a Firebase project  
2. Add Android app  
3. Download `google-services.json`  
4. Place it inside:

```
android/app/
```

5. Run the project

```bash
flutter run
```

## 🎯 Future Improvements

- Leaderboard system
- User progress persistence
- Offline caching
- Admin panel for managing questions
- UI/UX animation improvements
- CI/CD integration


## 👨‍💻 Developer

Thanh Hải  
Flutter Developer  

## 📌 License

This project is for educational and portfolio purposes.