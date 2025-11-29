import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../constants.dart';
import '../exceptions/dio_exception_handler.dart';
import '../services/token_storage_service.dart';
import '../../presentation/auth/providers/auth_state_provider.dart';

/// Request interceptor that adds Authorization header with access token
class _AuthorizationInterceptor extends Interceptor {
  final TokenStorageService _tokenStorageService;

  _AuthorizationInterceptor(this._tokenStorageService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get the stored access token
    final accessToken = await _tokenStorageService.getAccessToken();

    // Add token to header if available
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }
}

/// Error interceptor that handles network errors and token refresh
class _ErrorInterceptor extends Interceptor {
  final TokenStorageService _tokenStorageService;
  final Ref _ref;

  // Completer to prevent concurrent token refresh attempts
  Completer<String>? _refreshCompleter;

  // Dedicated Dio for refresh calls (no interceptors)
  late final Dio _refreshDio;

  _ErrorInterceptor(this._tokenStorageService, this._ref) {
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
      ),
    );
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 for token refresh
    if (err.response?.statusCode == 401) {
      try {
        final newAccessToken = await _performRefreshIfNeeded();

        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        final dio =
            (retryOptions.extra['_dio'] as Dio?) ??
            Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

        final retryResponse = await dio.request<dynamic>(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: Options(
            method: err.requestOptions.method,
            headers: retryOptions.headers,
          ),
        );

        handler.resolve(retryResponse);
        return;
      } catch (e) {
        try {
          await _ref
              .read(authStateProvider.notifier)
              .notifyTokenRefreshFailed();
        } catch (_) {}

        final simplified = DioExceptionHandler.handleException(err);
        final appException = AppException(
          message: simplified,
          code: err.response?.statusCode?.toString(),
          originalException: err,
        );
        handler.reject(err.copyWith(error: appException));
        return;
      }
    }

    // Handle other errors
    final simplifiedMessage = DioExceptionHandler.handleException(err);
    final appException = AppException(
      message: simplifiedMessage,
      code: err.response?.statusCode.toString(),
      originalException: err,
    );

    handler.reject(err.copyWith(error: appException));
  }

  /// Ensure only one token refresh happens at a time
  /// Returns the new access token
  Future<String> _performRefreshIfNeeded() async {
    // If a refresh is already in progress, wait for it
    if (_refreshCompleter != null) {
      return await _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<String>();

    try {
      final refreshToken = await _tokenStorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw AppException(message: 'No refresh token available', code: '401');
      }

      // Call refresh endpoint via dedicated Dio (no interceptors)
      final response = await _refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Safely extract tokens
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw AppException(
            message: 'Invalid refresh response format',
            code: '500',
          );
        }

        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];

        // Validate access token
        if (newAccessToken is! String || newAccessToken.isEmpty) {
          throw AppException(
            message: 'Invalid access token in refresh response',
            code: '500',
          );
        }

        // Save tokens (supports token rotation)
        if (newRefreshToken != null &&
            newRefreshToken is String &&
            newRefreshToken.isNotEmpty) {
          await _tokenStorageService.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
        } else {
          await _tokenStorageService.updateAccessToken(newAccessToken);
        }

        _refreshCompleter!.complete(newAccessToken);
        return newAccessToken;
      } else {
        throw AppException(
          message: 'Token refresh failed with status ${response.statusCode}',
          code: response.statusCode?.toString() ?? '500',
        );
      }
    } catch (e) {
      // Complete with error so waiting callers wake up
      if (!_refreshCompleter!.isCompleted) {
        _refreshCompleter!.completeError(e);
      }
      // Clear tokens if refresh failed
      await _tokenStorageService.clearTokens();
      rethrow;
    } finally {
      // Clear completer so future refreshes can run
      _refreshCompleter = null;
    }
  }
}

/// Logging interceptor for debugging (optional, only logs in debug mode)
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('→ REQUEST: ${options.method} ${options.path}');
      debugPrint('  Headers: ${options.headers}');
      if (options.data != null) {
        debugPrint('  Body: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '← RESPONSE: ${response.statusCode} ${response.requestOptions.path}',
      );
      debugPrint('  Data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      debugPrint('⚠️ ERROR: ${err.message}');
      debugPrint('  Type: ${err.type}');
      debugPrint('  Status Code: ${err.response?.statusCode}');
    }
    handler.next(err);
  }
}

/// Provider for TokenStorageService
final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

/// Provider for Dio HTTP client with all interceptors configured
final dioProvider = Provider<Dio>((ref) {
  final tokenStorageService = ref.watch(tokenStorageServiceProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
      validateStatus: (status) {
        // Accept all responses - error handling is in interceptor
        return true;
      },
    ),
  );

  // Add interceptor that passes dio instance via extra
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.extra['_dio'] = dio;
        handler.next(options);
      },
    ),
  );

  // Add logging (debug only)
  dio.interceptors.add(_LoggingInterceptor());

  // Add authorization header
  dio.interceptors.add(_AuthorizationInterceptor(tokenStorageService));

  // Add refresh & error handling (must be last)
  dio.interceptors.add(_ErrorInterceptor(tokenStorageService, ref));

  return dio;
});
