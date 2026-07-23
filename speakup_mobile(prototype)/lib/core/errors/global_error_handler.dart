import 'package:dio/dio.dart';

class AppError implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  AppError(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

class GlobalErrorHandler {
  static AppError handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return AppError('Connection timeout. Please check your internet connection.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;
          
          String message = 'An error occurred.';
          if (responseData is Map && responseData['message'] != null) {
            message = responseData['message'];
          } else {
            switch (statusCode) {
              case 400: message = 'Bad request.'; break;
              case 401: message = 'Unauthorized. Please login again.'; break;
              case 403: message = 'Forbidden. You do not have access.'; break;
              case 404: message = 'Resource not found.'; break;
              case 422: message = 'Validation error.'; break;
              case 500: message = 'Internal server error.'; break;
              case 503: message = 'Service unavailable.'; break;
            }
          }
          return AppError(message, statusCode: statusCode, data: responseData);
        case DioExceptionType.cancel:
          return AppError('Request was cancelled.');
        case DioExceptionType.connectionError:
          return AppError('No internet connection.');
        default:
          return AppError('Unexpected error occurred.');
      }
    }
    return AppError('An unknown error occurred.');
  }
}
