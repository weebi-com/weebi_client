import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_country_code_picker_weebi/fl_country_code_picker.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:protos_weebi/utils.dart' show RegExpWeebi;
import '../l10n/user_ui_strings.dart';
import 'phone_field_prefix_icon.dart';
import '../providers/user_provider.dart';

/// Widget for creating or editing a user
class UserFormWidget extends StatefulWidget {
  final UserPublic? user;
  final UserProvider userProvider;
  final VoidCallback? onSaved;

  const UserFormWidget({
    super.key,
    this.user,
    required this.userProvider,
    this.onSaved,
  });

  @override
  State<UserFormWidget> createState() => _UserFormWidgetState();
}

class _UserFormWidgetState extends State<UserFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _mailController;
  late TextEditingController _phoneController;

  // Country code for phone
  CountryCode? _countryCodePhone;

  // Loading and error states
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _firstnameController =
        TextEditingController(text: widget.user?.firstname ?? '');
    _lastnameController =
        TextEditingController(text: widget.user?.lastname ?? '');
    _mailController = TextEditingController(text: widget.user?.mail ?? '');
    _phoneController =
        TextEditingController(text: widget.user?.phone.number ?? '');

    // Initialize country code from existing user or default to France
    if (widget.user?.phone.hasCountryCode() == true) {
      _countryCodePhone =
          CountryCode.fromDialCode('+${widget.user!.phone.countryCode}');
    } else {
      _countryCodePhone = CountryCode.fromDialCode('+221'); // Default to France
    }
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _mailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final user = UserPublic()
        ..firstname = _firstnameController.text.trim()
        ..lastname = _lastnameController.text.trim()
        ..mail = _mailController.text.trim()
        ..phone = (Phone()
          ..countryCode =
              int.tryParse(_countryCodePhone?.dialCode.substring(1) ?? '33') ??
                  33
          ..number = _phoneController.text.trim());

      if (widget.user != null) {
        user.userId = widget.user!.userId;
        user.permissions = widget.user!.permissions;
        user.othersAttributes.addAll(widget.user!.othersAttributes);
        await widget.userProvider.updateUser(user);
      } else {
        await widget.userProvider.createUser(user);
      }

      if (mounted) {
        if (widget.onSaved != null) {
          widget.onSaved!();
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.user != null
                        ? UserUiStrings.userUpdatedSuccess
                        : UserUiStrings.userCreatedSuccessShort,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } on GrpcError catch (e) {
      final errorMsg = '${e.code} ${e.message}';
      setState(() {
        _error = errorMsg;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(UserUiStrings.errorGeneric(errorMsg))),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(UserUiStrings.errorGeneric('$e'))),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final countryPicker = const FlCountryCodePicker();

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error indicator
            if (_error != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red[600]),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(UserUiStrings.errorDialogTitle),
                              content: Text(_error!),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(UserUiStrings.ok),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text(UserUiStrings.details),
                      ),
                    ],
                  ),
                ),
              ),

            if (_error != null) const SizedBox(height: 16),

            // Basic Information Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First Name Field
                    TextFormField(
                      controller: _firstnameController,
                      autofocus:
                          widget.user == null, // Autofocus only for new users
                      decoration: const InputDecoration(
                        labelText: UserUiStrings.labelFirstName,
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return UserUiStrings.firstNameRequired;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Last Name Field
                    TextFormField(
                      controller: _lastnameController,
                      decoration: const InputDecoration(
                        labelText: UserUiStrings.labelLastName,
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return UserUiStrings.lastNameRequired;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Email Field
                    TextFormField(
                      controller: _mailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: UserUiStrings.labelEmail,
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return UserUiStrings.emailRequired;
                        }
                        if (RegExpWeebi.mailFormat.hasMatch(value) == false) {
                          return UserUiStrings.emailInvalid;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Phone Field with Country Code Picker
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: UserUiStrings.labelPhone,
                        prefixIcon: PhoneFieldPrefixIcon(
                          dialCode:
                              _countryCodePhone?.dialCode ?? '+221',
                          onPickDialCode: () async {
                            final code = await countryPicker.showPicker(
                              context: context,
                              pickerMaxHeight: 800,
                            );
                            if (code != null) {
                              setState(() {
                                _countryCodePhone = code;
                              });
                            }
                          },
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minHeight: 48,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (value.length < 8) {
                            return UserUiStrings.phoneTooShort;
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: const Text(UserUiStrings.cancel),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isSaving ? Colors.grey : Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving
                      ? UserUiStrings.saving
                      : (widget.user != null
                          ? UserUiStrings.updateUser
                          : UserUiStrings.createUserShort)),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
