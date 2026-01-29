import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/exceptions/dio_exception_handler.dart';
import '../../domain/repositories/auth_repository.dart' as abstract_repo;
import '../models/auth_response.dart';
import '../models/login_dto.dart';

class AuthRepositoryImpl implements abstract_repo.AuthRepository {
  final Dio dio;

  AuthRepositoryImpl({required this.dio});

  @override
  Future<AuthResponse> login({
    required String mobileNumber,
    String? otp,
  }) async {
    try {
      final loginDto = LoginDto(mobileNumber: mobileNumber, otp: otp ?? '');

      if (kDebugMode) {
        debugPrint('🔵 Attempting login with: ${loginDto.toJson()}');
      }

      final response = await dio.post(
        '/api/Auth/start',
        data: loginDto.toJson(),
      );

      if (kDebugMode) {
        debugPrint('🟢 Login response received: ${response.statusCode}');
        debugPrint('Response data type: ${response.data.runtimeType}');
        debugPrint('Response data: ${response.data}');
      }

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('🔴 DioException: ${e.type}');
        debugPrint('Error: ${e.error}');
        debugPrint('Response: ${e.response?.data}');
      }
      final errorMessage = DioExceptionHandler.handleException(e);
      throw AppException(message: errorMessage, originalException: e);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('🔴 Unexpected error: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      throw AppException(
        message: 'Unexpected error: ${e.toString()}',
        originalException: e,
      );
    }
  }

  @override
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await dio.post(
        '/api/Auth/register',
        data: {'email': email, 'password': password, 'fullName': name},
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = DioExceptionHandler.handleException(e);
      throw AppException(message: errorMessage, originalException: e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post('/api/Auth/revoke');
    } on DioException catch (e) {
      final errorMessage = DioExceptionHandler.handleException(e);
      throw AppException(message: errorMessage, originalException: e);
    }
  }
}
