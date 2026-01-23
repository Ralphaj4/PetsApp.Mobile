import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import '../constants.dart';

class Validators {
  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password must not exceed ${AppConstants.maxPasswordLength} characters';
    }
    return null;
  }

  /// Validates name field
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validates a non-empty field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates phone number based on country code (ISO code)
  static String? validatePhoneNumber(String? value, String countryCode) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    try {
      // Convert country code to IsoCode enum
      final isoCode = IsoCode.values.firstWhere(
        (code) => code.name == countryCode.toUpperCase(),
        orElse: () => IsoCode.LB,
      );

      final parsedNumber = PhoneNumber.parse(value, callerCountry: isoCode);

      if (!parsedNumber.isValid()) {
        return 'Invalid phone number for $countryCode';
      }

      return null; // Valid
    } catch (e) {
      return 'Invalid phone number format';
    }
  }
}
