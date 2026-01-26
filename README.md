# MySeries - Series Tracking App (Graduaatsproef 2025 - 2026)

Een Flutter-applicatie waarmee gebruikers hun favoriete series kunnen volgen, beoordelen en beheren.

## Inhoudsopgave

- [Over het Project](#over-het-project)
- [Functies](#functies)
- [Requirements](#requirements)
- [Installatie](#installatie)
- [Projectstructuur](#projectstructuur)
- [Technologieën](#technologieën)

## Over het Project

**MySeries** is een cross-platform Flutter-applicatie die gebruikers in staat stelt om:
- Series te ontdekken en toevoegen aan hun watchlist
- Episodes van series volgen en markeren als gekeken
- Series beoordelen 
- Seizoen- en episode-informatie bekijken
- Een persoonlijke bibliotheek met favoriete series beheren

Dit project is gemaakt als onderdeel van een afstudeerwerk (GraduaatsProef) 2025-2026.

## Functies

- **Authenticatie**: Firebase Authentication voor veilige inloggen
- **Series Management**: Beheer je series in watchlist en markeer ze als favorieten
- **Beoordelingen**: Geef ratings aan series
- **Real-time Sync**: Synchronisatie met Firebase Firestore
- **Multi-platform**: Ondersteunt Android, iOS, Web, Windows, Linux, en macOS
- **Moderne UI**: Gebruiksvriendelijke interface met Flutter widgets

## Requirements

- **Flutter SDK**: ^3.10.4 (https://docs.flutter.dev/install/quick)
- **Dart SDK**: ^3.10.4 (https://dart.dev/get-dart)
- **Android Studio**: Virtual device (Android)

## Installatie

### 1. Repository klonen
```bash
git clone <repository-url>
cd myseries
```

### 2. Flutter dependencies installeren
```bash
flutter pub get
```

### 3. Virtual device starten
```bash
Via Android Studio starten
```

### 4. App starten
```bash
flutter run
```

## Projectstructuur

```
lib/
├── main.dart                 # Application entry point
├── authentication/           # Authenticatie logica
│   └── auth.dart
├── config/                   # Configuratie bestanden
│   ├── api_keys.dart
│   └── firebase.dart
├── models/                   # Data models
│   ├── episodes.dart
│   ├── rated_series.dart
│   ├── seasons.dart
│   ├── serie_detail.dart
│   ├── series.dart
│   └── watchlist.dart
├── navigation/               # Navigatie configuratie
├── screens/                  # UI Schermen
├── services/                 # Services (API calls, etc.)
├── widgets/                  # Herbruikbare widgets
└── ...
```

## Technologieën

### Frameworks & Libraries
- **Flutter**: UI framework
- **Firebase**: Backend services
  - Authentication
  - Cloud Firestore

### Platforms
- Android
- iOS
- Web
- Windows
- Linux
- macOS





