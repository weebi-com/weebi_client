import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:web_admin/contacts/contact_form_validator.dart';
import 'package:web_admin/views/screens/contacts/contact_edit_form.dart';

import '../helpers/l10n_app.dart';

ContactFormValidator _validator() {
  return ContactFormValidator(
    messages: const ContactFormMessages(
      enterFirstName: 'Saisir le prénom',
      enterLastName: 'Saisir le nom de famille',
      emailInvalid: "L'adresse mail n'est pas correcte",
      phoneTooShort: 'Le numéro doit comporter au moins 8 chiffres',
    ),
  );
}

ContactEditForm _form({
  required TextEditingController firstName,
  required TextEditingController lastName,
  TextEditingController? mail,
  VoidCallback? onSave,
}) {
  return ContactEditForm(
    formKey: GlobalKey<FormState>(),
    isNew: true,
    firstNameController: firstName,
    lastNameController: lastName,
    mailController: mail ?? TextEditingController(),
    phoneController: TextEditingController(),
    overdraftController: TextEditingController(),
    streetController: TextEditingController(),
    codeController: TextEditingController(),
    cityController: TextEditingController(),
    countryController: TextEditingController(),
    isClient: true,
    isSupplier: false,
    onIsClientChanged: (_) {},
    onIsSupplierChanged: (_) {},
    dialCode: '+221',
    onDialCodeChanged: (_) {},
    onSave: onSave ?? () {},
    onCancel: () {},
  );
}

Widget _app(Widget child, {ContactFormValidator? validator}) {
  return l10nApp(
    home: ChangeNotifierProvider.value(
      value: validator ?? _validator(),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('save is disabled when first name is empty', (tester) async {
    await tester.pumpWidget(
      _app(
        _form(
          firstName: TextEditingController(),
          lastName: TextEditingController(text: 'Lovelace'),
        ),
      ),
    );

    final save = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Sauvegarder'),
    );
    expect(save.onPressed, isNull);
  });

  testWidgets('save is disabled when last name is empty', (tester) async {
    await tester.pumpWidget(
      _app(
        _form(
          firstName: TextEditingController(text: 'Ada'),
          lastName: TextEditingController(),
        ),
      ),
    );

    final save = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Sauvegarder'),
    );
    expect(save.onPressed, isNull);
  });

  testWidgets('save is enabled when first and last name are filled',
      (tester) async {
    var saved = false;
    await tester.pumpWidget(
      _app(
        _form(
          firstName: TextEditingController(text: 'Ada'),
          lastName: TextEditingController(text: 'Lovelace'),
          onSave: () => saved = true,
        ),
      ),
    );

    final save = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Sauvegarder'),
    );
    expect(save.onPressed, isNotNull);
    await tester.tap(find.text('Sauvegarder'));
    expect(saved, isTrue);
  });

  testWidgets('invalid email shows error text', (tester) async {
    final validator = _validator();
    final mail = TextEditingController();
    await tester.pumpWidget(
      _app(
        _form(
          firstName: TextEditingController(text: 'Ada'),
          lastName: TextEditingController(text: 'Lovelace'),
          mail: mail,
        ),
        validator: validator,
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mail'),
      'not-an-email',
    );
    await tester.pump();

    expect(validator.emailError, isNotNull);
    expect(find.text("L'adresse mail n'est pas correcte"), findsOneWidget);

    final save = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Sauvegarder'),
    );
    expect(save.onPressed, isNull);
  });

  testWidgets('phone field uses dial-code prefix control', (tester) async {
    await tester.pumpWidget(
      _app(
        _form(
          firstName: TextEditingController(text: 'Ada'),
          lastName: TextEditingController(text: 'Lovelace'),
        ),
      ),
    );

    expect(find.text('+221'), findsOneWidget);
    expect(find.byIcon(Icons.phone), findsOneWidget);
  });
}
