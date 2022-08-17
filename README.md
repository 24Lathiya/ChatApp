# chat_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

- Configure Firebase Authentication for Android
  - get package name (search for package=")
  - get google_service.json and add to android app folder.
  - follow firebase instruction to implement dependencies.
  - app gradle -->  minimumSdk 21 & multiDexEnable true
  
- Configure Firebase Authentication for iOS
  - get package name (search for package=")
  - get GoogleService-Info.plist and add to ios Runner folder.
  - ios/Podfile --> platform :ios, '12.0'
  - terminal --> cd ios --> pod install
  
- Configure Firebase Cloud Filestore
  - create firebase cloud
  - change rules (allow read, write : if false - > if(request.auth != null))