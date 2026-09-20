import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/trip_api_exception.dart';
import 'package:mobile/models/trip_request.dart';
import 'support/mock_trip_api.dart';

void main() {
  const request = TripPlanRequest(
    destinationId: 'istanbul',
    days: 4,
    interests: [],
  );

  test('success keeps every requested day and at most 3 places', () async {
    final api = MockTripApi(delay: Duration.zero);
    final plan = await api.planTrip(request);

    expect(plan.days.map((day) => day.dayNumber), [1, 2, 3, 4]);
    expect(plan.warnings, isEmpty);
    for (final day in plan.days) {
      expect(day.places.length, inInclusiveRange(1, 3));
    }
  });

  test('partial keeps empty days and a coverage warning', () async {
    final api = MockTripApi(
      delay: Duration.zero,
      scenario: MockScenario.partial,
    );
    final plan = await api.planTrip(request);

    expect(plan.days.length, 4);
    expect(plan.warnings.map((warning) => warning.code), ['PARTIAL_ITINERARY']);
    expect(plan.days.last.places, isEmpty);
  });

  test('empty result still returns every requested day', () async {
    final api = MockTripApi(
      delay: Duration.zero,
      scenario: MockScenario.empty,
    );
    final plan = await api.planTrip(request);

    expect(plan.days.length, 4);
    expect(plan.warnings.map((warning) => warning.code), ['NO_PLACES_AVAILABLE']);
    expect(plan.days.every((day) => day.places.isEmpty), isTrue);
  });

  test('no-interests request is valid', () async {
    final api = MockTripApi(delay: Duration.zero);
    final plan = await api.planTrip(request);
    expect(plan.requestedDays, 4);
  });

  test('PLANNING_SERVICE_UNAVAILABLE is a retryable API error', () async {
    final api = MockTripApi(
      delay: Duration.zero,
      scenario: MockScenario.planningUnavailable,
    );

    expect(
      () => api.planTrip(request),
      throwsA(
        isA<TripApiException>().having(
          (error) => error.code,
          'code',
          TripApiException.planningUnavailable,
        ),
      ),
    );
  });

  test('PLANNING_FAILED is a retryable API error', () async {
    final api = MockTripApi(
      delay: Duration.zero,
      scenario: MockScenario.planningFailed,
    );

    expect(
      () => api.planTrip(request),
      throwsA(
        isA<TripApiException>().having(
          (error) => error.code,
          'code',
          TripApiException.planningFailed,
        ),
      ),
    );
  });
}
