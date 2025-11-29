import '../repositories/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository _authRepository;

  LogoutUsecase({required AuthRepository authRepository})
      : _authRepository = authRepository;

  Future<void> call() async {
    return await _authRepository.logout();
  }
}
