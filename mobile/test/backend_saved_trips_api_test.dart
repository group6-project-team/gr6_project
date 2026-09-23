import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/models/saved_trips_api_exception.dart';
import 'package:mobile/models/trip_plan.dart';
import 'package:mobile/services/backend_saved_trips_api.dart';

BackendSavedTripsApi _api(Future<http.Response> Function(http.Request) handler) {
  return BackendSavedTripsApi(
    baseUrl: 'https://gr6-tripplanning-api.runasp.net/',
    client: MockClient((request) async => handler(request)),
  );
}

final _plan = TripPlan.fromJson({
  'destinationId': 'istanbul',
  'requestedDays': 2,
  'days': [
    {
      'dayNumber': 1,
      'places': [
        {'id': 'geoapify:place-id', 'name': 'Place Name'},
      ],
    },
  ],
  'warnings': [],
});

void main() {
  test('save posts the preview snapshot with a Bearer token', () async {
    final api = _api((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/saved-trips');
      expect(request.headers['Authorization'], 'Bearer jwt-token');
      expect(request.body, contains('"destinationId":"istanbul"'));
      expect(request.body, contains('"trip"'));
      return http.Response(
        '''
{
  "id": 1,
  "destinationId": "istanbul",
  "requestedDays": 2,
  "trip": {
    "destinationId": "istanbul",
    "requestedDays": 2,
    "days": [{"dayNumber": 1, "places": [{"id": "geoapify:place-id", "name": "Place Name"}]}],
    "warnings": []
  },
  "createdAt": "2026-09-22T19:04:32Z"
}
''',
        201,
      );
    });

    final saved = await api.saveTrip(token: 'jwt-token', plan: _plan);
    expect(saved.id, '1');
    expect(saved.trip?.days.first.places.first.name, 'Place Name');
  });

  test('list accepts a raw array of the current user trips', () async {
    final api = _api((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/api/saved-trips');
      return http.Response(
        '''
[
  {
    "id": 1,
    "destinationId": "istanbul",
    "requestedDays": 2,
    "createdAt": "2026-09-22T19:04:32Z"
  }
]
''',
        200,
      );
    });

    final trips = await api.listTrips(token: 'jwt-token');
    expect(trips, hasLength(1));
    expect(trips.first.destinationId, 'istanbul');
  });

  test('missing trip is 404', () async {
    final api = _api((request) async => http.Response('', 404));
    expect(
      () => api.getTrip(token: 'jwt-token', id: '9'),
      throwsA(
        isA<SavedTripsApiException>().having(
          (error) => error.code,
          'code',
          SavedTripsApiException.notFound,
        ),
      ),
    );
  });

  test('delete uses 204 and the trip id', () async {
    final api = _api((request) async {
      expect(request.method, 'DELETE');
      expect(request.url.path, '/api/saved-trips/1');
      return http.Response('', 204);
    });

    await api.deleteTrip(token: 'jwt-token', id: '1');
  });
}
