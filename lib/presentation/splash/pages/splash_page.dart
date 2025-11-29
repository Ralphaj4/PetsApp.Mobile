import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/auth/providers/auth_state_provider.dart';
import '../../../core/constants.dart';
import '../../../core/providers/shared_preferences_provider.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();

    // Schedule a post-frame callback to check auth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    final authState = ref.read(authStateProvider);
    final prefsAsync = await ref.read(sharedPreferencesProvider.future);
    final onboardingCompleted =
        prefsAsync.getBool(AppConstants.onboardingCompletedKey) ?? false;

    if (!mounted) return;

    if (!onboardingCompleted) {
      context.go('/onboarding');
    } else if (authState.isAuthenticated) {
      context.go('/home');
    } else if (authState.status == AuthStatus.unauthenticated) {
      context.go('/login');
    }
    // If status unknown, stay on splash
  }

  @override
  Widget build(BuildContext context) {
    // You can still listen to auth changes if needed:
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (!mounted) return;

      if (next.isAuthenticated) {
        context.go('/home');
      } else if (next.status == AuthStatus.unauthenticated) {
        context.go('/login');
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/code.png', width: 120, height: 120),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Loading...', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
