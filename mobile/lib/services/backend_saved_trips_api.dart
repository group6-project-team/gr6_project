import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/saved_trip.dart';
import '../models/saved_trips_api_exception.dart';
import '../models/trip_plan.dart';
import 'saved_trips_api.dart';

class BackendSavedTripsApi implements SavedTripsApi {
  BackendSavedTripsApi({
    required this.baseUrl,
    http.Client? client,
    this.timeout = AppConfig.requestTimeout,
  }) : client = client ?? http.Client();

  final String baseUrl;
  final http.Client client;
  final Duration timeout;

  static const path = '/api/saved-trips';

  @override
  Future<SavedTrip> saveTrip({
    required String token,
    required TripPlan plan,
  }) async {
    final json = await _sendJson(
      () => client.post(
        _uri(path),
        headers: _headers(token),
        body: jsonEncode({
          'destinationId': plan.destinationId,
          'requestedDays': plan.requestedDays,
          'trip': plan.toJson(),
        }),
      ),
      expected: const {200, 201},
    );
    return SavedTrip.fromJson(json);
  }

  @override
  Future<List<SavedTrip>> listTrips({required String token}) async {
    final response = await _send(
      () => client.get(_uri(path), headers: _headers(token)),
      expected: const {200},
    );
    if (response.body.isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(response.body);
    final items = _asList(decoded);
    return items
        .whereType<Map>()
        .map((item) => SavedTrip.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<SavedTrip> getTrip({
    required String token,
    required String id,
  }) async {
    final json = await _sendJson(
      () => client.get(_uri('$path/$id'), headers: _headers(token)),
      expected: const {200},
    );
    return SavedTrip.fromJson(json);
  }

  @override
  Future<void> deleteTrip({
    required String token,
    required String id,
  }) async {
    await _send(
      () => client.delete(_uri('$path/$id'), headers: _headers(token)),
      expected: const {200, 204},
    );
  }

  List<dynamic> _asList(Object? decoded) {
    if (decoded is List) {
      return decoded;
    }
    if (decoded is Map) {
      final trips = decoded['trips'] ?? decoded['items'] ?? decoded['data'];
      if (trips is List) {
        return trips;
      }
    }
    throw const FormatException('Expected a saved-trips list.');
  }

  Map<String, String> _headers(String token) {
    if (token.isEmpty) {
      throw const SavedTripsApiException(
        code: SavedTripsApiException.unauthorized,
        message: 'Missing auth token.',
      );
    }
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _sendJson(
    Future<http.Response> Function() request, {
    required Set<int> expected,
  }) async {
    final response = await _send(request, expected: expected);
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
      throw _exceptionFrom(response.statusCode);
    } on SavedTripsApiException {
      rethrow;
    } on TimeoutException {
      throw const SavedTripsApiException(
        code: SavedTripsApiException.unexpected,
        message: 'The saved-trips request timed out.',
      );
    } on SocketException {
      throw const SavedTripsApiException(
        code: SavedTripsApiException.unexpected,
        message: 'Could not reach saved trips.',
      );
    } on http.ClientException {
      throw const SavedTripsApiException(
        code: SavedTripsApiException.unexpected,
        message: 'The HTTP client failed before a saved-trips response arrived.',
      );
    } on FormatException {
      throw const SavedTripsApiException(
        code: SavedTripsApiException.unexpected,
        message: 'The saved-trips response was not readable JSON.',
      );
    }
  }

  SavedTripsApiException _exceptionFrom(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      return const SavedTripsApiException(
        code: SavedTripsApiException.unauthorized,
        message: 'Please log in to continue.',
      );
    }
    if (statusCode == 404) {
      return const SavedTripsApiException(
        code: SavedTripsApiException.notFound,
        message: 'That saved trip was not found.',
      );
    }
    return SavedTripsApiException(
      code: SavedTripsApiException.unexpected,
      message: 'Saved trips request failed ($statusCode).',
    );
  }

  Uri _uri(String requestPath) {
    final normalized = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalized$requestPath');
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
