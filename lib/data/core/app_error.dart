import 'package:dio/dio.dart';

class AppError implements Exception {
  final String? title;
  final int? statusCode;
  final String? message;

  const AppError({
    this.title,
    this.statusCode,
    this.message,
  });

  @override
  String toString() {
    return 'AppError(title: $title, statusCode: $statusCode, message: $message)';
  }

  /// Maps a DioException or other error to an AppError
  static AppError from(dynamic error) {
    if (error is AppError) {
      return error;
    }

    int? statusCode;
    String? title;
    String? message;

    if (error is DioException) {
      statusCode = error.response?.statusCode;
      final responseData = error.response?.data;

      // Extract error details from response body
      if (responseData != null) {
        if (responseData is Map<String, dynamic>) {
          title = responseData['title'] as String?;
          message = responseData['message'] as String?;
        } else if (responseData is String) {
          message = responseData;
        }
      }

      // Fallback to DioException message if no message from response
      message ??= error.message;

      // Provide default messages based on exception type
      if (error.type == DioExceptionType.connectionError) {
        message ??= 'Unable to connect to the server. Please check your internet connection.';
      } else if (error.type == DioExceptionType.receiveTimeout) {
        message ??= 'Server is not responding. Please try again later.';
      } else if (error.type == DioExceptionType.sendTimeout) {
        message ??= 'Request timed out. Please try again.';
      } else if (error.type == DioExceptionType.cancel) {
        message ??= 'Request was cancelled.';
      } else if (error.response == null && message == null) {
        message = 'An unexpected error occurred. Please try again.';
      }

      // Provide default titles based on status code
      if (title == null) {
        title = _getDefaultTitle(statusCode);
      }
    } else if (error is Exception) {
      message = error.toString();
    }

    return AppError(title: title, statusCode: statusCode, message: message);
  }

  static String? _getDefaultTitle(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 409:
        return 'Conflict';
      case 422:
        return 'Validation Error';
      case 429:
        return 'Too Many Requests';
      case 500:
        return 'Server Error';
      case 502:
        return 'Bad Gateway';
      case 503:
        return 'Service Unavailable';
      default:
        return null;
    }
  }
}