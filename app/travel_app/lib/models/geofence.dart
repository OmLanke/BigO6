import 'dart:math' as math;

class GeoFence {
  final String id;
  final String name;
  final String description;
  final double centerLatitude;
  final double centerLongitude;
  final double radius; // in meters
  final bool isRestrictedZone;
  final bool isActive;
  final List<String> tags;
  final DateTime createdAt;

  GeoFence({
    required this.id,
    required this.name,
    required this.description,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.radius,
    this.isRestrictedZone = false,
    this.isActive = true,
    this.tags = const [],
    required this.createdAt,
  });

  bool containsPoint(double latitude, double longitude) {
    const double earthRadius = 6371000; // Earth's radius in meters

    double dLat = (latitude - centerLatitude) * (math.pi / 180);
    double dLon = (longitude - centerLongitude) * (math.pi / 180);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(centerLatitude * (math.pi / 180)) *
            math.cos(latitude * (math.pi / 180)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.asin(math.sqrt(a));
    double distance = earthRadius * c;

    return distance <= radius;
  }

  double distanceFromPoint(double latitude, double longitude) {
    const double earthRadius = 6371000; // Earth's radius in meters

    double dLat = (latitude - centerLatitude) * (math.pi / 180);
    double dLon = (longitude - centerLongitude) * (math.pi / 180);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(centerLatitude * (math.pi / 180)) *
            math.cos(latitude * (math.pi / 180)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'centerLatitude': centerLatitude,
      'centerLongitude': centerLongitude,
      'radius': radius,
      'isRestrictedZone': isRestrictedZone,
      'isActive': isActive,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GeoFence.fromJson(Map<String, dynamic> json) {
    return GeoFence(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      centerLatitude: json['centerLatitude'].toDouble(),
      centerLongitude: json['centerLongitude'].toDouble(),
      radius: json['radius'].toDouble(),
      isRestrictedZone: json['isRestrictedZone'] ?? false,
      isActive: json['isActive'] ?? true,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  GeoFence copyWith({
    String? id,
    String? name,
    String? description,
    double? centerLatitude,
    double? centerLongitude,
    double? radius,
    bool? isRestrictedZone,
    bool? isActive,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return GeoFence(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      centerLatitude: centerLatitude ?? this.centerLatitude,
      centerLongitude: centerLongitude ?? this.centerLongitude,
      radius: radius ?? this.radius,
      isRestrictedZone: isRestrictedZone ?? this.isRestrictedZone,
      isActive: isActive ?? this.isActive,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
