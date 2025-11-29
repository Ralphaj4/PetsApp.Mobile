import '../repositories/auth_repository.dart';
import '../../data/models/auth_response.dart';

class RegisterUsecase {
  final AuthRepository _authRepository;

  RegisterUsecase({required AuthRepository authRepository})
      : _authRepository = authRepository;

  Future<AuthResponse> call({
    required String email,
    required String password,
    required String name,
  }) async {
    return await _authRepository.register(
      email: email,
      password: password,
      name: name,
    );
  }
}
