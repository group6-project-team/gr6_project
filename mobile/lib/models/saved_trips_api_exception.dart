class SavedTripsApiException implements Exception {
  const SavedTripsApiException({required this.code, required this.message});

  static const unauthorized = 'UNAUTHORIZED';
  static const notFound = 'NOT_FOUND';
  static const unexpected = 'UNEXPECTED_ERROR';

  final String code;
  final String message;

  String get userMessage {
    switch (code) {
      case unauthorized:
        return 'Please log in to continue.';
      case notFound:
        return 'That saved trip was not found.';
      default:
        return 'Could not update saved trips. Please try again.';
    }
  }

  @override
  String toString() => 'SavedTripsApiException($code)';
}
