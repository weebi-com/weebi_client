import 'package:protos_weebi/utils.dart' show RegExpWeebi;

/// Email validation utilities for the boutiques package
class EmailValidator {
  /// Email validation regex pattern
  static final RegExp _emailRegex = RegExpWeebi.mailFormat;

  /// Validates if the given string is a valid email address
  static bool isValid(String email) {
    if (email.isEmpty) return false;
    return _emailRegex.hasMatch(email);
  }

  /// Validates email and returns a validation message if invalid
  static String? validate(String? email) {
    if (email == null || email.isEmpty) return null;
    if (!isValid(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
