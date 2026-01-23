import 'package:equatable/equatable.dart';

class LoginDto extends Equatable {
  final String mobileNumber;
  final String otp;

  const LoginDto({
    required this.mobileNumber,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'mobileNumber': mobileNumber,
      'otp': otp,
    };
  }

  @override
  List<Object?> get props => [mobileNumber, otp];
}
