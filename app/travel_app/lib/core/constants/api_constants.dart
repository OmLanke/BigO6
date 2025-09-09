class ApiConstants {
  // Backend URL - Change this to your deployed backend URL when ready
  static const String baseUrl = 'http://localhost:5000';
  static const String apiVersion = 'v1';
  static const String apiPrefix = '/api';

  // Full API base URL
  static const String apiBaseUrl = '$baseUrl$apiPrefix';

  // Endpoints
  static const String users = '/users';
  static const String trips = '/trips';
  static const String alerts = '/alerts';
  static const String locations = '/locations';
  static const String safety = '/safety';
  static const String geofences = '/geofences';
  static const String health = '/health';

  // Request timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);

  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Developer info
  static const String developerName = 'Pradyum Mistry';
  static const String location = 'India';
}
