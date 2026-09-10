import 'package:flutter_test/flutter_test.dart';
import 'package:web_admin/contacts/contact_form_validator.dart';

ContactFormMessages get _messages => const ContactFormMessages(
      enterFirstName: 'Saisir le prénom',
      enterLastName: 'Saisir le nom de famille',
      emailInvalid: "L'adresse mail n'est pas correcte",
      phoneTooShort: 'Le numéro doit comporter au moins 8 chiffres',
    );

void main() {
  test('first and last name are required', () {
    final validator = ContactFormValidator(messages: _messages);
    validator.validateFirstName('');
    validator.validateLastName('  ');
    expect(validator.firstNameError, 'Saisir le prénom');
    expect(validator.lastNameError, 'Saisir le nom de famille');
    expect(validator.hasErrors, isTrue);

    validator.validateFirstName('Ada');
    validator.validateLastName('Lovelace');
    expect(validator.firstNameError, isNull);
    expect(validator.lastNameError, isNull);
  });

  test('email is optional but must match RegExpWeebi.mailFormat', () {
    final validator = ContactFormValidator(messages: _messages);
    validator.validateEmail('');
    expect(validator.emailError, isNull);

    validator.validateEmail('not-an-email');
    expect(validator.emailError, "L'adresse mail n'est pas correcte");

    validator.validateEmail('ada@example.com');
    expect(validator.emailError, isNull);
  });

  test('phone is optional but must have at least 8 digits when set', () {
    final validator = ContactFormValidator(messages: _messages);
    validator.validatePhone('');
    expect(validator.phoneError, isNull);

    validator.validatePhone('1234567');
    expect(
      validator.phoneError,
      'Le numéro doit comporter au moins 8 chiffres',
    );

    validator.validatePhone('12345678');
    expect(validator.phoneError, isNull);
  });

  test('validateAll succeeds for valid required fields only', () {
    final validator = ContactFormValidator(messages: _messages);
    final ok = validator.validateAll(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: '',
      phone: '',
    );
    expect(ok, isTrue);
  });

  test('validateAll fails on invalid optional email', () {
    final validator = ContactFormValidator(messages: _messages);
    final ok = validator.validateAll(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'bad',
      phone: '',
    );
    expect(ok, isFalse);
    expect(validator.emailError, isNotNull);
  });
}
