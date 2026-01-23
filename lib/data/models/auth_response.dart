import 'package:equatable/equatable.dart';
import 'user_model.dart';

class AuthResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final UserModel? user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      if (user != null) 'user': user!.toJson(),
    };
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
