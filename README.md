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
- **flutter_map** + **latlong2** — map
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

The root URL serves a simple JSON API (`{"message": "Hello, world!"}`). Admin is at `/admin/` (create a superuser with `python manage.py createsuperuser` if needed).

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
