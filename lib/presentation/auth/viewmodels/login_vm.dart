import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../data/models/auth_response.dart';
import '../../../core/exceptions/dio_exception_handler.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_state_provider.dart';

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>((ref) {
      return LoginViewModel(ref.watch(loginUsecaseProvider), ref);
    });

class LoginState {
  final bool isLoading;
  final String? error;
  final AuthResponse? authResponse;

  LoginState({this.isLoading = false, this.error, this.authResponse});

  LoginState copyWith({
    bool? isLoading,
    String? error,
    AuthResponse? authResponse,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      authResponse: authResponse ?? this.authResponse,
    );
  }
}

class LoginViewModel extends StateNotifier<LoginState> {
  final LoginUsecase _loginUsecase;
  final Ref _ref;

  LoginViewModel(this._loginUsecase, this._ref) : super(LoginState());

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _loginUsecase(email: email, password: password);
      state = state.copyWith(isLoading: false, authResponse: response);

      // Update global auth state with token persistence
      await _ref.read(authStateProvider.notifier).handleLoginSuccess(response);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
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
