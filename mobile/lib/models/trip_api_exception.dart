/// Failures Flutter must handle without showing internal .NET/Python details.
class TripApiException implements Exception {
  const TripApiException({required this.code, required this.message});

  static const planningUnavailable = 'PLANNING_SERVICE_UNAVAILABLE';
  static const planningFailed = 'PLANNING_FAILED';
  static const networkError = 'NETWORK_ERROR';
  static const unexpected = 'UNEXPECTED_ERROR';
  static const invalidDestination = 'INVALID_DESTINATION';
  static const invalidInterest = 'INVALID_INTEREST';
  static const placesProviderUnavailable = 'PLACES_PROVIDER_UNAVAILABLE';

  final String code;
  final String message;

  /// Safe text for the UI. Unknown future codes still get a generic retry.
  String get userMessage {
    switch (code) {
      case planningUnavailable:
        return 'The planning service is unavailable right now. Please try again.';
      case planningFailed:
        return 'We could not create this itinerary. Please try again.';
      case networkError:
        return 'Could not reach the server. Check your connection and retry.';
      case invalidDestination:
        return 'That destination is not supported. Options will refresh.';
      case invalidInterest:
        return 'One of the interests is not supported. Options will refresh.';
      case placesProviderUnavailable:
        return 'Place data is unavailable right now. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  String toString() => 'TripApiException($code)';
}
