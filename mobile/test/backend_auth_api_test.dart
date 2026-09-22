import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/models/auth_api_exception.dart';
import 'package:mobile/services/backend_auth_api.dart';

BackendAuthApi _api(Future<http.Response> Function(http.Request) handler) {
  return BackendAuthApi(
    baseUrl: 'https://gr6-tripplanning-api.runasp.net/',
    client: MockClient((request) async => handler(request)),
  );
}

void main() {
  test('login posts to /api/Auth/login and keeps the JWT', () async {
    final api = _api((request) async {
      expect(request.url.path, '/api/Auth/login');
      expect(request.body, contains('heba@example.com'));
      return http.Response(
        '''
{
  "success": true,
  "message": "Logged in",
  "token": "jwt-token",
  "expiresAt": "2026-09-22T22:00:00Z",
  "userId": "u-1",
  "name": "Heba Rabaya",
  "email": "heba@example.com"
}
''',
        200,
      );
    });

    final session = await api.login(
      email: 'heba@example.com',
      password: 'Password123!',
    );

    expect(session.token, 'jwt-token');
    expect(session.userId, 'u-1');
    expect(session.displayName, 'Heba Rabaya');
    expect(session.email, 'heba@example.com');
  });

  test('register posts confirmPassword then logs in for the token', () async {
    final paths = <String>[];
    final api = _api((request) async {
      paths.add(request.url.path);
      if (request.url.path.endsWith('/register')) {
        expect(request.body, contains('"name":"Heba Rabaya"'));
        expect(request.body, contains('confirmPassword'));
        return http.Response(
          '''
{
  "success": true,
  "message": "Created",
  "userId": "u-1",
  "name": "Heba Rabaya",
  "email": "heba@example.com",
  "errors": []
}
''',
          201,
        );
      }
      return http.Response(
        '''
{
  "success": true,
  "token": "jwt-after-register",
  "expiresAt": "2026-09-22T22:00:00Z",
  "userId": "u-1",
  "name": "Heba Rabaya",
  "email": "heba@example.com"
}
''',
        200,
      );
    });

    final session = await api.register(
      name: 'Heba Rabaya',
      email: 'heba@example.com',
      password: 'Password123!',
      confirmPassword: 'Password123!',
    );

    expect(paths, ['/api/Auth/register', '/api/Auth/login']);
    expect(session.token, 'jwt-after-register');
  });

  test('logout sends the Bearer token', () async {
    final api = _api((request) async {
      expect(request.url.path, '/api/Auth/logout');
      expect(request.headers['Authorization'], 'Bearer jwt-token');
      return http.Response('{"success":true}', 200);
    });

    await api.logout('jwt-token');
  });

  test('duplicate email 400 maps to EMAIL_TAKEN', () async {
    final api = _api((request) async {
      return http.Response(
        '''
{
  "success": false,
  "message": "Email is already registered.",
  "userId": null,
  "name": null,
  "email": null,
  "errors": []
}
''',
        400,
      );
    });

    expect(
      () => api.register(
        name: 'Heba Rabaya',
        email: 'heba@example.com',
        password: 'Password123!',
        confirmPassword: 'Password123!',
      ),
      throwsA(
        isA<AuthApiException>().having(
          (error) => error.code,
          'code',
          AuthApiException.emailTaken,
        ),
      ),
    );
  });

  test('failed login 400 maps to INVALID_CREDENTIALS', () async {
    final api = _api((request) async {
      return http.Response(
        '''
{
  "success": false,
  "message": "Invalid email or password.",
  "token": null,
  "expiresAt": null,
  "userId": null,
  "name": null,
  "email": null
}
''',
        400,
      );
    });

    expect(
      () => api.login(email: 'heba@example.com', password: 'bad'),
      throwsA(
        isA<AuthApiException>().having(
          (error) => error.code,
          'code',
          AuthApiException.invalidCredentials,
        ),
      ),
    );
  });
}
