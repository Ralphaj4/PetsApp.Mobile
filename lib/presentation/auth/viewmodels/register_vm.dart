import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/usecases/register_usecase.dart';
import '../../../data/models/auth_response.dart';
import '../../../core/exceptions/dio_exception_handler.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_state_provider.dart';

final registerViewModelProvider =
    StateNotifierProvider<RegisterViewModel, RegisterState>((ref) {
      return RegisterViewModel(ref.watch(registerUsecaseProvider), ref);
    });

class RegisterState {
  final bool isLoading;
  final String? error;
  final AuthResponse? authResponse;

  RegisterState({this.isLoading = false, this.error, this.authResponse});

  RegisterState copyWith({
    bool? isLoading,
    String? error,
    AuthResponse? authResponse,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      authResponse: authResponse ?? this.authResponse,
    );
  }
}

class RegisterViewModel extends StateNotifier<RegisterState> {
  final RegisterUsecase _registerUsecase;
  final Ref _ref;

  RegisterViewModel(this._registerUsecase, this._ref) : super(RegisterState());

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _registerUsecase(
        email: email,
        password: password,
        name: name,
      );
      state = state.copyWith(isLoading: false, authResponse: response);

      // Update global auth state with token persistence
      await _ref.read(authStateProvider.notifier).handleRegisterSuccess(response);
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
