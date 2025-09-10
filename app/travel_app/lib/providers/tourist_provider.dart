import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/tourist_profile.dart';
import '../models/tourist_alert.dart';
import '../models/family_member.dart';
import '../models/location_feedback.dart';

class TouristProvider extends ChangeNotifier {
  TouristProfile? _currentProfile;
  final List<TouristAlert> _alerts = [];
  final List<FamilyMember> _familyMembers = [];
  final List<LocationFeedback> _locationFeedbacks = [];
  bool _isRegistered = false;
  bool _sosActive = false;
  bool _sosTimerActive = false;
  Timer? _sosTimer;
  String? _digitalId;

  // Getters
  TouristProfile? get currentProfile => _currentProfile;
  List<TouristAlert> get alerts => List.unmodifiable(_alerts);
  List<TouristAlert> get activeAlerts =>
      _alerts.where((alert) => !alert.isResolved).toList();
  List<FamilyMember> get familyMembers => List.unmodifiable(_familyMembers);
  List<LocationFeedback> get locationFeedbacks =>
      List.unmodifiable(_locationFeedbacks);
  bool get isRegistered => _isRegistered;
  bool get sosActive => _sosActive;
  bool get sosTimerActive => _sosTimerActive;
  String? get digitalId => _digitalId;

  // Registration and Profile Management
  Future<void> registerTourist({
    required String name,
    required String passportNumber,
    required String nationality,
    required String emergencyContact,
    required String emergencyContactNumber,
    String? emergencyContactRelationship,
    required DateTime tripStartDate,
    required DateTime tripEndDate,
    required List<String> plannedLocations,
    String profileImageUrl = '',
  }) async {
    try {
      // Generate a mock digital ID
      _digitalId = 'DTI_${DateTime.now().millisecondsSinceEpoch}';

      _currentProfile = TouristProfile(
        id: _digitalId!,
        name: name,
        passportNumber: passportNumber,
        nationality: nationality,
        emergencyContact: emergencyContact,
        emergencyContactNumber: emergencyContactNumber,
        emergencyContactRelationship: emergencyContactRelationship,
        tripStartDate: tripStartDate,
        tripEndDate: tripEndDate,
        plannedLocations: plannedLocations,
        profileImageUrl: profileImageUrl,
      );

      _isRegistered = true;
      notifyListeners();

      // In a real app, this would interact with blockchain/backend
      if (kDebugMode) {
        print('Tourist registered with Digital ID: $_digitalId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Registration failed: $e');
      }
      rethrow;
    }
  }

  Future<void> updateProfile(TouristProfile updatedProfile) async {
    _currentProfile = updatedProfile;
    notifyListeners();
  }

  // SOS and Alert Management with Timer
  Future<void> triggerSOS({
    required double latitude,
    required double longitude,
    String? customMessage,
  }) async {
    if (_currentProfile == null || _sosTimerActive) return;

    _sosTimerActive = true;
    notifyListeners();

    // Start 60-second timer
    _sosTimer = Timer(const Duration(seconds: 60), () {
      // Timer expired, send SOS to authorities
      _sendSOSToAuthorities(latitude, longitude, customMessage);
    });

    if (kDebugMode) {
      print('SOS timer started - 60 seconds to dismiss');
    }
  }

  void dismissSOS() {
    if (_sosTimer != null) {
      _sosTimer!.cancel();
      _sosTimer = null;
    }
    _sosTimerActive = false;
    notifyListeners();

    if (kDebugMode) {
      print('SOS dismissed by user');
    }
  }

