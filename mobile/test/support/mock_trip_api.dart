import 'package:mobile/data/stage1_catalog.dart';
import 'package:mobile/models/trip_api_exception.dart';
import 'package:mobile/models/trip_options.dart';
import 'package:mobile/models/trip_plan.dart';
import 'package:mobile/models/trip_request.dart';
import 'package:mobile/services/mock_scenario.dart';

export 'package:mobile/services/mock_scenario.dart';

/// Local fake Backend for tests only. Not part of the release app.
class MockTripApi implements ConfigurableTripApi {
  MockTripApi({
    this.delay = const Duration(milliseconds: 700),
    this.scenario = MockScenario.success,
  });

  Duration delay;
  @override
  MockScenario scenario;
  int planCallCount = 0;

  @override
  Future<TripOptions> getOptions() async {
    await _wait();
    return Stage1Catalog.options;
  }

  @override
  Future<TripPlan> planTrip(TripPlanRequest request) async {
    planCallCount++;
    await _wait();
    _validate(request);

    switch (scenario) {
      case MockScenario.success:
        return _plan(request, filledDays: request.days, warnings: const []);
      case MockScenario.partial:
        final filled = request.days <= 1 ? 0 : (request.days / 2).ceil();
        return _plan(
          request,
          filledDays: filled,
          warnings: const [
            PlanningWarning(
              code: 'PARTIAL_ITINERARY',
              message: 'There are not enough places to cover every requested day.',
            ),
          ],
        );
      case MockScenario.empty:
        return _plan(
          request,
          filledDays: 0,
          warnings: const [
            PlanningWarning(
              code: 'NO_PLACES_AVAILABLE',
              message: 'No places are available for the selected destination.',
            ),
          ],
        );
      case MockScenario.planningUnavailable:
        throw const TripApiException(
          code: TripApiException.planningUnavailable,
          message: 'Planning service unavailable.',
        );
      case MockScenario.planningFailed:
        throw const TripApiException(
          code: TripApiException.planningFailed,
          message: 'Planning failed.',
        );
      case MockScenario.networkError:
        throw const TripApiException(
          code: TripApiException.networkError,
          message: 'Connection failed before any JSON arrived.',
        );
      case MockScenario.unexpected:
        throw const TripApiException(
          code: 'FUTURE_UNKNOWN_CODE',
          message: 'Internal stack traces must never reach the UI.',
        );
    }
  }

  Future<void> _wait() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
  }

  void _validate(TripPlanRequest request) {
    final knownDestination = Stage1Catalog.destinations.any(
      (item) => item.id == request.destinationId,
    );
    if (!knownDestination) {
      throw const TripApiException(
        code: TripApiException.invalidDestination,
        message: 'Unsupported destinationId.',
      );
    }

    final knownInterestIds = Stage1Catalog.interests.map((item) => item.id).toSet();
    final hasInvalidInterest = request.interests.any(
      (id) => !knownInterestIds.contains(id),
    );
    if (hasInvalidInterest) {
      throw const TripApiException(
        code: TripApiException.invalidInterest,
        message: 'Unsupported interest id.',
      );
    }
  }

  TripPlan _plan(
    TripPlanRequest request, {
    required int filledDays,
    required List<PlanningWarning> warnings,
  }) {
    final catalog = _catalog[request.destinationId] ?? const <Place>[];
    final days = <DayPlan>[];

    for (var dayNumber = 1; dayNumber <= request.days; dayNumber++) {
      if (catalog.isEmpty || dayNumber > filledDays) {
        days.add(DayPlan(dayNumber: dayNumber, places: const []));
        continue;
      }

      final start = (dayNumber - 1) * 2 % catalog.length;
      final places = <Place>[
        catalog[start],
        if (catalog.length > 1) catalog[(start + 1) % catalog.length],
        if (dayNumber.isOdd && catalog.length > 2) catalog[(start + 2) % catalog.length],
      ];
      days.add(DayPlan(dayNumber: dayNumber, places: places.take(3).toList()));
    }

    return TripPlan(
      destinationId: request.destinationId,
      requestedDays: request.days,
      days: days,
      warnings: warnings,
    );
  }

  static const Map<String, List<Place>> _catalog = {
    'istanbul': [
      Place(id: 'test-hagia-sophia', name: 'Hagia Sophia', description: 'Historic landmark in Istanbul.', address: 'Sultanahmet, Istanbul'),
      Place(id: 'test-topkapi-palace', name: 'Topkapi Palace', description: 'Historic Ottoman palace.', address: 'Fatih, Istanbul'),
      Place(id: 'test-blue-mosque', name: 'Blue Mosque', description: 'Historic mosque in Sultanahmet.', address: 'Sultanahmet, Istanbul'),
      Place(id: 'test-grand-bazaar', name: 'Grand Bazaar', description: 'Historic covered market.', address: 'Fatih, Istanbul'),
      Place(id: 'test-galata-tower', name: 'Galata Tower', description: 'Historic tower with city views.', address: 'Beyoglu, Istanbul'),
      Place(id: 'test-archaeological-museums', name: 'Istanbul Archaeological Museums', address: 'Fatih, Istanbul'),
      Place(id: 'test-basilica-cistern', name: 'Basilica Cistern', address: 'Sultanahmet, Istanbul'),
      Place(id: 'test-dolmabahce-palace', name: 'Dolmabahce Palace', address: 'Besiktas, Istanbul'),
      Place(id: 'test-spice-bazaar', name: 'Spice Bazaar', address: 'Fatih, Istanbul'),
    ],
    'rome': [
      Place(id: 'test-colosseum', name: 'Colosseum', description: 'Historic amphitheatre in Rome.', address: 'Rome, Italy'),
      Place(id: 'test-roman-forum', name: 'Roman Forum', description: 'Ancient Roman archaeological site.', address: 'Rome, Italy'),
    ],
    'aqaba': [],
  };
}
