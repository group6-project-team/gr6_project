import 'trip_api.dart';

/// Demo cases used by tests when a [ConfigurableTripApi] is injected.
enum MockScenario {
  success,
  partial,
  empty,
  planningUnavailable,
  planningFailed,
  networkError,
  unexpected,
}

/// Test-only Backend stand-in. The release factory never constructs this.
abstract class ConfigurableTripApi implements TripApi {
  MockScenario get scenario;
  set scenario(MockScenario value);
}