  void _sendSOSToAuthorities(
    double latitude,
    double longitude,
    String? customMessage,
  ) {
    if (_currentProfile == null) return;

    _sosActive = true;
    _sosTimerActive = false;

    TouristAlert sosAlert = TouristAlert.createSOS(
      touristId: _currentProfile!.id,
      latitude: latitude,
      longitude: longitude,
      customMessage: customMessage,
    );

    _alerts.add(sosAlert);
    notifyListeners();

    // In a real app, this would:
    // 1. Send alert to police dashboard
    // 2. Notify emergency contacts
    // 3. Send to tourism department
    // 4. Trigger local emergency services

    if (kDebugMode) {
      print('SOS SENT TO AUTHORITIES: ${sosAlert.message}');
      print('Location: $latitude, $longitude');
      print('Tourist: ${_currentProfile!.name}');
    }

    // Simulate emergency response (auto-resolve after 5 minutes for demo)
    Future.delayed(const Duration(minutes: 5), () {
      if (_sosActive) {
        resolveSOS('Emergency Services');
      }
    });
  }

  void resolveSOS(String resolvedBy) {
    if (!_sosActive) return;

    _sosActive = false;

    // Find and resolve the active SOS alert
    for (int i = 0; i < _alerts.length; i++) {
      if (_alerts[i].type == AlertType.sos && !_alerts[i].isResolved) {
        _alerts[i] = _alerts[i].resolve(resolvedBy: resolvedBy);
        break;
      }
    }

    notifyListeners();

    if (kDebugMode) {
      print('SOS resolved by: $resolvedBy');
    }
  }

  void addAlert(TouristAlert alert) {
    _alerts.add(alert);
    notifyListeners();
  }

  void resolveAlert(String alertId, String resolvedBy) {
    for (int i = 0; i < _alerts.length; i++) {
      if (_alerts[i].id == alertId) {
        _alerts[i] = _alerts[i].resolve(resolvedBy: resolvedBy);
        break;
      }
    }
    notifyListeners();
  }

  void clearResolvedAlerts() {
    _alerts.removeWhere((alert) => alert.isResolved);
    notifyListeners();
  }

  // Trip Management
  bool get isTripActive {
    if (_currentProfile == null) return false;

    DateTime now = DateTime.now();
    return now.isAfter(_currentProfile!.tripStartDate) &&
        now.isBefore(_currentProfile!.tripEndDate);
  }

  Duration get timeUntilTripStart {
    if (_currentProfile == null) return Duration.zero;

    DateTime now = DateTime.now();
    if (now.isAfter(_currentProfile!.tripStartDate)) {
      return Duration.zero;
    }

    return _currentProfile!.tripStartDate.difference(now);
  }

  Duration get timeUntilTripEnd {
    if (_currentProfile == null) return Duration.zero;

    DateTime now = DateTime.now();
    if (now.isAfter(_currentProfile!.tripEndDate)) {
      return Duration.zero;
    }

    return _currentProfile!.tripEndDate.difference(now);
  }

  // Mock data for demo
  void loadMockData() {
    _digitalId = 'DTI_DEMO_123456789';
    _currentProfile = TouristProfile(
      id: _digitalId!,
      name: 'Pradyum Mistry',
      passportNumber: 'M12345678',
      nationality: 'India',
      emergencyContact: 'Emergency Contact',
      emergencyContactNumber: '+91-98765-43210',
      emergencyContactRelationship: 'Parent',
      tripStartDate: DateTime.now().subtract(const Duration(days: 1)),
      tripEndDate: DateTime.now().add(const Duration(days: 6)),
      plannedLocations: [
        'Red Fort, Delhi',
        'India Gate, Delhi',
        'Qutub Minar, Delhi',
        'Lotus Temple, Delhi',
        'Taj Mahal, Agra',
        'Gateway of India, Mumbai',
      ],
      profileImageUrl: '',
    );
    _isRegistered = true;

    // Add some mock alerts
    _alerts.addAll([
      TouristAlert.createGeofenceAlert(
        touristId: _digitalId!,
        latitude: 28.6562,
        longitude: 77.2410,
        zoneName: 'Red Fort Area',
        isRestricted: false,
      ),
      TouristAlert.createDeviationAlert(
        touristId: _digitalId!,
        latitude: 28.6129,
        longitude: 77.2295,
        plannedLocation: 'India Gate',
        deviationDistance: 2.5,
      ),
    ]);

    notifyListeners();
  }

