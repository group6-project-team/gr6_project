/// Public trip-plan contract that Flutter renders.
/// Optional fields are shown only when the Backend actually sent them.
class Place {
  const Place({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.rating,
    this.website,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? description;
  final String? address;
  final double? rating;
  final String? website;
  final String? imageUrl;

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      description: json['description'] as String?,
      address: json['address'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      website: json['website'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (address != null) 'address': address,
      if (rating != null) 'rating': rating,
      if (website != null) 'website': website,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}

class DayPlan {
  const DayPlan({required this.dayNumber, required this.places});

  final int dayNumber;
  final List<Place> places;

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      dayNumber: _requiredInt(json, 'dayNumber'),
      places: (json['places'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((item) => Place.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'dayNumber': dayNumber,
        'places': places.map((place) => place.toJson()).toList(),
      };
}

class PlanningWarning {
  const PlanningWarning({required this.code, this.message});

  final String code;
  final String? message;

  factory PlanningWarning.fromJson(Object? json) {
    if (json is String) {
      return PlanningWarning(code: json);
    }
    if (json is Map) {
      final map = Map<String, dynamic>.from(json);
      final code = map['code'] as String? ?? '';
      if (code.isEmpty) {
        throw const FormatException('Warning object is missing code.');
      }
      return PlanningWarning(
        code: code,
        message: map['message'] as String?,
      );
    }
    throw const FormatException('Warning must be an object or string.');
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        if (message != null) 'message': message,
      };
}

class TripPlan {
  const TripPlan({
    required this.destinationId,
    required this.requestedDays,
    required this.days,
    required this.warnings,
  });

  final String destinationId;
  final int requestedDays;
  final List<DayPlan> days;
  final List<PlanningWarning> warnings;

  /// [requestedDays] comes from the request Flutter sent. Backend Stage 1
  /// does not return this field.
  factory TripPlan.fromJson(
    Map<String, dynamic> json, {
    int? requestedDays,
  }) {
    final days = (json['days'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => DayPlan.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    final fromJson = json['requestedDays'];
    final resolvedDays = requestedDays ??
        (fromJson is num ? fromJson.toInt() : null) ??
        days.length;

    return TripPlan(
      destinationId: _requiredString(json, 'destinationId'),
      requestedDays: resolvedDays,
      days: days,
      warnings: (json['warnings'] as List<dynamic>? ?? const [])
          .map(PlanningWarning.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'destinationId': destinationId,
        'requestedDays': requestedDays,
        'days': days.map((day) => day.toJson()).toList(),
        'warnings': warnings.map((warning) => warning.toJson()).toList(),
      };
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Missing or invalid "$key".');
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  throw FormatException('Missing or invalid "$key".');
}
