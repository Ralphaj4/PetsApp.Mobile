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
  bool _canNavigate = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2)).then((_) {
      if (mounted) {
        _canNavigate = true;
        _checkAuthAndNavigate();
      }
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    if (!mounted) return;

    final prefs = await ref.read(sharedPreferencesProvider.future);
    final onboardingCompleted =
        prefs.getBool(AppConstants.onboardingCompletedKey) ?? false;

    if (!mounted) return;

    if (!onboardingCompleted) {
      context.pushReplacement('/onboarding');
      return;
    }
    context.go('/map');
    return;
    // final auth = ref.read(authStateProvider);

    // if (auth.isAuthenticated) {
    //   context.go('/home');
    // } else if (auth.status == AuthStatus.unauthenticated) {
    //   context.go('/login');
    // }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (!_canNavigate || !mounted) return;

      if (next.isAuthenticated) {
        context.go('/home');
      } else if (next.status == AuthStatus.unauthenticated) {
        context.go('/login');
      }
    });

    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/logo.png', width: 120, height: 120),
      ),
    );
  }
}
