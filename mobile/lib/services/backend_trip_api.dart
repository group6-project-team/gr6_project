import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/trip_api_exception.dart';
import '../models/trip_options.dart';
import '../models/trip_plan.dart';
import '../models/trip_request.dart';
import 'trip_api.dart';

/// Real public client: ASP.NET only.
///
/// Paths are documented here so they can be updated to match Swagger
/// without touching the Flutter screens.
class BackendTripApi implements TripApi {
  BackendTripApi({
    required this.baseUrl,
    http.Client? client,
    this.timeout = AppConfig.requestTimeout,
  }) : client = client ?? http.Client();

  final String baseUrl;
  final http.Client client;
  final Duration timeout;

  static const optionsPath = '/trip-options';
  static const planPath = '/trips/plan';

  @override
  Future<TripOptions> getOptions() async {
    final response = await _send(() => client.get(_uri(optionsPath), headers: _headers));
    return TripOptions.fromJson(_decodeObject(response.body));
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
    return TripPlan.fromJson(_decodeObject(response.body));
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
      throw _exceptionFromBody(response.body);
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

  TripApiException _exceptionFromBody(String body) {
    try {
      final json = _decodeObject(body);
      final code = json['code'] as String? ?? TripApiException.unexpected;
      return TripApiException(
        code: code,
        message: json['message'] as String? ?? 'Request failed.',
      );
    } on FormatException {
      return const TripApiException(
        code: TripApiException.networkError,
        message: 'The server response was not readable JSON.',
      );
    }
  }

  Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const FormatException('Expected a JSON object.');
  }
}
