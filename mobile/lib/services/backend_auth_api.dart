import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/auth_api_exception.dart';
import '../models/auth_session.dart';
import 'auth_api.dart';

/// ASP.NET auth client. Flutter talks only to this Backend.
class BackendAuthApi implements AuthApi {
  BackendAuthApi({
    required this.baseUrl,
    http.Client? client,
    this.timeout = AppConfig.requestTimeout,
  }) : client = client ?? http.Client();

  final String baseUrl;
  final http.Client client;
  final Duration timeout;

  static const registerPath = '/api/Auth/register';
  static const loginPath = '/api/Auth/login';
  static const logoutPath = '/api/Auth/logout';

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final json = await _postJson(
      loginPath,
      {'email': email, 'password': password},
      expected: const {200},
    );
    return _sessionFrom(json, email: email);
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    await _postJson(
      registerPath,
      {
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      },
      expected: const {200, 201},
    );
    return login(email: email, password: password);
  }

  @override
  Future<void> logout(String token) async {
    await _send(
      () => client.post(
        _uri(logoutPath),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
      expected: const {200, 204},
    );
  }

  AuthSession _sessionFrom(Map<String, dynamic> json, {required String email}) {
    final token = json['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const AuthApiException(
        code: AuthApiException.unexpected,
        message: 'Login did not return a token.',
      );
    }
    final rawExpiry = json['expiresAt'];
    return AuthSession(
      email: json['email'] as String? ?? email,
      displayName: json['name'] as String?,
      userId: json['userId']?.toString(),
      token: token,
      expiresAt: rawExpiry is String && rawExpiry.isNotEmpty
          ? DateTime.tryParse(rawExpiry)
          : null,
    );
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body, {
    required Set<int> expected,
  }) async {
    final response = await _send(
      () => client.post(
        _uri(path),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ),
      expected: expected,
    );
    if (response.body.isEmpty) {
      return {};
    }
    return _decodeObject(response.body);
  }

  Future<http.Response> _send(
    Future<http.Response> Function() request, {
    required Set<int> expected,
  }) async {
    try {
      final response = await request().timeout(timeout);
      if (expected.contains(response.statusCode)) {
        return response;
      }
      throw _exceptionFrom(response.body, response.statusCode);
    } on AuthApiException {
      rethrow;
    } on TimeoutException {
      throw const AuthApiException(
        code: AuthApiException.authUnavailable,
        message: 'The auth request timed out.',
      );
    } on SocketException {
      throw const AuthApiException(
        code: AuthApiException.authUnavailable,
        message: 'Could not reach the auth service.',
      );
    } on http.ClientException {
      throw const AuthApiException(
        code: AuthApiException.authUnavailable,
        message: 'The HTTP client failed before a valid auth response arrived.',
      );
    } on FormatException {
      throw const AuthApiException(
        code: AuthApiException.authUnavailable,
        message: 'The auth response was not readable JSON.',
      );
    }
  }

  AuthApiException _exceptionFrom(String body, int statusCode) {
    Map<String, dynamic> json = {};
    try {
      if (body.isNotEmpty) {
        json = _decodeObject(body);
      }
    } on FormatException {
      json = {};
    }

    final message = _messageFrom(json) ?? 'Request failed ($statusCode).';
    final haystack = '${message.toLowerCase()} ${_errorsText(json).toLowerCase()}';

    if (statusCode == 409 || _looksLikeEmailTaken(haystack)) {
      return AuthApiException(code: AuthApiException.emailTaken, message: message);
    }
    if (_looksLikeBadPassword(haystack)) {
      return AuthApiException(
        code: AuthApiException.invalidCredentials,
        message: message,
      );
    }
    if (statusCode == 401 || statusCode == 403) {
      return AuthApiException(
        code: AuthApiException.unauthorized,
        message: message,
      );
    }
    if (statusCode == 400) {
      return AuthApiException(
        code: AuthApiException.validation,
        message: message,
      );
    }
    if (statusCode == 404 || statusCode == 503) {
      return const AuthApiException(
        code: AuthApiException.authUnavailable,
        message: 'Account service is not available yet.',
      );
    }
    return AuthApiException(
      code: AuthApiException.unexpected,
      message: message,
    );
  }

  bool _looksLikeEmailTaken(String haystack) {
    return haystack.contains('already registered') ||
        haystack.contains('already has') ||
        haystack.contains('email is already') ||
        haystack.contains('taken');
  }

  bool _looksLikeBadPassword(String haystack) {
    return haystack.contains('invalid email or password') ||
        haystack.contains('invalid credentials');
  }

  String? _messageFrom(Map<String, dynamic> json) {
    final message = json['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
    final errors = _errorsText(json);
    return errors.isEmpty ? null : errors;
  }

  String _errorsText(Map<String, dynamic> json) {
    final errors = json['errors'];
    if (errors is List) {
      return errors.whereType<String>().where((item) => item.isNotEmpty).join(' ');
    }
    if (errors is Map) {
      final parts = <String>[];
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          parts.add(value.first.toString());
        } else if (value is String && value.isNotEmpty) {
          parts.add(value);
        }
      }
      return parts.join(' ');
    }
    return '';
  }

  Uri _uri(String path) {
    final normalized = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalized$path');
  }

  Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw const FormatException('Expected a JSON object.');
  }
}