  void completeKyc() {
    // In demo mode, just update the profile to show KYC is completed
    if (_currentProfile != null) {
      // For demo purposes, we'll just mark it as completed
      // In a real app, this would update the backend
      notifyListeners();
    }
  }

  // Family Member Management
  void addFamilyMember({
    required String name,
    required String passportNumber,
    required String nationality,
    required String relationship,
    required String emergencyContact,
    required String emergencyContactNumber,
    String? emergencyContactRelationship,
    required DateTime tripStartDate,
    required DateTime tripEndDate,
    required List<String> plannedLocations,
    String profileImageUrl = '',
  }) {
    final memberId = 'FM_${DateTime.now().millisecondsSinceEpoch}';

    final familyMember = FamilyMember(
      id: memberId,
      name: name,
      passportNumber: passportNumber,
      nationality: nationality,
      relationship: relationship,
      emergencyContact: emergencyContact,
      emergencyContactNumber: emergencyContactNumber,
      emergencyContactRelationship: emergencyContactRelationship,
      tripStartDate: tripStartDate,
      tripEndDate: tripEndDate,
      plannedLocations: plannedLocations,
      profileImageUrl: profileImageUrl,
    );

    _familyMembers.add(familyMember);
    notifyListeners();

    if (kDebugMode) {
      print(
        'Family member added: ${familyMember.name} (${familyMember.relationship})',
      );
    }
  }

  void removeFamilyMember(String memberId) {
    _familyMembers.removeWhere((member) => member.id == memberId);
    notifyListeners();

    if (kDebugMode) {
      print('Family member removed: $memberId');
    }
  }

  void updateFamilyMember(FamilyMember updatedMember) {
    final index = _familyMembers.indexWhere(
      (member) => member.id == updatedMember.id,
    );
    if (index != -1) {
      _familyMembers[index] = updatedMember;
      notifyListeners();

      if (kDebugMode) {
        print('Family member updated: ${updatedMember.name}');
      }
    }
  }

  // Location Feedback Management
  void submitLocationFeedback({
    required String locationName,
    required double latitude,
    required double longitude,
    required int safetyRating,
    String? comments,
    List<String> categories = const [],
  }) {
    if (_currentProfile == null) return;

    final feedbackId = 'FB_${DateTime.now().millisecondsSinceEpoch}';

    final feedback = LocationFeedback(
      id: feedbackId,
      touristId: _currentProfile!.id,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      safetyRating: safetyRating,
      comments: comments,
      submittedAt: DateTime.now(),
      categories: categories,
    );

    _locationFeedbacks.add(feedback);
    notifyListeners();

    if (kDebugMode) {
      print(
        'Location feedback submitted: $locationName - ${feedback.safetyLabel}',
      );
    }
  }

  List<LocationFeedback> getFeedbackForLocation(
    double latitude,
    double longitude, {
    double radiusKm = 1.0,
  }) {
    return _locationFeedbacks.where((feedback) {
      // Simple distance calculation (not perfectly accurate but good enough for demo)
      final latDiff = (feedback.latitude - latitude).abs();
      final lngDiff = (feedback.longitude - longitude).abs();
      final distance = (latDiff + lngDiff) * 111; // Rough km conversion
      return distance <= radiusKm;
    }).toList();
  }

  @override
  void dispose() {
    _sosTimer?.cancel();
    super.dispose();
  }

  void logout() {
    _sosTimer?.cancel();
    _currentProfile = null;
    _alerts.clear();
    _familyMembers.clear();
    _locationFeedbacks.clear();
    _isRegistered = false;
    _sosActive = false;
    _sosTimerActive = false;
    _digitalId = null;
    notifyListeners();
  }
}
