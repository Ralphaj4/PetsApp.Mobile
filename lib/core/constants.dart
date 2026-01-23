class AppConstants {
  // API endpoints
  // static const String baseUrl = 'http://192.168.200.134:5075';
  static const String baseUrl = 'http://192.168.0.109:5075';
  // For Android emulator: 'https://10.0.2.2:7115'
  // For real device: 'https://YOUR_MACHINE_IP:7115'

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 64;

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingCompletedKey = 'onboarding_completed';
}
