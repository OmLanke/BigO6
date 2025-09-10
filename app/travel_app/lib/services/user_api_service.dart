import '../core/models/api_response.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/tourist_profile.dart';

class UserApiService {
  static final UserApiService _instance = UserApiService._internal();
  factory UserApiService() => _instance;
  UserApiService._internal();

  final ApiService _apiService = ApiService();

  // Get all users
  Future<ApiResponse<List<TouristProfile>>> getUsers() async {
    return _apiService.get<List<TouristProfile>>(
      ApiConstants.users,
      fromJson: (json) =>
          (json as List).map((item) => TouristProfile.fromJson(item)).toList(),
    );
  }

  // Get user by ID
  Future<ApiResponse<TouristProfile>> getUserById(String userId) async {
    return _apiService.get<TouristProfile>(
      '${ApiConstants.users}/$userId',
      fromJson: (json) => TouristProfile.fromJson(json),
    );
  }

  // Create new user
  Future<ApiResponse<TouristProfile>> createUser(
    Map<String, dynamic> userData,
  ) async {
    return _apiService.post<TouristProfile>(
      ApiConstants.users,
      body: userData,
      fromJson: (json) => TouristProfile.fromJson(json),
    );
  }

  // Update user
  Future<ApiResponse<TouristProfile>> updateUser(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    return _apiService.put<TouristProfile>(
      '${ApiConstants.users}/$userId',
      body: userData,
      fromJson: (json) => TouristProfile.fromJson(json),
    );
  }

  // Delete user
  Future<ApiResponse<void>> deleteUser(String userId) async {
    return _apiService.delete<void>('${ApiConstants.users}/$userId');
  }

  // Upload Aadhar card (Mock KYC)
  Future<ApiResponse<TouristProfile>> uploadAadharCard(
    String userId,
    String base64Image,
  ) async {
    return _apiService.post<TouristProfile>(
      '${ApiConstants.users}/$userId/kyc/aadhar',
      body: {
        'aadharImage': base64Image,
        'timestamp': DateTime.now().toIso8601String(),
      },
      fromJson: (json) => TouristProfile.fromJson(json),
    );
  }

  // Get KYC status
  Future<ApiResponse<Map<String, dynamic>>> getKycStatus(String userId) async {
    return _apiService.get<Map<String, dynamic>>(
      '${ApiConstants.users}/$userId/kyc/status',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // Register tourist (convenience method)
  Future<ApiResponse<TouristProfile>> registerTourist({
    required String name,
    required String email,
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
  }) async {
    final userData = {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'nationality': nationality,
      'passportNumber': passportNumber,
      'emergencyContactName': emergencyContact,
      'emergencyContactPhone': emergencyContactNumber,
      if (emergencyContactRelationship != null) 'emergencyContactRelationship': emergencyContactRelationship,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
      if (address != null) 'address': address,
      if (gender != null) 'gender': gender,
      if (bloodGroup != null) 'bloodGroup': bloodGroup,
      'isActive': true,
    };

    return createUser(userData);
  }
}
