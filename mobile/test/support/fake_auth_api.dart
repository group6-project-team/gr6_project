import 'package:mobile/models/auth_api_exception.dart';
import 'package:mobile/models/auth_session.dart';
import 'package:mobile/services/auth_api.dart';

class FakeAuthApi implements AuthApi {
  FakeAuthApi({this.failLogin = false});

  bool failLogin;
  int loginCalls = 0;
  int registerCalls = 0;
  int logoutCalls = 0;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    loginCalls += 1;
    if (failLogin) {
      throw const AuthApiException(
        code: AuthApiException.invalidCredentials,
        message: 'Email or password is incorrect.',
      );
    }
    return AuthSession(
      email: email,
      displayName: email.split('@').first,
      userId: 'user-1',
      token: 'test-token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    registerCalls += 1;
    return login(email: email, password: password);
  }

  @override
  Future<void> logout(String token) async {
    logoutCalls += 1;
  }
}
