import '../models/auth_session.dart';

abstract class AuthSessionStore {
  Future<AuthSession?> read();
  Future<void> write(AuthSession session);
  Future<void> clear();
}

/// Holds the JWT for this app run. Logout deletes it locally.
class InMemoryAuthSessionStore implements AuthSessionStore {
  AuthSession? _session;

  @override
  Future<AuthSession?> read() async {
    final session = _session;
    if (session == null) {
      return null;
    }
    if (session.isExpired) {
      _session = null;
      return null;
    }
    return session;
  }

  @override
  Future<void> write(AuthSession session) async {
    _session = session;
  }

  @override
  Future<void> clear() async {
    _session = null;
  }
}
