class LocationFeedback {
  final String id;
  final String touristId;
  final String locationName;
  final double latitude;
  final double longitude;
  final int safetyRating; // 1-5 scale
  final String? comments;
  final DateTime submittedAt;
  final List<String>
  categories; // e.g., ['police_presence', 'well_lit', 'crowded']

  LocationFeedback({
    required this.id,
    required this.touristId,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.safetyRating,
    this.comments,
    required this.submittedAt,
    this.categories = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'touristId': touristId,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'safetyRating': safetyRating,
      'comments': comments,
      'submittedAt': submittedAt.toIso8601String(),
      'categories': categories,
    };
  }

  factory LocationFeedback.fromJson(Map<String, dynamic> json) {
    return LocationFeedback(
      id: json['id'],
      touristId: json['touristId'],
      locationName: json['locationName'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      safetyRating: json['safetyRating'],
      comments: json['comments'],
      submittedAt: DateTime.parse(json['submittedAt']),
      categories: List<String>.from(json['categories'] ?? []),
    );
  }

  String get safetyLabel {
    switch (safetyRating) {
      case 5:
        return 'Very Safe';
      case 4:
        return 'Safe';
      case 3:
        return 'Moderate';
      case 2:
        return 'Unsafe';
      case 1:
        return 'Very Unsafe';
      default:
        return 'Unknown';
    }
  }
}
