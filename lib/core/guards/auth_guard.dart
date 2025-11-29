import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/auth/providers/auth_state_provider.dart';

/// Helper class to check authentication status and handle redirects
class AuthGuard {
  /// Check if user is authenticated
  static bool isAuthenticated(WidgetRef ref) {
    final authState = ref.read(authStateProvider);
    return authState.isAuthenticated;
  }

  /// Get current user info if authenticated
  static String? getCurrentUserId(WidgetRef ref) {
    final authState = ref.read(authStateProvider);
    return authState.authResponse?.user.id;
  }

  /// Get current user email if authenticated
  static String? getCurrentUserEmail(WidgetRef ref) {
    final authState = ref.read(authStateProvider);
    return authState.authResponse?.user.email;
  }

  /// Watch authentication status (triggers rebuilds when auth state changes)
  static bool watchAuthenticated(WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.isAuthenticated;
  }

  /// Handle logout (clears tokens and resets auth state)
  /// Called when refresh token expires or on explicit logout
  static Future<void> logout(WidgetRef ref) async {
    await ref.read(authStateProvider.notifier).logout();
  }
}
