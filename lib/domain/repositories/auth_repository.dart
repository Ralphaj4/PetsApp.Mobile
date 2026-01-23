import '../../data/models/auth_response.dart';

abstract class AuthRepository {
  Future<AuthResponse> login({
    required String mobileNumber,
    String? otp,
  });

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
  });

  Future<void> logout();
}
