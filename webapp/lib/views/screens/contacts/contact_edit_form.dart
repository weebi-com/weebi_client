import 'package:design_weebi/design_weebi.dart' show IconsWeebi;
import 'package:fl_country_code_picker_weebi/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:users_weebi/users_weebi.dart' show PhoneFieldPrefixIcon;
import 'package:web_admin/contacts/contact_form_validator.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/entity/entity_chrome.dart';

/// Contact create/edit form (no portal chrome) for tests and [ContactEditScreen].
///
/// Field icons/labels follow the PoS contact create/update forms.
class ContactEditForm extends StatelessWidget {
  const ContactEditForm({
    super.key,
    required this.formKey,
    required this.isNew,
    required this.firstNameController,
    required this.lastNameController,
    required this.mailController,
    required this.phoneController,
    required this.overdraftController,
    required this.streetController,
    required this.codeController,
    required this.cityController,
    required this.countryController,
    required this.isClient,
    required this.isSupplier,
    required this.onIsClientChanged,
    required this.onIsSupplierChanged,
    required this.dialCode,
    required this.onDialCodeChanged,
    required this.onSave,
    required this.onCancel,
    this.isSaving = false,
    this.error,
    this.onFieldsChanged,
  });

  final GlobalKey<FormState> formKey;
  final bool isNew;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController mailController;
  final TextEditingController phoneController;
  final TextEditingController overdraftController;
  final TextEditingController streetController;
  final TextEditingController codeController;
  final TextEditingController cityController;
  final TextEditingController countryController;
  final bool isClient;
  final bool isSupplier;
  final ValueChanged<bool> onIsClientChanged;
  final ValueChanged<bool> onIsSupplierChanged;
  final String dialCode;
  final ValueChanged<CountryCode> onDialCodeChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool isSaving;
  final String? error;
  final VoidCallback? onFieldsChanged;

  bool _canSave(ContactFormValidator validator) {
    if (firstNameController.text.trim().isEmpty) return false;
    if (lastNameController.text.trim().isEmpty) return false;
    return !validator.hasErrors;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final validator = context.watch<ContactFormValidator>();
    final countryPicker = const FlCountryCodePicker();

    return Form(
      key: formKey,
      child: ListView(
        children: [
          EntityEditHeader(
            title: isNew ? lang.contactNew : lang.contactEdit,
            saveLabel: lang.save,
            cancelLabel: lang.cancel,
            isSaving: isSaving,
            onCancel: onCancel,
            onSave: _canSave(validator) ? onSave : null,
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: kDefaultPadding),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(title: lang.contactDetails),
                CardBody(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: firstNameController,
                        decoration: InputDecoration(
                          labelText: lang.contactFirstName,
                          icon: const Icon(Icons.short_text),
                          errorText: validator.firstNameError,
                        ),
                        onChanged: (v) {
                          validator.validateFirstName(v);
                          onFieldsChanged?.call();
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                          labelText: lang.contactLastName,
                          icon: const Icon(Icons.short_text),
                          errorText: validator.lastNameError,
                        ),
                        onChanged: (v) {
                          validator.validateLastName(v);
                          onFieldsChanged?.call();
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: mailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: lang.contactMail,
                          icon: const Icon(IconsWeebi.email),
                          errorText: validator.emailError,
                        ),
                        onChanged: (v) {
                          validator.validateEmail(v);
                          onFieldsChanged?.call();
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: lang.contactPhone,
                          errorText: validator.phoneError,
                          prefixIcon: PhoneFieldPrefixIcon(
                            dialCode: dialCode,
                            onPickDialCode: () async {
                              final code = await countryPicker.showPicker(
                                context: context,
                                pickerMaxHeight: 800,
                              );
                              if (code != null) {
                                onDialCodeChanged(code);
                              }
                            },
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minHeight: 48,
                          ),
                        ),
                        onChanged: (v) {
                          validator.validatePhone(v);
                          onFieldsChanged?.call();
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: overdraftController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: lang.contactOverdraft,
                          icon: const Icon(Icons.verified_user),
                        ),
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.face),
                        title: Text(lang.contactIsClient),
                        value: isClient,
                        onChanged: (v) => onIsClientChanged(v),
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.local_shipping),
                        title: Text(lang.contactIsSupplier),
                        value: isSupplier,
                        onChanged: (v) => onIsSupplierChanged(v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: kDefaultPadding),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(title: lang.contactAddress),
                CardBody(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: streetController,
                        decoration: InputDecoration(
                          labelText: lang.contactStreet,
                          icon: const Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: codeController,
                        decoration: InputDecoration(
                          labelText: lang.contactPostCode,
                          icon: const Icon(Icons.markunread_mailbox),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: cityController,
                        decoration: InputDecoration(
                          labelText: lang.contactCity,
                          icon: const Icon(Icons.location_city),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: countryController,
                        decoration: InputDecoration(
                          labelText: lang.contactCountry,
                          icon: const Icon(Icons.flag),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
