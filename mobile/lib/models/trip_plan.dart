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
      id: json['id'] as String,
      name: json['name'] as String,
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
      dayNumber: json['dayNumber'] as int,
      places: (json['places'] as List<dynamic>? ?? const [])
          .map((item) => Place.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'dayNumber': dayNumber,
        'places': places.map((place) => place.toJson()).toList(),
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
  final List<String> warnings;

  factory TripPlan.fromJson(Map<String, dynamic> json) {
    return TripPlan(
      destinationId: json['destinationId'] as String,
      requestedDays: json['requestedDays'] as int,
      days: (json['days'] as List<dynamic>)
          .map((item) => DayPlan.fromJson(item as Map<String, dynamic>))
          .toList(),
      warnings: (json['warnings'] as List<dynamic>? ?? const [])
          .map((item) => item as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'destinationId': destinationId,
        'requestedDays': requestedDays,
        'days': days.map((day) => day.toJson()).toList(),
        'warnings': warnings,
      };
}
