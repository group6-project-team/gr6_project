import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/models/trip_api_exception.dart';
import 'package:mobile/models/trip_plan.dart';
import 'package:mobile/models/trip_request.dart';
import 'package:mobile/services/backend_trip_api.dart';

const _istanbulBody = '''
{
  "destinationId": "istanbul",
  "days": [
    {
      "dayNumber": 1,
      "places": [
        { "id": "ist-001", "name": "Hagia Sophia", "description": "Historic landmark in Istanbul.", "address": "Sultanahmet, Istanbul" },
        { "id": "ist-002", "name": "Topkapi Palace" },
        { "id": "ist-003", "name": "Blue Mosque" }
      ]
    },
    {
      "dayNumber": 2,
      "places": [
        { "id": "ist-004", "name": "Grand Bazaar" },
        { "id": "ist-005", "name": "Galata Tower" }
      ]
    }
  ],
  "warnings": []
}
''';

const _romePartialBody = '''
{
  "destinationId": "rome",
  "days": [
    { "dayNumber": 1, "places": [{ "id": "rom-001", "name": "Colosseum" }] },
    { "dayNumber": 2, "places": [{ "id": "rom-002", "name": "Roman Forum" }] },
    { "dayNumber": 3, "places": [] }
  ],
  "warnings": [
    { "code": "PARTIAL_ITINERARY", "message": "There are not enough places to cover every requested day." }
  ]
}
''';

const _aqabaEmptyBody = '''
{
  "destinationId": "aqaba",
  "days": [
    { "dayNumber": 1, "places": [] },
    { "dayNumber": 2, "places": [] }
  ],
  "warnings": [
    { "code": "NO_PLACES_AVAILABLE", "message": "No places are available for the selected destination." }
  ]
}
''';

const _validationBody = '''
{
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": {
    "DestinationId": ["The selected destination is not supported."]
  }
}
''';

BackendTripApi _api(Future<http.Response> Function(http.Request) handler) {
  return BackendTripApi(
    baseUrl: 'http://localhost:5185',
    client: MockClient((request) async => handler(request)),
  );
}

void main() {
  test('options come from the Stage 1 catalog, not GET /trip-options', () async {
    var httpCalls = 0;
    final api = _api((request) async {
      httpCalls++;
      return http.Response('{}', 200);
    });

    final options = await api.getOptions();
    expect(httpCalls, 0);
    expect(options.destinations.map((item) => item.id), ['istanbul', 'rome', 'aqaba']);
  });

  test('posts to /trip-plans/preview and uses request days when requestedDays is absent', () async {
    late http.Request captured;
    final api = _api((request) async {
      captured = request;
      return http.Response(_istanbulBody, 200, headers: {'content-type': 'application/json'});
    });

    final plan = await api.planTrip(
      const TripPlanRequest(destinationId: 'istanbul', days: 2, interests: []),
    );

    expect(captured.method, 'POST');
    expect(captured.url.path, '/trip-plans/preview');
    expect(plan.requestedDays, 2);
    expect(plan.days.map((day) => day.dayNumber), [1, 2]);
    expect(plan.days.first.places.first.name, 'Hagia Sophia');
    expect(plan.warnings, isEmpty);
  });

  test('parses structured partial warnings and keeps empty days', () async {
    final api = _api(
      (_) async => http.Response(_romePartialBody, 200, headers: {'content-type': 'application/json'}),
    );

    final plan = await api.planTrip(
      const TripPlanRequest(destinationId: 'rome', days: 3, interests: []),
    );

    expect(plan.days.length, 3);
    expect(plan.days.last.places, isEmpty);
    expect(plan.warnings.single.code, 'PARTIAL_ITINERARY');
  });

  test('parses empty Aqaba fixture with NO_PLACES_AVAILABLE', () async {
    final api = _api(
      (_) async => http.Response(_aqabaEmptyBody, 200, headers: {'content-type': 'application/json'}),
    );

    final plan = await api.planTrip(
      const TripPlanRequest(destinationId: 'aqaba', days: 2, interests: []),
    );

    expect(plan.days.every((day) => day.places.isEmpty), isTrue);
    expect(plan.warnings.single.code, 'NO_PLACES_AVAILABLE');
  });

  test('maps ASP.NET validation problem details to INVALID_DESTINATION', () async {
    final api = _api((_) async => http.Response(_validationBody, 400));

    expect(
      () => api.planTrip(
        const TripPlanRequest(destinationId: 'amman', days: 3, interests: []),
      ),
      throwsA(
        isA<TripApiException>().having(
          (error) => error.code,
          'code',
          TripApiException.invalidDestination,
        ),
      ),
    );
  });

  test('malformed success JSON becomes a safe API error, not a fake itinerary', () async {
    final api = _api((_) async => http.Response('<html>nope</html>', 200));

    expect(
      () => api.planTrip(
        const TripPlanRequest(destinationId: 'istanbul', days: 3, interests: []),
      ),
      throwsA(
        isA<TripApiException>().having(
          (error) => error.code,
          'code',
          TripApiException.unexpected,
        ),
      ),
    );
  });

  test('unknown error codes stay retryable without crashing', () async {
    final api = _api(
      (_) async => http.Response('{"code":"FUTURE_UNKNOWN_CODE","message":"nope"}', 500),
    );

    try {
      await api.planTrip(
        const TripPlanRequest(destinationId: 'istanbul', days: 3, interests: []),
      );
      fail('expected TripApiException');
    } on TripApiException catch (error) {
      expect(error.code, 'FUTURE_UNKNOWN_CODE');
      expect(error.userMessage, 'Something went wrong. Please try again.');
    }
  });

  test('TripPlan parser accepts warning objects and ignores extra place fields', () {
    final plan = TripPlan.fromJson(
      {
        'destinationId': 'rome',
        'days': [
          {
            'dayNumber': 1,
            'places': [
              {
                'id': 'rom-001',
                'name': 'Colosseum',
                'categoryIds': ['historic_site'],
              },
            ],
          },
        ],
        'warnings': [
          {'code': 'PARTIAL_ITINERARY', 'message': 'Not enough places.'},
        ],
      },
      requestedDays: 3,
    );

    expect(plan.requestedDays, 3);
    expect(plan.days.single.places.single.rating, isNull);
    expect(plan.warnings.single.message, 'Not enough places.');
  });
}
