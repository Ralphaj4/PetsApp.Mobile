import '../repositories/auth_repository.dart';
import '../../data/models/auth_response.dart';

class LoginUsecase {
  final AuthRepository _authRepository;

  LoginUsecase({required AuthRepository authRepository})
      : _authRepository = authRepository;

  Future<AuthResponse> call({
    required String email,
    required String password,
  }) async {
    return await _authRepository.login(
      email: email,
      password: password,
    );
  }
}
