class TouristProfile {
  final String id;
  final String name;
  final String passportNumber;
  final String nationality;
  final String emergencyContact;
  final String emergencyContactNumber;
  final String? emergencyContactRelationship;
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
    this.emergencyContactRelationship,
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
      'emergencyContactRelationship': emergencyContactRelationship,
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
      emergencyContactRelationship: json['emergencyContactRelationship'],
      tripStartDate: DateTime.parse(json['tripStartDate']),
      tripEndDate: DateTime.parse(json['tripEndDate']),
      plannedLocations: List<String>.from(json['plannedLocations']),
      profileImageUrl: json['profileImageUrl'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  // Backend JSON has different field names
  factory TouristProfile.fromBackendJson(Map<String, dynamic> json) {
    return TouristProfile(
      id: json['id'],
      name: json['name'] ?? 'Pradyum Mistry',
      passportNumber: json['passportNumber'] ?? 'M12345678',
      nationality: json['nationality'] ?? 'India',
      emergencyContact: json['emergencyContactName'] ?? 'Emergency Contact',
      emergencyContactNumber:
          json['emergencyContactPhone'] ?? '+91-98765-43210',
      emergencyContactRelationship: json['emergencyContactRelationship'],
      tripStartDate: DateTime.now().subtract(const Duration(days: 1)),
      tripEndDate: DateTime.now().add(const Duration(days: 6)),
      plannedLocations: const [
        'Red Fort, Delhi',
        'India Gate, Delhi',
        'Qutub Minar, Delhi',
        'Lotus Temple, Delhi',
        'Taj Mahal, Agra',
        'Gateway of India, Mumbai',
      ],
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
    String? emergencyContactRelationship,
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
      emergencyContactRelationship:
          emergencyContactRelationship ?? this.emergencyContactRelationship,
      tripStartDate: tripStartDate ?? this.tripStartDate,
      tripEndDate: tripEndDate ?? this.tripEndDate,
      plannedLocations: plannedLocations ?? this.plannedLocations,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
