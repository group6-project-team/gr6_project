/// Body of POST /trips/plan.
/// Budget is intentionally absent: the v0 capability is disabled.
class TripPlanRequest {
  const TripPlanRequest({
    required this.destinationId,
    required this.days,
    required this.interests,
  });

  final String destinationId;
  final int days;
  final List<String> interests;

  Map<String, dynamic> toJson() => {
        'destinationId': destinationId,
        'days': days,
        'interests': interests,
      };
}
