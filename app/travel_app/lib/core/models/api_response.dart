class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final List<String>? errors;
  final Map<String, dynamic>? meta;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      message: json['message'],
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
      meta: json['meta'],
    );
  }

  bool get isSuccess => success;
  bool get hasError => !success;
  bool get hasData => data != null;
}
