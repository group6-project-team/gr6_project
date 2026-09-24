import 'trip_plan.dart';

class SavedTrip {
  const SavedTrip({
    required this.id,
    required this.destinationId,
    required this.requestedDays,
    this.createdAt,
    this.trip,
  });

  final String id;
  final String destinationId;
  final int requestedDays;
  final DateTime? createdAt;
  final TripPlan? trip;

  factory SavedTrip.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id == null) {
      throw const FormatException('Saved trip is missing id.');
    }
    final tripJson = json['trip'];
    final requestedDays = json['requestedDays'] is num
        ? (json['requestedDays'] as num).toInt()
        : null;
    return SavedTrip(
      id: id.toString(),
      destinationId: json['destinationId'] as String? ??
          (tripJson is Map ? tripJson['destinationId'] as String? : null) ??
          '',
      requestedDays: requestedDays ??
          (tripJson is Map && tripJson['requestedDays'] is num
              ? (tripJson['requestedDays'] as num).toInt()
              : 0),
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      trip: tripJson is Map
          ? TripPlan.fromJson(
              Map<String, dynamic>.from(tripJson),
              requestedDays: requestedDays,
            )
          : null,
    );
  }
}
