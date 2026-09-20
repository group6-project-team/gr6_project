import '../models/trip_options.dart';

/// Stage 1 development catalog copied from Backend `FakeTripData`.
/// There is no GET /trip-options; Flutter must not pretend that route exists.
class Stage1Catalog {
  static const destinations = [
    DestinationOption(id: 'istanbul', name: 'Istanbul'),
    DestinationOption(id: 'rome', name: 'Rome'),
    DestinationOption(id: 'aqaba', name: 'Aqaba'),
  ];

  static const interests = [
    InterestOption(id: 'history', name: 'History'),
    InterestOption(id: 'landmark', name: 'Landmark'),
  ];

  static const options = TripOptions(
    destinations: destinations,
    interests: interests,
  );
}
