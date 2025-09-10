import 'package:flutter/foundation.dart';
import 'http_service.dart';
import '../models/tourist_profile.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Send OTP to the specified email
  Future<Map<String, dynamic>?> sendEmailOTP(String email, String type) async {
    try {
      final response = await HttpService.post('/users/auth/send-otp', {
        'email': email,
        'type': type,
      });

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending email OTP: $e');
      }
      return null;
    }
  }

  /// Verify the OTP received via email
  /// Returns the full response from the backend
  Future<Map<String, dynamic>?> verifyEmailOTP(String email, String otp, String type) async {
    try {
      final response = await HttpService.post('/users/auth/verify-otp', {
        'email': email,
        'otp': otp,
        'type': type,
      });

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying email OTP: $e');
      }
      return null;
    }
  }

  /// Complete the user registration process after email verification
  Future<TouristProfile?> completeRegistration({
    required String userId,
    required String name,
    required String phoneNumber,
    required String nationality,
    required String passportNumber,
    required String emergencyContact,
    required String emergencyContactNumber,
    String? emergencyContactRelationship,
    DateTime? dateOfBirth,
    String? address,
    String? gender,
    String? bloodGroup,
    double? height,
    double? weight,
    String? languages,
    bool? organDonor,
  }) async {
    try {
      final userData = {
        'name': name,
        'phoneNumber': phoneNumber,
        'nationality': nationality,
        'passportNumber': passportNumber,
        'emergencyContactName': emergencyContact,
        'emergencyContactPhone': emergencyContactNumber,
        if (emergencyContactRelationship != null) 'emergencyContactRelation': emergencyContactRelationship,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
        if (address != null) 'address': address,
        if (gender != null) 'gender': gender,
        if (bloodGroup != null) 'bloodGroup': bloodGroup,
        if (height != null) 'height': height,
        if (weight != null) 'weight': weight,
        if (languages != null) 'languages': languages,
        if (organDonor != null) 'organDonor': organDonor,
        'isActive': true,
      };

      final response = await HttpService.post('/users/$userId/complete-registration', userData);

      if (response['success'] == true && response['data'] != null) {
        return TouristProfile.fromBackendJson(response['data']);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error completing registration: $e');
      }
      return null;
    }
  }

  /// Get user profile completeness status
  Future<Map<String, dynamic>?> getProfileCompleteness(String userId) async {
    try {
      final response = await HttpService.get('/users/$userId/profile/completeness');
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting profile completeness: $e');
      }
      return null;
    }
  }

  /// Validate user data before submission
  Future<Map<String, dynamic>?> validateUserData(Map<String, dynamic> userData) async {
    try {
      final response = await HttpService.post('/users/validate', userData);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error validating user data: $e');
      }
      return null;
    }
  }
}
