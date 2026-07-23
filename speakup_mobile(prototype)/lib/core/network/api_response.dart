class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}

class ApiPaginatedResponse<T> {
  final bool success;
  final String message;
  final List<T> data;
  final Map<String, dynamic>? meta;
  final Map<String, dynamic>? links;

  ApiPaginatedResponse({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
    this.links,
  });

  factory ApiPaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiPaginatedResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => fromJsonT(e))
              .toList() ??
          [],
      meta: json['meta'] as Map<String, dynamic>?,
      links: json['links'] as Map<String, dynamic>?,
    );
  }
}
