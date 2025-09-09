import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_data.dart';
import '../models/safety_score.dart';
import '../models/geofence.dart';
import '../models/tourist_alert.dart';

class LocationProvider extends ChangeNotifier {
  LocationData? _currentLocation;
  SafetyScore? _currentSafetyScore;
  bool _isTracking = false;
  bool _hasLocationPermission = false;
  String? _locationError;
  StreamSubscription<Position>? _positionStream;
  Timer? _safetyScoreTimer;

  // Dummy geofences for demo
  final List<GeoFence> _geofences = [
    GeoFence(
      id: '1',
      name: 'Red Fort Area',
      description: 'High tourist area with good security',
      centerLatitude: 28.6562,
      centerLongitude: 77.2410,
      radius: 500,
      isRestrictedZone: false,
      tags: ['tourist', 'safe'],
      createdAt: DateTime.now(),
    ),
    GeoFence(
      id: '2',
      name: 'Restricted Military Zone',
      description: 'Military restricted area',
      centerLatitude: 28.6129,
      centerLongitude: 77.2295,
      radius: 1000,
      isRestrictedZone: true,
      tags: ['military', 'restricted'],
      createdAt: DateTime.now(),
    ),
    GeoFence(
      id: '3',
      name: 'Connaught Place',
      description: 'Busy commercial area',
      centerLatitude: 28.6315,
      centerLongitude: 77.2167,
      radius: 300,
      isRestrictedZone: false,
      tags: ['commercial', 'crowded'],
      createdAt: DateTime.now(),
    ),
  ];

  // Getters
  LocationData? get currentLocation => _currentLocation;
  SafetyScore? get currentSafetyScore => _currentSafetyScore;
  bool get isTracking => _isTracking;
  bool get hasLocationPermission => _hasLocationPermission;
  String? get locationError => _locationError;
  List<GeoFence> get geofences => _geofences;

  Future<void> initializeLocation() async {
    try {
      _locationError = null;

      // Check and request permissions
      await _checkPermissions();

      if (_hasLocationPermission) {
        // Get initial location
        await _getCurrentLocation();

        // Start tracking if permission granted
        await startTracking();
      }
    } catch (e) {
      _locationError = 'Failed to initialize location: $e';
      notifyListeners();
    }
  }

  Future<void> _checkPermissions() async {
    try {
      // Check if location services are enabled first
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationError = 'Location services are disabled. Please enable them in settings.';
        _hasLocationPermission = false;
        notifyListeners();
        return;
      }

      // Check location permission using Geolocator
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever) {
        _locationError = 'Location permissions are permanently denied. Please enable them in settings.';
        _hasLocationPermission = false;
      } else if (permission == LocationPermission.denied) {
        _locationError = 'Location permission denied.';
        _hasLocationPermission = false;
      } else {
        _hasLocationPermission = true;
        _locationError = null;
      }
      
      notifyListeners();
    } catch (e) {
      _locationError = 'Failed to check permissions: $e';
      _hasLocationPermission = false;
      notifyListeners();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentLocation = LocationData.fromPosition(position);
      _updateSafetyScore();
      _checkGeofences();

      notifyListeners();
    } catch (e) {
      _locationError = 'Failed to get current location: $e';
      notifyListeners();
    }
  }

  Future<void> startTracking() async {
    if (!_hasLocationPermission || _isTracking) return;

    try {
      _isTracking = true;
      _locationError = null;

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen(
            (Position position) {
              _currentLocation = LocationData.fromPosition(position);
              _updateSafetyScore();
              _checkGeofences();
              notifyListeners();
            },
            onError: (e) {
              _locationError = 'Location tracking error: $e';
              notifyListeners();
            },
          );

      // Update safety score periodically
      _safetyScoreTimer = Timer.periodic(
        const Duration(minutes: 5),
        (timer) => _updateSafetyScore(),
      );

      notifyListeners();
    } catch (e) {
      _locationError = 'Failed to start tracking: $e';
      _isTracking = false;
      notifyListeners();
    }
  }

  void stopTracking() {
    _isTracking = false;
    _positionStream?.cancel();
    _safetyScoreTimer?.cancel();
    notifyListeners();
  }

  void _updateSafetyScore() {
    if (_currentLocation == null) return;

    // Check if in restricted zones
    bool isInRestrictedZone = _geofences
        .where((fence) => fence.isRestrictedZone && fence.isActive)
        .any(
          (fence) => fence.containsPoint(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
          ),
        );

    // Calculate crowd density (mock data)
    int crowdDensity = DateTime.now().hour >= 9 && DateTime.now().hour <= 18
        ? 6
        : 3; // Higher during day hours

    // Check police presence (mock data)
    bool hasPolicePresence = _geofences
        .where((fence) => fence.tags.contains('safe'))
        .any(
          (fence) => fence.containsPoint(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
          ),
        );

    _currentSafetyScore = SafetyScore.calculate(
      latitude: _currentLocation!.latitude,
      longitude: _currentLocation!.longitude,
      currentTime: DateTime.now(),
      isRestrictedZone: isInRestrictedZone,
      crowdDensity: crowdDensity,
      hasPolicePresence: hasPolicePresence,
    );
  }

  void _checkGeofences() {
    if (_currentLocation == null) return;

    for (GeoFence fence in _geofences.where((f) => f.isActive)) {
      if (fence.containsPoint(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      )) {
        // Create geofence alert
        TouristAlert alert = TouristAlert.createGeofenceAlert(
          touristId: 'current_user', // This would be the actual user ID
          latitude: _currentLocation!.latitude,
          longitude: _currentLocation!.longitude,
          zoneName: fence.name,
          isRestricted: fence.isRestrictedZone,
        );

        // In a real app, this would be sent to a backend or local notification
        if (kDebugMode) {
          print('Geofence Alert: ${alert.title} - ${alert.message}');
        }
      }
    }
  }

  Future<void> refreshLocation() async {
    if (_hasLocationPermission) {
      await _getCurrentLocation();
    } else {
      await _checkPermissions();
      if (_hasLocationPermission) {
        await _getCurrentLocation();
      }
    }
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  // New methods for the map screen
  Future<void> startLiveTracking() async {
    await startTracking();
  }

  Future<void> stopLiveTracking() async {
    stopTracking();
  }

  // Add hasPermission getter
  bool get hasPermission => _hasLocationPermission;

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
