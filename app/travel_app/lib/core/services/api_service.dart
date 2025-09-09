import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/api_response.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late http.Client _client;

  void initialize() {
    _client = http.Client();
  }

  void dispose() {
    _client.close();
  }

  // Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);

      final response = await _client
          .get(uri, headers: ApiConstants.defaultHeaders)
          .timeout(ApiConstants.receiveTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);

      final response = await _client
          .post(
            uri,
            headers: ApiConstants.defaultHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.sendTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);

      final response = await _client
          .put(
            uri,
            headers: ApiConstants.defaultHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.sendTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);

      final response = await _client
          .delete(uri, headers: ApiConstants.defaultHeaders)
          .timeout(ApiConstants.receiveTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Generic PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);

      final response = await _client
          .patch(
            uri,
            headers: ApiConstants.defaultHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.sendTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Build URI with query parameters
  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final url = '${ApiConstants.apiBaseUrl}$endpoint';
    final uri = Uri.parse(url);

    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }

    return uri;
  }

  // Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Check if response indicates success
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.fromJson(jsonResponse, fromJson);
      } else {
        return ApiResponse<T>(
          success: false,
          message: jsonResponse['message'] ?? 'Request failed',
          errors: jsonResponse['errors'] != null
              ? List<String>.from(jsonResponse['errors'])
              : ['HTTP ${response.statusCode}: ${response.reasonPhrase}'],
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Failed to parse response',
        errors: [e.toString()],
      );
    }
  }

  // Handle errors
  ApiResponse<T> _handleError<T>(dynamic error) {
    String errorMessage = 'Unknown error occurred';

    if (error is SocketException) {
      errorMessage = 'No internet connection';
    } else if (error is http.ClientException) {
      errorMessage = 'Network error';
    } else if (error is FormatException) {
      errorMessage = 'Invalid response format';
    } else {
      errorMessage = error.toString();
    }

    return ApiResponse<T>(
      success: false,
      message: errorMessage,
      errors: [errorMessage],
    );
  }

  // Health check
  Future<ApiResponse<Map<String, dynamic>>> healthCheck() async {
    return get<Map<String, dynamic>>(
      ApiConstants.health,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
