import 'package:flutter/foundation.dart';
import 'package:protos_weebi/utils.dart' show RegExpWeebi;
import 'package:web_admin/generated/l10n.dart';

/// Localized messages for contact create/edit validation.
class ContactFormMessages {
  const ContactFormMessages({
    required this.enterFirstName,
    required this.enterLastName,
    required this.emailInvalid,
    required this.phoneTooShort,
  });

  factory ContactFormMessages.fromLang(Lang lang) {
    return ContactFormMessages(
      enterFirstName: lang.contactEnterFirstName,
      enterLastName: lang.contactEnterLastName,
      emailInvalid: lang.contactEmailInvalid,
      phoneTooShort: lang.contactPhoneTooShort,
    );
  }

  final String enterFirstName;
  final String enterLastName;
  final String emailInvalid;
  final String phoneTooShort;
}

/// Provider-based contact form validators (names required; email/phone optional).
class ContactFormValidator extends ChangeNotifier {
  ContactFormValidator({required this.messages});

  final ContactFormMessages messages;

  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? phoneError;

  bool get hasErrors =>
      firstNameError != null ||
      lastNameError != null ||
      emailError != null ||
      phoneError != null;

  void validateFirstName(String value) {
    firstNameError = value.trim().isEmpty ? messages.enterFirstName : null;
    notifyListeners();
  }

  void validateLastName(String value) {
    lastNameError = value.trim().isEmpty ? messages.enterLastName : null;
    notifyListeners();
  }

  void validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      emailError = null;
    } else if (!RegExpWeebi.mailFormat.hasMatch(trimmed)) {
      emailError = messages.emailInvalid;
    } else {
      emailError = null;
    }
    notifyListeners();
  }

  void validatePhone(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      phoneError = null;
    } else if (trimmed.length < 8) {
      phoneError = messages.phoneTooShort;
    } else {
      phoneError = null;
    }
    notifyListeners();
  }

  bool validateAll({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) {
    validateFirstName(firstName);
    validateLastName(lastName);
    validateEmail(email);
    validatePhone(phone);
    return !hasErrors;
  }
}
