# Dash - Shared List App

A collaborative list management app built with SwiftUI and Firebase.

## 📱 Features

- **Real-time Collaboration** - Share lists and sync instantly across devices
- **Achievement System** - Unlock colors by creating items
- **Universal Links** - Share lists via links
- **Bulk Operations** - Mark all, clear all, delete efficiently
- **Offline Support** - Full offline persistence with automatic sync
- **Apple & Google Sign-In** - Multiple authentication options

## 🏗️ Architecture

- **SwiftUI** - Modern declarative UI
- **Firebase Firestore** - Real-time database with offline support
- **Firebase Auth** - Authentication (Apple, Google, Email/Password)
- **OSLog** - Production logging and monitoring
- **MVVM Pattern** - Clean separation of concerns

## 📁 Project Structure

```
dash/
├── Model/
│   ├── ListManager.swift       # List & item operations
│   ├── UserManager.swift       # User data management
│   └── RewardsManager.swift    # Achievement system
├── Views/
│   ├── Auth/                   # Login & signup
│   ├── Onboarding/             # First-run experience
│   └── Pages/                  # Main app screens
├── Utilities/
│   ├── AppLogger.swift         # Centralized logging
│   ├── AppleSignInManager.swift
│   └── GoogleSignInManager.swift
└── dashApp.swift               # App entry point
```

## 🔐 Security

- Comprehensive Firestore security rules
- User authentication required for all operations
- List access restricted to members only
- Creator-only deletion rights

## 📝 Documentation

- **`PRODUCTION_CHECKLIST.md`** - Pre-launch checklist
- **`LEGAL_REQUIREMENTS.md`** - App Store compliance guide
- **`LOGGING_GUIDE.md`** - Production logging reference
- **`dash/Views/Onboarding/README.md`** - Onboarding flow details

## 🚀 Getting Started

1. Open `dash.xcodeproj` in Xcode
2. Configure Firebase (GoogleService-Info.plist)
3. Update bundle identifier
4. Build and run!

## 📱 Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## 🔧 Configuration

Before production release:
1. Update contact emails in Privacy Policy & Terms
2. Deploy Firestore security rules
3. Configure App Store Connect privacy details
4. Test account deletion flow

See **`PRODUCTION_CHECKLIST.md`** for complete details.

## 📊 Monitoring

View production logs:
```bash
# Stream live logs from device
log stream --predicate 'subsystem == "com.dash.app"' --level debug

# View last 24 hours
log show --predicate 'subsystem == "com.dash.app"' --last 24h

# Filter by category
log show --predicate 'subsystem == "com.dash.app" AND category == "auth"'
```

## 📄 License

All rights reserved.
