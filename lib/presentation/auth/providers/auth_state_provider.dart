import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/token_storage_service.dart';
import '../../../core/providers/http_providers.dart';
import '../../../data/models/auth_response.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AuthResponse? authResponse;

  const AuthState._({
    required this.status,
    this.authResponse,
  });

  const AuthState.unknown() : this._(status: AuthStatus.unknown);
  const AuthState.authenticated(AuthResponse? authResponse)
      : this._(status: AuthStatus.authenticated, authResponse: authResponse);
  const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

/// Global authentication state provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final tokenStorageService = ref.watch(tokenStorageServiceProvider);
  return AuthStateNotifier(tokenStorageService);
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final TokenStorageService _tokenStorageService;

  AuthStateNotifier(this._tokenStorageService) : super(const AuthState.unknown()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final hasTokens = await _tokenStorageService.hasTokens();
      state = hasTokens
          ? const AuthState.authenticated(null)
          : const AuthState.unauthenticated();
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  /// Called after successful login to save auth state
  Future<void> handleLoginSuccess(AuthResponse authResponse) async {
    try {
      await _tokenStorageService.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
      state = AuthState.authenticated(authResponse);
    } catch (e) {
      state = const AuthState.unauthenticated();
      rethrow;
    }
  }

  /// Called after successful registration
  Future<void> handleRegisterSuccess(AuthResponse authResponse) async {
    await handleLoginSuccess(authResponse);
  }

  /// Logout and clear all authentication data
  Future<void> logout() async {
    try {
      await _tokenStorageService.clearTokens();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = const AuthState.unauthenticated();
      rethrow;
    }
  }

  /// Called when token refresh fails (during interceptor)
  Future<void> notifyTokenRefreshFailed() async {
    await logout();
  }
}
