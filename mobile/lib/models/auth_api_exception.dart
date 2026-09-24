/// Public auth/save errors Flutter will map once Backend auth exists.
class AuthApiException implements Exception {
  const AuthApiException({required this.code, required this.message});

  static const emailTaken = 'EMAIL_TAKEN';
  static const invalidCredentials = 'INVALID_CREDENTIALS';
  static const unauthorized = 'UNAUTHORIZED';
  static const sessionExpired = 'SESSION_EXPIRED';
  static const authUnavailable = 'AUTH_UNAVAILABLE';
  static const validation = 'VALIDATION_ERROR';
  static const unexpected = 'UNEXPECTED_ERROR';

  final String code;
  final String message;

  String get userMessage {
    switch (code) {
      case emailTaken:
        return 'That email already has an account. Try logging in.';
      case invalidCredentials:
        return 'Email or password is incorrect.';
      case unauthorized:
        return 'Please log in to continue.';
      case sessionExpired:
        return 'Your session expired. Please log in again.';
      case authUnavailable:
        return 'Account service is not connected yet.';
      case validation:
        return message.isEmpty
            ? 'Please check the form and try again.'
            : message;
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  String toString() => 'AuthApiException($code)';
}
