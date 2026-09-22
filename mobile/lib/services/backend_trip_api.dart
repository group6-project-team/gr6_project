import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../config/app_config.dart';
import '../data/stage1_catalog.dart';
import '../models/trip_api_exception.dart';
import '../models/trip_options.dart';
import '../models/trip_plan.dart';
import '../models/trip_request.dart';
import 'trip_api.dart';

/// Real public client: ASP.NET only.
///
/// Stage 1 route: POST /trip-plans/preview
/// Options: documented Stage 1 catalog. There is no GET /trip-options.
class BackendTripApi implements TripApi {
  BackendTripApi({
    required this.baseUrl,
    http.Client? client,
    this.timeout = AppConfig.requestTimeout,
  }) : client = client ?? _clientWithConnectionTimeout(timeout);

  static http.Client _clientWithConnectionTimeout(Duration timeout) {
    return IOClient(HttpClient()..connectionTimeout = timeout);
  }

  final String baseUrl;
  final http.Client client;
  final Duration timeout;

  static const planPath = '/trip-plans/preview';

  @override
  Future<TripOptions> getOptions() async {
    return Stage1Catalog.options;
  }

  @override
  Future<TripPlan> planTrip(TripPlanRequest request) async {
    final response = await _send(
      () => client.post(
        _uri(planPath),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      ),
    );
    try {
      return TripPlan.fromJson(
        _decodeObject(response.body),
        requestedDays: request.days,
      );
    } on FormatException {
      throw const TripApiException(
        code: TripApiException.unexpected,
        message: 'The server returned JSON that does not match the trip contract.',
      );
    } on TypeError {
      throw const TripApiException(
        code: TripApiException.unexpected,
        message: 'The server returned JSON that does not match the trip contract.',
      );
    }
  }

  Map<String, String> get _headers => const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  Uri _uri(String path) {
    final normalized = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalized$path');
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      throw _exceptionFromBody(response.body, response.statusCode);
    } on TripApiException {
      rethrow;
    } on TimeoutException {
      throw const TripApiException(
        code: TripApiException.networkError,
        message: 'The request timed out.',
      );
    } on SocketException {
      throw const TripApiException(
        code: TripApiException.networkError,
        message: 'The device could not open a network connection.',
      );
    } on http.ClientException {
      throw const TripApiException(
        code: TripApiException.networkError,
        message: 'The HTTP client failed before a valid response arrived.',
      );
    } on FormatException {
      throw const TripApiException(
        code: TripApiException.networkError,
        message: 'The server response was not readable JSON.',
      );
    }
  }

  TripApiException _exceptionFromBody(String body, int statusCode) {
    try {
      final json = _decodeObject(body);
      final mapped = _fromValidationProblem(json);
      if (mapped != null) {
        return mapped;
      }
      final code = json['code'] as String? ?? TripApiException.unexpected;
      return TripApiException(
        code: code,
        message: json['message'] as String? ?? json['title'] as String? ?? 'Request failed ($statusCode).',
      );
    } on FormatException {
      return const TripApiException(
        code: TripApiException.networkError,
        message: 'The server response was not readable JSON.',
      );
    }
  }

  TripApiException? _fromValidationProblem(Map<String, dynamic> json) {
    final errors = json['errors'];
    if (errors is! Map) {
      return null;
    }
    final map = Map<String, dynamic>.from(errors);
    final firstMessage = _firstValidationMessage(map);
    if (_hasField(map, 'destinationId')) {
      return TripApiException(
        code: TripApiException.invalidDestination,
        message: firstMessage ?? 'The selected destination is not supported.',
      );
    }
    if (_hasField(map, 'interests')) {
      return TripApiException(
        code: TripApiException.invalidInterest,
        message: firstMessage ?? 'One or more interests are not supported.',
      );
    }
    return TripApiException(
      code: TripApiException.unexpected,
      message: firstMessage ?? 'The request was rejected.',
    );
  }

  bool _hasField(Map<String, dynamic> errors, String name) {
    return errors.keys.any((key) => key.toLowerCase() == name.toLowerCase());
  }

  String? _firstValidationMessage(Map<String, dynamic> errors) {
    for (final value in errors.values) {
      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
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
