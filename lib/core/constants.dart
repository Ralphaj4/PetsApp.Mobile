class AppConstants {
  // API endpoints
  static const String baseUrl = 'http://10.0.2.2:3000';
  // For Android emulator: 'http://10.0.2.2:3000'
  // For real device: 'http://YOUR_MACHINE_IP:3000'

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 64;

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingCompletedKey = 'onboarding_completed';
}
