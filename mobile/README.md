# Team 6 Flutter client

Trip input + result flow for the Flutter track. Default mode is **mock**, so this card works without the ASP.NET Backend.

## Run

```bash
cd mobile
flutter pub get
flutter run
```

You should see a **MOCK** chip in the app bar. No Backend process is required.

## Switch mock / real

Edit `lib/config/app_config.dart`:

```dart
static const bool useMockApi = true; // false = real ASP.NET only
static const String backendBaseUrl = 'http://10.0.2.2:5080';
```

| Device | Backend URL |
|---|---|
| Android emulator | `http://10.0.2.2:PORT` |
| Windows / Chrome / iOS simulator | `http://localhost:PORT` |
| Physical phone | `http://YOUR_LAN_IP:PORT` |

Put the **ASP.NET public base URL** only. Never a FastAPI URL and never a Places provider URL.

When OpenAPI/Swagger exists, match these paths (or change them in `lib/services/backend_trip_api.dart`):

- `GET /trip-options`
- `POST /trips/plan`

## Mock scenarios

The **Mock scenario** chips are demo-only. They are not sent to the real Backend.

- Success — every requested day has places (max 3 / day)
- Partial — later days can be empty + `PARTIAL_ITINERARY`
- Empty — all requested days exist, places are empty + `NO_PLACES_AVAILABLE`
- `PLANNING_SERVICE_UNAVAILABLE`
- `PLANNING_FAILED`
- Network / no JSON
- Unknown future error code (generic retry text)

JSON samples live in `assets/mocks/`.

## What this card does not include

Local saved trips, login, budget, maps, FastAPI/Places calls, or planning logic.
