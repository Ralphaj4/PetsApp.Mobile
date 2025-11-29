import 'dart:io';
import 'package:dio/dio.dart';

/// Custom exception class for simplified error handling
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => message;
}

/// Handler for Dio exceptions that converts them to simplified error strings
class DioExceptionHandler {
  /// Converts any exception to a simplified error message
  static String handleException(dynamic exception) {
    if (exception is DioException) {
      return _handleDioException(exception);
    } else if (exception is AppException) {
      return exception.message;
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Handles DioException specifically
  static String _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please check your internet connection.';

      case DioExceptionType.receiveTimeout:
        return 'Response timeout. Please check your internet connection.';

      case DioExceptionType.badResponse:
        return _handleBadResponse(exception);

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.unknown:
        if (exception.error is SocketException) {
          return 'Network error. Please check your internet connection.';
        }
        return 'An unexpected network error occurred. Please try again.';

      case DioExceptionType.badCertificate:
        return 'Security error. Please try again later.';

      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
    }
  }

  /// Handles bad response (HTTP error codes)
  static String _handleBadResponse(DioException exception) {
    final statusCode = exception.response?.statusCode ?? 0;
    final responseData = exception.response?.data;

    switch (statusCode) {
      case 400:
        return _extractErrorMessage(responseData) ?? 'Bad request. Please check your input.';

      case 401:
        return 'Unauthorized. Please log in again.';

      case 403:
        return 'Access denied.';

      case 404:
        return 'Resource not found.';

      case 409:
        return 'Conflict. This resource may already exist.';

      case 422:
        return _extractErrorMessage(responseData) ?? 'Validation error. Please check your input.';

      case 429:
        return 'Too many requests. Please try again later.';

      case 500:
        return 'Server error. Please try again later.';

      case 502:
      case 503:
      case 504:
        return 'Server is temporarily unavailable. Please try again later.';

      default:
        return _extractErrorMessage(responseData) ?? 'An error occurred. Please try again.';
    }
  }

  /// Attempts to extract a meaningful error message from the response data
  static String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // Try common error message fields
      return responseData['message'] ??
             responseData['error'] ??
             responseData['error_message'] ??
             responseData['detail'] ??
             responseData['msg'];
    }
    return null;
  }
}
