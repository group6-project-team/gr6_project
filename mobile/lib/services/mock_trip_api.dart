import '../models/trip_api_exception.dart';
import '../models/trip_options.dart';
import '../models/trip_plan.dart';
import '../models/trip_request.dart';
import 'trip_api.dart';

/// Demo cases the mock Backend can return.
/// The real ASP.NET API will never see this value.
enum MockScenario {
  success,
  partial,
  empty,
  planningUnavailable,
  planningFailed,
  networkError,
  unexpected,
}

/// Local fake Backend so the Flutter card can be finished without Mohammad.
class MockTripApi implements TripApi {
  MockTripApi({
    this.delay = const Duration(milliseconds: 700),
    this.scenario = MockScenario.success,
  });

  Duration delay;
  MockScenario scenario;
  int planCallCount = 0;

  static const TripOptions localOptions = TripOptions(
    destinations: [
      DestinationOption(id: 'amman', name: 'Amman'),
      DestinationOption(id: 'petra', name: 'Petra'),
      DestinationOption(id: 'aqaba', name: 'Aqaba'),
      DestinationOption(id: 'jerash', name: 'Jerash'),
    ],
    interests: [
      InterestOption(id: 'culture', name: 'Culture'),
      InterestOption(id: 'food', name: 'Food'),
      InterestOption(id: 'nature', name: 'Nature'),
      InterestOption(id: 'history', name: 'History'),
      InterestOption(id: 'shopping', name: 'Shopping'),
    ],
  );

  @override
  Future<TripOptions> getOptions() async {
    await _wait();
    return localOptions;
  }

  @override
  Future<TripPlan> planTrip(TripPlanRequest request) async {
    planCallCount++;
    await _wait();
    _validate(request);

    switch (scenario) {
      case MockScenario.success:
        return _plan(
          request,
          filledDays: request.days,
          warnings: const [],
        );
      case MockScenario.partial:
        final filled = request.days <= 1 ? 0 : (request.days / 2).ceil();
        return _plan(
          request,
          filledDays: filled,
          warnings: const ['PARTIAL_ITINERARY'],
        );
      case MockScenario.empty:
        return _plan(
          request,
          filledDays: 0,
          warnings: const ['NO_PLACES_AVAILABLE'],
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
    final knownDestination = localOptions.destinations.any(
      (item) => item.id == request.destinationId,
    );
    if (!knownDestination) {
      throw const TripApiException(
        code: TripApiException.invalidDestination,
        message: 'Unsupported destinationId.',
      );
    }

    final knownInterestIds = localOptions.interests.map((item) => item.id).toSet();
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
    required List<String> warnings,
  }) {
    final catalog = _catalog[request.destinationId] ?? _catalog['amman']!;
    final days = <DayPlan>[];

    for (var dayNumber = 1; dayNumber <= request.days; dayNumber++) {
      if (dayNumber > filledDays) {
        days.add(DayPlan(dayNumber: dayNumber, places: const []));
        continue;
      }

      final start = (dayNumber - 1) * 2 % catalog.length;
      final places = <Place>[
        catalog[start],
        catalog[(start + 1) % catalog.length],
        if (dayNumber.isOdd) catalog[(start + 2) % catalog.length],
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
    'amman': [
      Place(
        id: 'amman-citadel',
        name: 'Amman Citadel',
        description: 'Hilltop ruins overlooking downtown Amman.',
        address: 'K. Ali Ben Al-Hussein St, Amman',
        rating: 4.6,
      ),
      Place(
        id: 'roman-theatre',
        name: 'Roman Theatre',
        description: 'Restored 2nd-century theatre in the city center.',
        address: 'Al-Hashemi St, Amman',
        rating: 4.5,
      ),
      Place(
        id: 'rainbow-street',
        name: 'Rainbow Street',
        description: 'Cafes, viewpoints, and evening walks in Jabal Amman.',
        address: 'Rainbow St, Amman',
      ),
      Place(
        id: 'jordan-museum',
        name: 'The Jordan Museum',
        address: 'Ras Al Ain, Amman',
        rating: 4.4,
      ),
    ],
    'petra': [
      Place(id: 'siq', name: 'The Siq', description: 'The main entrance canyon.'),
      Place(id: 'treasury', name: 'The Treasury', rating: 4.9),
      Place(id: 'monastery', name: 'The Monastery'),
      Place(id: 'royal-tombs', name: 'Royal Tombs'),
    ],
    'aqaba': [
      Place(id: 'south-beach', name: 'South Beach', description: 'Red Sea swimming and snorkel access.'),
      Place(id: 'aqaba-fort', name: 'Aqaba Fort'),
      Place(id: 'sharif-hussein', name: 'Sharif Hussein Bin Ali Mosque'),
      Place(id: 'aqaba-museum', name: 'Aqaba Archaeological Museum'),
    ],
    'jerash': [
      Place(id: 'hadrian-gate', name: "Hadrian's Arch"),
      Place(id: 'oval-plaza', name: 'Oval Plaza'),
      Place(id: 'artemis', name: 'Temple of Artemis'),
      Place(id: 'south-theatre', name: 'South Theatre', rating: 4.7),
    ],
  };
}
