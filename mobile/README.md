# Team 6 Flutter client — Stage 1

Default runtime talks to Mohammad's ASP.NET Backend. Mock mode is explicit tests/dev only. A failed real request never becomes a fake itinerary.

## Run the Backend first

```bash
cd Backend/TripPlanning.Api
dotnet run --launch-profile http
```

Swagger: `http://localhost:5185/swagger`  
Public Stage 1 route: `POST /trip-plans/preview`  
There is **no** `GET /trip-options`. Flutter uses the documented catalog: Istanbul, Rome, Aqaba.

## Run Flutter

```bash
cd mobile
flutter pub get
dart analyze lib test
flutter test
flutter run
```

Use an Android emulator or Windows desktop. The HTTP client uses `dart:io`, so Chrome is not the Stage 1 proof target.

## Backend URL

Edit `lib/config/app_config.dart`:

```dart
static const bool useMockApi = false; // true only for explicit mock/demo
static const String backendBaseUrl = 'http://10.0.2.2:5185';
```

| Device | Backend URL |
|---|---|
| Android emulator | `http://10.0.2.2:5185` |
| Windows / iOS simulator | `http://localhost:5185` |
| Physical phone | `http://YOUR_LAN_IP:5185` |

ASP.NET public base URL only. Never FastAPI or Geoapify.

## Stage 1 fixtures to verify with Mohammad

- Istanbul = normal itinerary
- Rome = `PARTIAL_ITINERARY` (empty days stay empty)
- Aqaba = `NO_PLACES_AVAILABLE`
- Invalid destination / offline = error + Retry, no fake success

Interests are sent and validated; Stage 1 fake ranking does not change by interest.

## What this card does not include

Local saved trips, login, budget, maps, FastAPI/Places calls, or planning logic.
