import 'package:flutter/foundation.dart';
import '../models/tourist_profile.dart';
import '../models/tourist_alert.dart';
import '../services/backend_service.dart';

class TouristProvider extends ChangeNotifier {
  TouristProfile? _currentProfile;
  final List<TouristAlert> _alerts = [];
  bool _isRegistered = false;
  bool _sosActive = false;
  String? _digitalId;

  // Getters
  TouristProfile? get currentProfile => _currentProfile;
  List<TouristAlert> get alerts => List.unmodifiable(_alerts);
  List<TouristAlert> get activeAlerts =>
      _alerts.where((alert) => !alert.isResolved).toList();
  bool get isRegistered => _isRegistered;
  bool get sosActive => _sosActive;
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

  // SOS and Alert Management
  Future<void> triggerSOS({
    required double latitude,
    required double longitude,
    String? customMessage,
  }) async {
    if (_currentProfile == null) return;

    _sosActive = true;

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
      print('SOS TRIGGERED: ${sosAlert.message}');
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

  void logout() {
    _currentProfile = null;
    _alerts.clear();
    _isRegistered = false;
    _sosActive = false;
    _digitalId = null;
    notifyListeners();
  }
}
