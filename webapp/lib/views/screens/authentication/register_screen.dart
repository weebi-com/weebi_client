import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/utils/app_dialogs.dart';
import 'package:web_admin/utils/app_focus_helper.dart';
import 'package:web_admin/views/widgets/public_master_layout/public_master_layout.dart';

import '../../../core/constants/dimens.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/theme_extensions/app_button_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _passwordTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  var _isFormLoading = false;
  var _obscurePassword = true;
  var _obscureRetypePassword = true;
  final authService = AuthService();

  void _submitForm() {
    _doRegisterAsync(
      onSuccess: (message) => _onRegisterSuccess(context, message),
      onError: (message) => _onRegisterError(context, message),
    );
  }

  Future<void> _doRegisterAsync({
    required void Function(String message) onSuccess,
    required void Function(String message) onError,
  }) async {
    AppFocusHelper.instance.requestUnfocus();

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      setState(() => _isFormLoading = true);

      try {
        final result = await authService.signUp(
            firmName: _formData.firmName,
            firstName: _formData.firstName,
            lastName: _formData.lastName,
            mail: _formData.mail,
            password: _formData.password);

        if (result.success) {
          _onRegisterSuccess(
              context, 'Your account has been successfully created');
        } else {
          onError
              .call(result.errorMessage ?? 'Login failed. Please try again.');
        }
      } catch (e) {
        onError.call('An error occurred during register. Please try again.');
      } finally {
        setState(() => _isFormLoading = false);
      }
    }
  }

  void _onRegisterSuccess(BuildContext context, String message) {
    AppDialog.show(
      context: context,
      dialogType: AppDialogType.success,
      desc: message,
      width: kDialogWidth,
      btnOkText: Lang.of(context).loginNow,
      btnOkOnPress: () => GoRouter.of(context).go(RouteUri.login),
    );
  }

  void _onRegisterError(BuildContext context, String message) {
    AppDialog.show(
      context: context,
      dialogType: AppDialogType.error,
      desc: message,
      width: kDialogWidth,
      btnOkText: 'OK',
      btnOkOnPress: () {},
    );
  }

  @override
  void dispose() {
    _passwordTextEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);

    return PublicMasterLayout(
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: const EdgeInsets.only(top: kDefaultPadding),
            constraints: const BoxConstraints(maxWidth: 400.0),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: kDefaultPadding),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: 150.0,
                        height: 60.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: kDefaultPadding),
                      child: Text(
                        lang.register,
                        style: themeData.textTheme.titleMedium,
                      ),
                    ),
                    FormBuilder(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: kDefaultPadding),
                            child: FormBuilderTextField(
                              name: 'firmName',
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.business),
                                labelText: lang.enterpriseNameFieldLabel,
                                hintText: lang.enterpriseNameFieldHint,
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              enableSuggestions: false,
                              textInputAction: TextInputAction.next,
                              validator: FormBuilderValidators.required(),
                              onSaved: (value) =>
                                  (_formData.firmName = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: kDefaultPadding),
                            child: FormBuilderTextField(
                              name: 'firstName',
                              decoration: InputDecoration(
                                labelText: lang.firstName,
                                hintText: lang.firstName,
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              enableSuggestions: false,
                              textInputAction: TextInputAction.next,
                              validator: FormBuilderValidators.required(),
                              onSaved: (value) =>
                                  (_formData.firstName = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: kDefaultPadding),
                            child: FormBuilderTextField(
                              name: 'lastName',
                              decoration: InputDecoration(
                                labelText: lang.lastName,
                                hintText: lang.lastName,
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              enableSuggestions: false,
                              textInputAction: TextInputAction.next,
                              validator: FormBuilderValidators.required(),
                              onSaved: (value) =>
                                  (_formData.lastName = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: kDefaultPadding),
                            child: FormBuilderTextField(
                              name: 'mail',
                              decoration: InputDecoration(
                                labelText: lang.mail,
                                hintText: lang.mail,
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: FormBuilderValidators.required(),
                              onSaved: (value) =>
                                  (_formData.mail = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: kDefaultPadding),
                            child: FormBuilderTextField(
                              name: 'password',
                              decoration: InputDecoration(
                                labelText: lang.password,
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              enableSuggestions: false,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.next,
                              controller: _passwordTextEditingController,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.minLength(4),
                                FormBuilderValidators.maxLength(28),
                              ]),
                              onSaved: (value) =>
                                  (_formData.password = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: kDefaultPadding),
                            child: FormBuilderTextField(
                              name: 'retypePassword',
                              decoration: InputDecoration(
                                labelText: lang.retypePassword,
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureRetypePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () => setState(() =>
                                      _obscureRetypePassword =
                                          !_obscureRetypePassword),
                                ),
                              ),
                              enableSuggestions: false,
                              obscureText: _obscureRetypePassword,
                              textInputAction: TextInputAction.done,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                (value) {
                                  if (_formKey.currentState?.fields['password']
                                          ?.value !=
                                      value) {
                                    return lang.passwordNotMatch;
                                  }

                                  return null;
                                },
                              ]),
                              onSubmitted: (_) => _submitForm(),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: kDefaultPadding),
                            child: SizedBox(
                              height: 40.0,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: themeData
                                    .extension<AppButtonTheme>()!
                                    .primaryElevated,
                                onPressed: _isFormLoading ? null : _submitForm,
                                child: Text(lang.register),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40.0,
                            width: double.infinity,
                            child: OutlinedButton(
                              style: themeData
                                  .extension<AppButtonTheme>()!
                                  .secondaryOutlined,
                              onPressed: () =>
                                  GoRouter.of(context).go(RouteUri.login),
                              child: Text(lang.backToLogin),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FormData {
  String firmName = '';
  String firstName = '';
  String lastName = '';
  String mail = '';
  String password = '';
}
