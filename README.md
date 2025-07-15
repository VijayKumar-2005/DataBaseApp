# Flutter SQLite + Firestore App with Natural Language Interface

This Flutter application integrates **Firebase Authentication**, **Cloud Firestore**, and **SQLite (sqflite)** to provide a hybrid local-cloud database experience. The core concept of the app is to allow users to create, manage, and interact with SQLite databases on their device using natural language commands via Genkit NLP.

## 🔑 Key Features

* **User Authentication** via Firebase Auth
* **User Profiles and Metadata Storage** using Firestore
* **Create SQLite Databases** dynamically through user input
* **Execute Raw SQLite Commands** using a built-in SQL terminal
* **Natural Language to SQL Translation** powered by Genkit NLP
* **Upload, Edit, and Export SQLite Database Files**

## 🔧 Technologies Used

* **Flutter** & **Dart**
* **Firebase Auth** (for user login/signup)
* **Cloud Firestore** (for storing user data/config)
* **sqflite** (for on-device SQLite databases)
* **path\_provider** (for locating and exporting database files)
* **Genkit** (for natural language to SQL command generation)

## 🧠 Example Use Case

1. User signs in using Firebase Authentication.
2. The app stores user info and preferences in Firestore.
3. User creates a new SQLite database on their device.
4. User enters a natural language query like: *"Create a table for students with id, name, and age."*
5. Genkit NLP converts this to a valid SQL command.
6. The command is executed using `sqflite`, and results are shown in the UI.
7. Users can export or upload database files as `.db` files.

## 📦 Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.5.0
  firebase_auth: ^5.5.0
  cloud_firestore: ^4.14.0
  sqflite: ^2.3.0
  path_provider: ^2.1.2
  path: ^1.8.3
  genkit: ^latest
```

## 🚀 How to Run

1. Clone the repository.
2. Run `flutter pub get`.
3. Add your Firebase project config (GoogleService-Info.plist / google-services.json).
4. Run the app: `flutter run`.
