# PetsApp Architecture Guide

## Overview

This app uses **Clean Architecture + MVVM** with **Riverpod** for state management.

```
lib/
├── core/           # Services, providers, utils, theme
├── data/           # Models & repository implementations
├── domain/         # Use cases & abstract repositories
└── presentation/   # UI (pages, viewmodels, widgets)
```

---

## Layer Responsibilities

| Layer | Contains | Depends On |
|-------|----------|------------|
| **Presentation** | Pages, ViewModels, Widgets | Domain |
| **Domain** | Use Cases, Abstract Repos | Nothing |
| **Data** | Repo Implementations, Models | Domain interfaces |
| **Core** | Services, HTTP config, Utils | External packages |

---

## Why Each Component?

### Providers (Dependency Injection)

Providers wire everything together and make dependencies injectable/testable.

```dart
// core/providers/http_providers.dart
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: Constants.baseUrl));
  dio.interceptors.add(_AuthorizationInterceptor(...));
  return dio;
});

// presentation/auth/providers/auth_providers.dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(dio: ref.watch(dioProvider));
});

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(authRepository: ref.watch(authRepositoryProvider));
});
```

**Why?** Swap implementations easily (e.g., mock for testing), automatic dependency resolution.

---

### Repositories (Data Access)

Abstract interface in `domain/`, implementation in `data/`.

```dart
// domain/repositories/auth_repository.dart (ABSTRACT)
abstract class AuthRepository {
  Future<AuthResponse> login({required String mobileNumber, String? otp});
}

// data/repositories/auth_repository.dart (IMPLEMENTATION)
class AuthRepositoryImpl implements AuthRepository {
  final Dio dio;

  @override
  Future<AuthResponse> login({required String mobileNumber, String? otp}) async {
    final response = await dio.post('/api/Auth/login', data: {...});
    return AuthResponse.fromJson(response.data);
  }
}
```

**Why?** Domain layer doesn't know about HTTP/databases. Easy to swap data sources.

---

### Use Cases (Business Logic)

Single-purpose classes that orchestrate operations.

```dart
// domain/usecases/login_usecase.dart
class LoginUsecase {
  final AuthRepository _authRepository;

  LoginUsecase({required AuthRepository authRepository})
      : _authRepository = authRepository;

  Future<AuthResponse> call({required String mobileNumber, String? otp}) {
    return _authRepository.login(mobileNumber: mobileNumber, otp: otp);
  }
}
```

**Why?** Reusable business logic. ViewModels stay thin. Easy to test in isolation.

---

### ViewModels (State Management)

Manage UI state using `StateNotifier`.

```dart
// presentation/auth/viewmodels/login_vm.dart
class LoginState {
  final bool isLoading;
  final String? error;
  final AuthResponse? authResponse;
}

class LoginViewModel extends StateNotifier<LoginState> {
  final LoginUsecase _loginUsecase;

  Future<void> login({required String mobileNumber}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _loginUsecase(mobileNumber: mobileNumber);
      state = state.copyWith(isLoading: false, authResponse: response);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }
}

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>((ref) {
      return LoginViewModel(ref.watch(loginUsecaseProvider), ref);
    });
```

**Why?** Separates UI logic from widgets. Testable. Reactive state updates.

---

### Pages (UI)

Consume state via `ref.watch()`, trigger actions via `ref.read()`.

```dart
// presentation/auth/pages/login_page.dart
class LoginPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginViewModelProvider);

    ref.listen(loginViewModelProvider, (prev, next) {
      if (next.authResponse != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });

    return Scaffold(
      body: state.isLoading
        ? CircularProgressIndicator()
        : LoginForm(onSubmit: _handleLogin),
    );
  }

  void _handleLogin() {
    ref.read(loginViewModelProvider.notifier).login(mobileNumber: '...');
  }
}
```

---

## Data Flow

```
User Action → Page → ViewModel → UseCase → Repository → API
                ↑                                        ↓
                └──────────── State Update ←─────────────┘
```

**Login Example:**
1. User taps login → `ref.read(loginViewModelProvider.notifier).login()`
2. ViewModel sets `isLoading: true`, calls `LoginUsecase`
3. UseCase calls `AuthRepository.login()`
4. Repository makes HTTP request, returns `AuthResponse`
5. ViewModel updates state with response
6. UI rebuilds via `ref.watch()`, navigates to home

---

## Quick Reference

| What | Where | Example |
|------|-------|---------|
| HTTP client | `core/providers/http_providers.dart` | `dioProvider` |
| Feature providers | `presentation/{feature}/providers/` | `loginUsecaseProvider` |
| Business logic | `domain/usecases/` | `LoginUsecase` |
| Data contracts | `domain/repositories/` | `abstract AuthRepository` |
| API calls | `data/repositories/` | `AuthRepositoryImpl` |
| State management | `presentation/{feature}/viewmodels/` | `LoginViewModel` |
| UI | `presentation/{feature}/pages/` | `LoginPage` |
