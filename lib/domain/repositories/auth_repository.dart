import '../../data/models/auth_response.dart';

abstract class AuthRepository {
  Future<AuthResponse> login({
    required String email,
    required String password,
  });

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
  });

  Future<void> logout();
}
