/// Signed-in user returned by Backend login/register.
class AuthSession {
  const AuthSession({
    required this.email,
    this.displayName,
    this.userId,
    this.token,
    this.expiresAt,
  });

  final String email;
  final String? displayName;
  final String? userId;
  final String? token;
  final DateTime? expiresAt;

  bool get isExpired =>
      expiresAt != null && !expiresAt!.isAfter(DateTime.now());

  String get greetingName {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name.split(' ').first;
    }
    return email.split('@').first;
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        if (displayName != null) 'name': displayName,
        if (userId != null) 'userId': userId,
        if (token != null) 'token': token,
        if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      };

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final email = json['email'] as String? ?? '';
    if (email.isEmpty) {
      throw const FormatException('Auth session is missing email.');
    }
    final rawExpiry = json['expiresAt'];
    return AuthSession(
      email: email,
      displayName: json['name'] as String? ?? json['displayName'] as String?,
      userId: json['userId']?.toString(),
      token: json['token'] as String?,
      expiresAt: rawExpiry is String && rawExpiry.isNotEmpty
          ? DateTime.tryParse(rawExpiry)
          : null,
    );
  }
}
