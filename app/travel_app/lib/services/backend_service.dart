import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'http_service.dart';
import '../models/tourist_profile.dart';
import '../models/tourist_alert.dart';

class BackendService {
  static final BackendService _instance = BackendService._internal();
  factory BackendService() => _instance;
  BackendService._internal();

  // User Management
  Future<TouristProfile?> createUser({
    required String name,
    required String email,
    required String phoneNumber,
    required String nationality,
    required String passportNumber,
    required String emergencyContact,
    required String emergencyContactNumber,
    DateTime? dateOfBirth,
    String? address,
    String? gender,
    String? bloodGroup,
  }) async {
    try {
      final userData = {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'nationality': nationality,
        'passportNumber': passportNumber,
        'emergencyContactName': emergencyContact,
        'emergencyContactPhone': emergencyContactNumber,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
        if (address != null) 'address': address,
        if (gender != null) 'gender': gender,
        if (bloodGroup != null) 'bloodGroup': bloodGroup,
        'isActive': true,
      };

      final response = await HttpService.post('/users', userData);
      
      if (response['success'] == true && response['data'] != null) {
        return TouristProfile.fromBackendJson(response['data']);
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user: $e');
      }
      return null;
    }
  }

  Future<TouristProfile?> getUserById(String userId) async {
    try {
      final response = await HttpService.get('/users/$userId');
      
      if (response['success'] == true && response['data'] != null) {
        return TouristProfile.fromBackendJson(response['data']);
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user: $e');
      }
      return null;
    }
  }

  Future<TouristProfile?> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      final response = await HttpService.put('/users/$userId', updates);
      
      if (response['success'] == true && response['data'] != null) {
        return TouristProfile.fromBackendJson(response['data']);
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user: $e');
      }
      return null;
    }
  }

  // KYC Management
  Future<bool> uploadAadharCard(String userId, File? imageFile) async {
    try {
      // Mock implementation - convert image to base64
      String base64Image = '';
      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        base64Image = base64Encode(bytes);
      } else {
        // Mock base64 image for demo
        base64Image = 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/';
      }

      final response = await HttpService.post('/users/$userId/kyc/aadhar', {
        'aadharImage': base64Image,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      return response['success'] == true;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading Aadhar card: $e');
      }
      return false;
    }
  }

  Future<Map<String, dynamic>?> getKycStatus(String userId) async {
    try {
      final response = await HttpService.get('/users/$userId/kyc/status');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching KYC status: $e');
      }
      return null;
    }
  }

  // Trip Management
  Future<String?> createTrip({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> plannedLocations,
  }) async {
    try {
      final tripData = {
        'userId': userId,
        'tripStartDate': startDate.toIso8601String(),
        'tripEndDate': endDate.toIso8601String(),
        'plannedLocations': plannedLocations,
        'status': 'planned',
      };

      final response = await HttpService.post('/trips', tripData);
      
      if (response['success'] == true && response['data'] != null) {
        return response['data']['id'];
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating trip: $e');
      }
      return null;
    }
  }

  Future<bool> updateTripStatus(String tripId, String status) async {
    try {
      final response = await HttpService.put('/trips/$tripId/status', {
        'status': status,
      });
      
      return response['success'] == true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating trip status: $e');
      }
      return false;
    }
  }

  // Alert Management
  Future<bool> createAlert({
    required String userId,
    required String alertType,
    required String message,
    required String severity,
    String? tripId,
    double? latitude,
    double? longitude,
    String? location,
  }) async {
    try {
      final alertData = {
        'userId': userId,
        'alertType': alertType,
        'message': message,
        'severity': severity,
        if (tripId != null) 'tripId': tripId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (location != null) 'location': location,
      };

      final response = await HttpService.post('/alerts', alertData);
      
      return response['success'] == true;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating alert: $e');
      }
      return false;
    }
  }

  Future<List<TouristAlert>> getUserAlerts(String userId) async {
    try {
      final response = await HttpService.get('/alerts/user/$userId');
      
      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((item) => TouristAlert.fromBackendJson(item))
            .toList();
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user alerts: $e');
      }
      return [];
    }
  }

  Future<bool> resolveAlert(String alertId) async {
    try {
      final response = await HttpService.put('/alerts/$alertId/resolve', {});
      return response['success'] == true;
    } catch (e) {
      if (kDebugMode) {
        print('Error resolving alert: $e');
      }
      return false;
    }
  }

  // Location Management
  Future<bool> recordLocation({
    required String userId,
    required double latitude,
    required double longitude,
    String? tripId,
    String? address,
    double? accuracy,
    double? speed,
  }) async {
    try {
      final locationData = {
        'userId': userId,
        'latitude': latitude,
        'longitude': longitude,
        if (tripId != null) 'tripId': tripId,
        if (address != null) 'address': address,
        if (accuracy != null) 'accuracy': accuracy,
        if (speed != null) 'speed': speed,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await HttpService.post('/locations', locationData);
      
      return response['success'] == true;
    } catch (e) {
      if (kDebugMode) {
        print('Error recording location: $e');
      }
      return false;
    }
  }

  // Safety Score
  Future<Map<String, dynamic>?> getSafetyScore({
    required double latitude,
    required double longitude,
    String? userId,
    String? location,
  }) async {
    try {
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        if (userId != null) 'userId': userId,
        if (location != null) 'location': location,
      };

      final query = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await HttpService.get('/safety?$query');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching safety score: $e');
      }
      return null;
    }
  }

  // Health Check
  Future<bool> isBackendHealthy() async {
    try {
      final response = await HttpService.get('/health');
      return response['status'] == 'OK';
    } catch (e) {
      if (kDebugMode) {
        print('Backend health check failed: $e');
      }
      return false;
    }
  }
}
