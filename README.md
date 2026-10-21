# Nova — Social App

A bilingual (Arabic / English) social networking app built with **Flutter** and a feature-first **BLoC** architecture.

![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white)
![BLoC](https://img.shields.io/badge/State-BLoC-8A2BE2)
![License](https://img.shields.io/badge/License-MIT-green)

---

## ✨ Features

- **Authentication** — login, registration, remember-me, forgot password, social login flow, and session restore.
- **Feed** — posts with images, emoji reactions, share, and pull-to-refresh.
- **Comments** — list, add, and delete comments.
- **Favorites** — every post you reacted to, with removal support.
- **Notifications** — unread badge, mark as read, mark all, clear read items, and friend-request actions.
- **Search** — search posts and users, with friendship status and friend requests.
- **Profiles** — cover/avatar upload and delete, bio, friends count, user posts, and logout.
- **Messages** — conversations, friends list, real-time-style chat UI, and optimistic message sending.
- **Localization** — full Arabic and English UI with RTL support.
- **Theming** — consistent dark theme powered by a central color palette.

---

## 🏗 Architecture

The project follows a **feature-first** layout. Each feature owns its data and presentation layers, and every screen is driven by an explicit BLoC with events and states.

```
lib/
├── app.dart                     # Providers, MaterialApp, localization
├── main.dart
├── core/
│   ├── constants/               # API endpoints and storage keys
│   ├── models/                  # Shared models (User)
│   ├── network/                 # ApiClient + ApiException
│   ├── router/                  # Named routes
│   ├── theme/                   # AppColors
│   ├── utils/                   # Context extensions, date formatting
│   └── widgets/                 # Shared widgets (top notification, nav bar)
└── features/
    ├── auth/
    │   ├── data/                # Repository + social auth service
    │   └── presentation/        # AuthBloc, screens
    ├── posts/
    │   ├── data/                # Post model + repository
    │   └── presentation/        # PostsBloc, CreatePostBloc, PostDetailBloc
    ├── comments/
    ├── likes/
    ├── notifications/
    ├── profile/
    ├── search/
    └── messages/
```

### State management

| Bloc | Scope | Responsibility |
| --- | --- | --- |
| `AuthBloc` | Global | Session, login, registration, logout |
| `NotificationsBloc` | Global | Notification list and unread badge |
| `PostsBloc` | Feed | Posts, reactions and current user |
| `CreatePostBloc` | New post | Content/image upload |
| `PostDetailBloc` | Post details | Single post loading |
| `CommentsBloc` | Comments screen | Comment CRUD |
| `LikesBloc` | Favorites screen | Favorite posts |
| `ProfileBloc` | Profile screen | Profile, images, friendship, owned posts |
| `SearchBloc` | Search screen | Post/user search + friend requests |
| `MessagesBloc` | Messages screen | Conversations and friends |
| `ChatBloc` | Chat screen | Messages and sending |

Repositories are provided once in `app.dart` with `MultiRepositoryProvider`; screens receive only the BLoC they need.

---

## 🚀 Getting started

### Requirements

- Flutter **3.41+**
- Dart **3.11+**

### Run

```bash
flutter pub get
flutter run
```

### Backend

All endpoints live in `lib/core/constants/api_constants.dart`.

```dart
static const String baseUrl = 'https://social-api-30ta.onrender.com';
static const String storageUrl = '$baseUrl/storage';
```

Change `baseUrl` in that single file to point the app at another server.

---

## ✅ Quality checks

```bash
flutter analyze
flutter test
```

Both commands run automatically on every push and pull request through GitHub Actions (`.github/workflows/flutter_ci.yml`).

---

## 🌍 Localization

The app supports **Arabic** and **English** and follows the device locale automatically:

- UI strings use `context.tr('نص عربي', 'English text')`.
- Direction uses `context.appTextDirection`.
- Relative dates are formatted by `DateFormatter`.

---

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/my-feature`
2. Keep the feature-first structure and add a repository + BLoC for new screens.
3. Run `flutter analyze` and `flutter test` before opening a pull request.

---

## 📄 License

Released under the [MIT License](LICENSE).

---

## العربية

تطبيق تواصل اجتماعي ثنائي اللغة (عربي / إنجليزي) مبني بـ **Flutter** وهيكلة **BLoC** منظمة حسب الميزات.

- تسجيل الدخول والتسجيل واستعادة الجلسة.
- المنشورات والتفاعلات والتعليقات والمفضلة.
- الإشعارات والبحث والملف الشخصي والرسائل.
- رفع الصور، والمشاركة، ودعم RTL.
- كل شاشة مرتبطة بـ BLoC و Events / States، وكل ميزة لها Repository مستقل.

لتشغيل المشروع:

```bash
flutter pub get
flutter run
```
