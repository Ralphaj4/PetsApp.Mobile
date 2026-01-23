import '../repositories/auth_repository.dart';
import '../../data/models/auth_response.dart';

class LoginUsecase {
  final AuthRepository _authRepository;

  LoginUsecase({required AuthRepository authRepository})
      : _authRepository = authRepository;

  Future<AuthResponse> call({
    required String mobileNumber,
    String? otp,
  }) async {
    return await _authRepository.login(
      mobileNumber: mobileNumber,
      otp: otp,
    );
  }
}
