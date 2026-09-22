import '../models/auth_session.dart';

abstract class AuthApi {
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  });

  Future<void> logout(String token);
}
