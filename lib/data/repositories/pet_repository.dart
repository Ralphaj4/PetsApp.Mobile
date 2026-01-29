import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/exceptions/dio_exception_handler.dart';
import '../../domain/repositories/pet_repository.dart' as abstract_repo;
import '../models/pet_model.dart';

class PetRepositoryImpl implements abstract_repo.PetRepository {
  final Dio dio;

  PetRepositoryImpl({required this.dio});

  @override
  Future<List<PetModel>> getPets() async {
    try {
      if (kDebugMode) {
        debugPrint('🔵 Fetching pets list');
        debugPrint('🔵 Base URL: ${dio.options.baseUrl}');
      }

      final response = await dio.get('/api/pets');

      if (kDebugMode) {
        debugPrint('🟢 Pets response received: ${response.statusCode}');
        debugPrint('Response data type: ${response.data.runtimeType}');
        debugPrint('Response data: ${response.data}');
      }

      // Check for error status codes
      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }

      final responseData = response.data;
      List<dynamic> data;

      if (responseData is List<dynamic>) {
        data = responseData;
      } else if (responseData is Map<String, dynamic>) {
        // Handle wrapped response like { "data": [...] } or { "pets": [...] }
        data =
            responseData['data'] as List<dynamic>? ??
            responseData['pets'] as List<dynamic>? ??
            responseData['items'] as List<dynamic>? ??
            [];
      } else {
        throw AppException(
          message: 'Unexpected response format: ${responseData.runtimeType}',
        );
      }

      return data
          .map((json) => PetModel.fromJson(json as Map<String, dynamic>))
          .toList();
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
  Future<PetModel> getPetById(String id) async {
    try {
      if (kDebugMode) {
        debugPrint('🔵 Fetching pet with id: $id');
      }

      final response = await dio.get('/api/pets/$id');

      if (kDebugMode) {
        debugPrint('🟢 Pet detail response received: ${response.statusCode}');
        debugPrint('Response data: ${response.data}');
      }

      // Check for error status codes
      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }

      return PetModel.fromJson(response.data as Map<String, dynamic>);
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
}
