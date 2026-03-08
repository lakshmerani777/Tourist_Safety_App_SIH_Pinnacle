# Tourist Safety App — SIH Pinnacle

**Smart Tourist Safety Monitoring & Incident Response System**

A Flutter mobile app with a Django backend for tourist safety: onboarding, SOS, map view, incident reporting, alerts, and emergency contacts.

---

## Project structure

```
Tourist_Safety_App_SIH_Pinnacle/
├── lib/                          # Flutter app source
│   ├── main.dart
│   ├── core/                      # Shared app logic & UI
│   │   ├── router/                # go_router routes
│   │   ├── theme/                 # Colors, typography, theme
│   │   └── widgets/               # Reusable widgets
│   ├── providers/                 # Riverpod state (SOS, location, onboarding, etc.)
│   └── screens/                   # App screens
│       ├── onboarding/            # Onboarding steps (phone, identity, travel, etc.)
│       ├── splash_screen.dart
│       ├── registration_screen.dart
│       ├── home_dashboard_screen.dart
│       ├── map_view_screen.dart
│       ├── sos_activated_screen.dart
│       ├── emergency_contacts_screen.dart
│       ├── report_incident_screen.dart
│       ├── alerts_screen.dart
│       └── profile_screen.dart
├── backend/
│   └── PinnacleBackend/           # Django project
│       ├── manage.py
│       ├── requirements.txt
│       ├── PinnacleBackend/       # Project settings (settings.py, urls.py)
│       └── backend/               # App: views, urls, models
├── android/                       # Android native
├── ios/                           # iOS native
├── linux/, macos/, web/, windows/ # Other Flutter platforms
└── pubspec.yaml
```

---

## Flutter app

### Requirements

- Flutter SDK **>=3.7.2**
- Dart **>=3.7.2**

### Main dependencies

- **go_router** — navigation
- **flutter_riverpod** — state management
- **google_maps_flutter** — map (Google Maps)
- **geolocator** — location
- **permission_handler** — permissions
- **image_picker** — photos
- **google_fonts** — typography

### Run the app

```bash
# From project root
flutter pub get
flutter run
```

Use `flutter run -d <device_id>` to pick a device. For Android emulator or a connected device, run `flutter devices` first.

### Google Maps setup

The map screen uses **Google Maps**. The API key is stored on the **backend** (see Django backend below) and read by the app as follows:

- **iOS:** The app fetches the key from the backend at startup (splash) and sets it via the native Maps SDK. No manual key in the app.
- **Android:** The Maps SDK reads the key from the app manifest at build time. Set `GOOGLE_MAPS_API_KEY=your_key` in `android/gradle.properties` for local or CI builds. Use the same value as in the backend `.env`. **Do not commit the key** to the repo (keep it only in local `gradle.properties` or in CI secrets).

1. **Google Cloud Console:** Create a project, enable **Maps SDK for Android** and **Maps SDK for iOS**, and create an API key. Restrict it by application (Android package name, iOS bundle ID) and by API (Maps SDK for Android / iOS only) for security.
2. **Backend:** Put the key in `backend/PinnacleBackend/.env` as `GOOGLE_MAPS_API_KEY=...` (see Backend setup below).
3. **Android only:** Add `GOOGLE_MAPS_API_KEY=your_key` to `android/gradle.properties` (do not commit this file if it contains the key, or add only the key in a local override).

Until the key is set on the backend (and on Android in `gradle.properties`), the map may appear blank or show an error.

---

## Django backend

### Requirements

- Python 3.x
- Virtual environment recommended

### Setup

```bash
cd backend/PinnacleBackend

# Create and activate a virtual environment (optional)
python -m venv .venv
source .venv/bin/activate   # Linux/macOS
# .venv\Scripts\activate    # Windows

# Install dependencies
pip install -r requirements.txt

# Copy .env.example to .env and set secrets (do not commit .env)
cp .env.example .env
# Edit .env: set SECRET_KEY, GOOGLE_MAPS_API_KEY, and optionally DEBUG.
```

The project uses **Django REST Framework** (see `settings.py`). If you get import errors for `rest_framework`, add it:

```bash
pip install djangorestframework
```

Then add `djangorestframework` to `requirements.txt` if not already there.

### Database & run server

```bash
# Apply migrations (SQLite by default)
python manage.py migrate

# Run development server (default: http://127.0.0.1:8000/)
python manage.py runserver
```

The root URL serves a simple JSON API (`{"message": "Hello, world!"}`). The app fetches the Google Maps API key from `GET /api/config/maps-key/` (reads `GOOGLE_MAPS_API_KEY` from `.env`). Admin is at `/admin/` (create a superuser with `python manage.py createsuperuser` if needed).

---

## App features (from routes & screens)

| Route     | Screen / feature          |
|----------|----------------------------|
| `/splash` | Splash                     |
| `/register` | Registration (e.g. phone/OTP) |
| `/onboarding` | Multi-step onboarding     |
| `/home`  | Home dashboard             |
| `/sos`   | SOS activated              |
| `/map`   | Map view                   |
| `/emergency` | Emergency contacts       |
| `/report` | Report incident           |
| `/alerts` | Alerts                    |
| `/profile` | Profile                   |

Onboarding steps in `lib/screens/onboarding/` include: phone, identity, travel, emergency, stay, medical, and consent.

---

## License

Not specified in the repo — add your license file and section as needed.
