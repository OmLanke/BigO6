class TouristProfile {
  final String id;
  final String name;
  final String passportNumber;
  final String nationality;
  final String emergencyContact;
  final String emergencyContactNumber;
  final DateTime tripStartDate;
  final DateTime tripEndDate;
  final List<String> plannedLocations;
  final String profileImageUrl;
  final bool isActive;

  TouristProfile({
    required this.id,
    required this.name,
    required this.passportNumber,
    required this.nationality,
    required this.emergencyContact,
    required this.emergencyContactNumber,
    required this.tripStartDate,
    required this.tripEndDate,
    required this.plannedLocations,
    this.profileImageUrl = '',
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'passportNumber': passportNumber,
      'nationality': nationality,
      'emergencyContact': emergencyContact,
      'emergencyContactNumber': emergencyContactNumber,
      'tripStartDate': tripStartDate.toIso8601String(),
      'tripEndDate': tripEndDate.toIso8601String(),
      'plannedLocations': plannedLocations,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
    };
  }

  factory TouristProfile.fromJson(Map<String, dynamic> json) {
    return TouristProfile(
      id: json['id'],
      name: json['name'],
      passportNumber: json['passportNumber'],
      nationality: json['nationality'],
      emergencyContact: json['emergencyContact'],
      emergencyContactNumber: json['emergencyContactNumber'],
      tripStartDate: DateTime.parse(json['tripStartDate']),
      tripEndDate: DateTime.parse(json['tripEndDate']),
      plannedLocations: List<String>.from(json['plannedLocations']),
      profileImageUrl: json['profileImageUrl'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  TouristProfile copyWith({
    String? id,
    String? name,
    String? passportNumber,
    String? nationality,
    String? emergencyContact,
    String? emergencyContactNumber,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
    List<String>? plannedLocations,
    String? profileImageUrl,
    bool? isActive,
  }) {
    return TouristProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      passportNumber: passportNumber ?? this.passportNumber,
      nationality: nationality ?? this.nationality,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyContactNumber:
          emergencyContactNumber ?? this.emergencyContactNumber,
      tripStartDate: tripStartDate ?? this.tripStartDate,
      tripEndDate: tripEndDate ?? this.tripEndDate,
      plannedLocations: plannedLocations ?? this.plannedLocations,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
