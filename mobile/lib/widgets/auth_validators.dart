/// Shared form checks for the auth UI shell. Backend rules can tighten later.
class AuthValidators {
  /// Local part must be at least 3 characters so stubs like t@gmail.com fail.
  static final _email = RegExp(
    r'^[A-Za-z0-9](?:[A-Za-z0-9._%+-]{2,})@[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)*\.[A-Za-z]{2,}$',
  );

  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Email is required';
    }
    if (!_email.hasMatch(text)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) {
      return 'Password is required';
    }
    if (text.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
