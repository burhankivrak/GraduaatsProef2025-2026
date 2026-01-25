# MySeries

Een Flutter applicatie om je favoriete TV-series te beheren, volgen en ontdekken.

## 📋 Overzicht

MySeries is een cross-platform applicatie waarmee gebruikers hun serie-collectie kunnen organiseren, kijkvoortgang kunnen bijhouden en nieuwe series kunnen ontdekken. De app maakt gebruik van The Movie Database (TMDB) API voor serie-informatie en Firebase voor gebruikersbeheer en data-opslag.

## ✨ Functies

### 🔐 Authenticatie
- Gebruikersregistratie en login
- Veilige authenticatie via Firebase Auth
- Persoonlijke gebruikersprofielen

### 📺 Serie Beheer
- **Watchlist**: Beheer je kijklijst met drie statussen:
  - 🎬 **Watching** - Series die je momenteel volgt
  - 📌 **To Watch** - Series die je nog wilt bekijken
  - ⏸️ **Paused** - Series die je tijdelijk hebt gepauzeerd
- **Favorieten**: Bewaar je favoriete series in een aparte lijst
- **Beoordelingen**: Bekijk je beoordeelde series

### 🎯 Voortgang Tracking
- Houd bij welk seizoen en welke aflevering je hebt bekeken
- Update eenvoudig je kijkvoortgang met een intuïtieve slider interface
- Seizoen- en afleveringinformatie wordt automatisch opgehaald

### 🔍 Serie Ontdekking
- Blader door populaire en trending series
- Gedetailleerde serie-informatie inclusief:
  - Poster en achtergrondafbeeldingen
  - Genres en eerste uitzenddatum
  - Seizoen- en afleveringoverzicht
  - Trailers en video's
- Zoek functionaliteit voor het vinden van specifieke series

## 🛠️ Technologieën

- **Flutter** - Cross-platform UI framework
- **Firebase**:
  - Firebase Authentication - Gebruikersbeheer
  - Cloud Firestore - Database voor watchlists, favorieten en gebruikersdata
- **TMDB API** - Serie-informatie en metadata
- **Dart 3.10.4+** - Programmeertaal

## 📱 Ondersteunde Platforms

- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ Web
- ✅ macOS
- ✅ Linux

## 🚀 Installatie

### Vereisten

- Flutter SDK (3.38.5 of hoger)
- Dart SDK (3.10.4 of hoger)
- Firebase project met Firestore en Authentication ingeschakeld
- TMDB API key

### Setup Stappen

1. **Clone de repository**
   ```bash
   git clone <repository-url>
   cd myseries
   ```

2. **Installeer dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase configuratie**
   - Plaats je `google-services.json` in `android/app/`
   - Configureer Firebase voor andere platforms indien nodig
   - Update `lib/config/firebase.dart` met je Firebase configuratie

4. **TMDB API configuratie**
   - Verkrijg een API key van [TMDB](https://www.themoviedb.org/settings/api)
   - Configureer de API key in je services

5. **Run de app**
   ```bash
   # Voor Android/iOS emulator
   flutter run
   
   # Voor Windows
   flutter run -d windows
   
   # Voor Web
   flutter run -d chrome
   ```

## 📂 Project Structuur

```
lib/
├── authentication/     # Auth wrapper en login logica
├── config/            # Firebase en app configuratie
├── models/            # Data models (Series, Watchlist, Episodes, etc.)
├── navigation/        # Navigatie en routing
├── screens/           # UI schermen
│   ├── home_screen.dart
│   ├── watchlist_screen.dart
│   ├── favorites_screen.dart
│   ├── series_detail_screen.dart
│   └── ...
├── services/          # Backend services
│   ├── watchlist_service.dart
│   ├── favorites_service.dart
│   └── tmdb_service.dart
└── widgets/           # Herbruikbare UI componenten
    └── watchlist_card.dart
```

## 🔥 Firestore Database Structuur

```
users/
└── {userId}/
    ├── watchlist/
    │   └── {seriesId}/
    │       ├── id
    │       ├── name
    │       ├── posterPath
    │       ├── genres
    │       ├── status (watching|to_watch|paused)
    │       ├── lastSeason
    │       ├── lastEpisode
    │       ├── listName (optioneel)
    │       └── addedAt (timestamp)
    └── favorites/
        └── {seriesId}/
            ├── id
            ├── name
            ├── posterPath
            ├── firstAirDate
            └── addedAt (timestamp)
```

## 🎨 Features in Detail

### Watchlist Card
- Toon serie poster en naam
- Visuele status indicator (watching/paused)
- Huidige seizoen en aflevering weergave
- Klik om voortgang te bewerken
- Navigatie naar serie details

### Episode Tracking
- Modal interface voor het updaten van voortgang
- Sliders voor seizoen en aflevering selectie
- Automatische validatie van max seizoenen/afleveringen
- Real-time synchronisatie met Firestore

## 🐛 Troubleshooting

### Firebase Index Vereist
Als je een foutmelding krijgt over een ontbrekende Firestore index:
- Klik op de link in de error message
- Dit zal automatisch de juiste index aanmaken in de Firebase Console

### Device Detection Timeout
Bij problemen met `flutter run`:
```bash
# Gebruik een specifiek apparaat
flutter run -d windows
flutter run -d chrome
flutter run -d <device-id>
```

## 📝 Licentie

Dit project is ontwikkeld als graduaatsproef 2025-2026.

## 👥 Auteur

Ontwikkeld voor GraduaatsProef 2025-2026

## 🔄 Updates

Voor de laatste updates en wijzigingen, zie de commit history.

---

**Note**: Vergeet niet om je Firebase credentials en API keys privé te houden en niet te committen naar version control.
