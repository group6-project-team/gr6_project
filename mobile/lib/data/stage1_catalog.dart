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
    InterestOption(id: 'culture', name: 'Culture'),
    InterestOption(id: 'art', name: 'Art'),
    InterestOption(id: 'nature', name: 'Nature'),
    InterestOption(id: 'adventure', name: 'Adventure'),
    InterestOption(id: 'food', name: 'Food'),
  ];

  static const options = TripOptions(
    destinations: destinations,
    interests: interests,
  );
}
