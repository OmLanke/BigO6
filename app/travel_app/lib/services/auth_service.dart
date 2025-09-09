import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'http_service.dart';
import '../models/tourist_profile.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Send OTP to the specified email for verification
  Future<bool> sendEmailOTP(String email) async {
    try {
      final response = await HttpService.post('/users/auth/send-otp', {
        'email': email,
      });

      return response['success'] == true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending email OTP: $e');
      }
      return false;
    }
  }

  /// Verify the OTP received via email
  /// Returns the user ID if verification is successful
  Future<Map<String, dynamic>?> verifyEmailOTP(String email, String otp) async {
    try {
      final response = await HttpService.post('/users/auth/verify-otp', {
        'email': email,
        'otp': otp,
      });

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      }

      return null;
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
    DateTime? dateOfBirth,
    String? address,
    String? gender,
    String? bloodGroup,
  }) async {
    try {
      final userData = {
        'name': name,
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
}
