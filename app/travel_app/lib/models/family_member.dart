class FamilyMember {
  final String id;
  final String name;
  final String passportNumber;
  final String nationality;
  final String relationship;
  final String emergencyContact;
  final String emergencyContactNumber;
  final String? emergencyContactRelationship;
  final DateTime tripStartDate;
  final DateTime tripEndDate;
  final List<String> plannedLocations;
  final String profileImageUrl;
  final bool isActive;

  FamilyMember({
    required this.id,
    required this.name,
    required this.passportNumber,
    required this.nationality,
    required this.relationship,
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
      'relationship': relationship,
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

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'],
      name: json['name'],
      passportNumber: json['passportNumber'],
      nationality: json['nationality'],
      relationship: json['relationship'],
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

  FamilyMember copyWith({
    String? id,
    String? name,
    String? passportNumber,
    String? nationality,
    String? relationship,
    String? emergencyContact,
    String? emergencyContactNumber,
    String? emergencyContactRelationship,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
    List<String>? plannedLocations,
    String? profileImageUrl,
    bool? isActive,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      name: name ?? this.name,
      passportNumber: passportNumber ?? this.passportNumber,
      nationality: nationality ?? this.nationality,
      relationship: relationship ?? this.relationship,
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
