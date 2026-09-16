/// Supported destinations and interests.
/// Stage 1 uses the documented Backend catalog, not GET /trip-options.
///
/// Flutter must not hardcode the final product taxonomy. Today's list is
/// temporary local data behind [TripApi.getOptions], so we can replace it
/// with the real Backend response later without rewriting the screen.
class DestinationOption {
  const DestinationOption({required this.id, required this.name});

  final String id;
  final String name;

  factory DestinationOption.fromJson(Map<String, dynamic> json) {
    return DestinationOption(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class InterestOption {
  const InterestOption({required this.id, required this.name});

  final String id;
  final String name;

  factory InterestOption.fromJson(Map<String, dynamic> json) {
    return InterestOption(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class TripOptions {
  const TripOptions({
    required this.destinations,
    required this.interests,
  });

  final List<DestinationOption> destinations;
  final List<InterestOption> interests;

  factory TripOptions.fromJson(Map<String, dynamic> json) {
    return TripOptions(
      destinations: (json['destinations'] as List<dynamic>)
          .map((item) => DestinationOption.fromJson(item as Map<String, dynamic>))
          .toList(),
      interests: (json['interests'] as List<dynamic>)
          .map((item) => InterestOption.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'destinations': destinations.map((item) => item.toJson()).toList(),
        'interests': interests.map((item) => item.toJson()).toList(),
      };
}
