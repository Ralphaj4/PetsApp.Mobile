import 'package:dio/dio.dart';
import '../../core/exceptions/dio_exception_handler.dart';
import '../../domain/repositories/auth_repository.dart' as abstract_repo;
import '../models/auth_response.dart';

class AuthRepositoryImpl implements abstract_repo.AuthRepository {
  final Dio dio;

  AuthRepositoryImpl({required this.dio});

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = DioExceptionHandler.handleException(e);
      throw AppException(message: errorMessage, originalException: e);
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
        '/auth/register',
        data: {'email': email, 'password': password, 'name': name},
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
      await dio.post('/auth/logout');
    } on DioException catch (e) {
      final errorMessage = DioExceptionHandler.handleException(e);
      throw AppException(message: errorMessage, originalException: e);
    }
  }
}
