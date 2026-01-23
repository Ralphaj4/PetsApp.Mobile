import 'package:go_router/go_router.dart';
import 'presentation/splash/pages/splash_page.dart';
import 'presentation/auth/pages/login_page.dart';
import 'presentation/auth/pages/register_page.dart';
import 'presentation/home/pages/home_page.dart';
import 'presentation/onboarding/pages/onboarding_page.dart';
import 'presentation/map/pages/map_page.dart';

final goRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) => const MapPage(),
    ),
  ],
);
