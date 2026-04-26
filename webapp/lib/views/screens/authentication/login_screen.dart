import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:auth_weebi/auth_weebi.dart' show AccessTokenProvider;
import 'package:provider/provider.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/utils/app_focus_helper.dart';
import 'package:web_admin/views/widgets/public_master_layout/public_master_layout.dart';

import '../../../core/constants/dimens.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/theme_extensions/app_button_theme.dart';
import '../../../core/theme/theme_extensions/app_color_scheme.dart';
import '../../../providers/user_data_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  var _isFormLoading = false;
  var _obscurePassword = true;
  final authService = AuthService();

  void _submitForm() {
    _doLoginAsync(
      onSuccess: () => _onLoginSuccess(context),
      onError: (message) => _onLoginError(context, message),
    );
  }

  Future<void> _doLoginAsync({
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    AppFocusHelper.instance.requestUnfocus();

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      setState(() => _isFormLoading = true);

      try {
        final result = await authService.signIn(
          mail: _formData.mail,
          password: _formData.password,
        );

        if (result.success) {
          if (!mounted) return;
          if (result.accessToken != null && result.accessToken!.isNotEmpty) {
            context.read<AccessTokenProvider>().accessToken = result.accessToken!;
          }
          await context.read<UserDataProvider>().setUserDataAsync(
                mail: _formData.mail,
                accessToken: result.accessToken,
                userProfileImageUrl:
                    'https://www.weebi.com/images/Weebi_Logo_Full.png',
              );

          if (!mounted) return;
          _onLoginSuccess(context);
        } else {
          onError
              .call(result.errorMessage ?? 'Login failed. Please try again.');
        }
      } on GrpcError catch (e) {
        onError.call('${e.codeName} ${e.message}');
      } catch (e) {
        onError.call('An error occurred during login. Please try again.');
      } finally {
        setState(() => _isFormLoading = false);
      }
    }
  }

  void _onLoginSuccess(BuildContext context) {
    GoRouter.of(context).go(RouteUri.home);
  }

  void _onLoginError(BuildContext context, String message) {
    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      desc: message,
      width: kDialogWidth,
      btnOkText: 'OK',
      btnOkOnPress: () {},
    );

    dialog.show();
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final lang = Lang.of(context);
    final formKey = GlobalKey<FormBuilderState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _ForgotPasswordDialog(
        formKey: formKey,
        lang: lang,
        authService: authService,
        onSuccess: () {
          Navigator.of(dialogContext).pop();
          if (context.mounted) _onForgotPasswordSuccess(context);
        },
        onError: (message) {
          Navigator.of(dialogContext).pop();
          if (context.mounted) _onLoginError(context, message);
        },
      ),
    );
  }

  void _onForgotPasswordSuccess(BuildContext context) {
    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      desc: 'Password reset email sent.', 
      width: kDialogWidth,
      btnOkText: 'OK',
      btnOkOnPress: () {},
    );
    dialog.show();
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
            padding: const EdgeInsets.fromLTRB(
              kDefaultPadding,
              kDefaultPadding * 5.0,
              kDefaultPadding,
              kDefaultPadding,
            ),
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
                        'assets/images/app_logo.png', // TODO remove
                        width: 150.0,
                        height: 60.0,
                      ),
                    ),
                    FormBuilder(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: kDefaultPadding * 1.5),
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
                            padding: const EdgeInsets.only(
                                bottom: kDefaultPadding),
                            child: FormBuilderTextField(
                              name: 'password',
                              decoration: InputDecoration(
                                labelText: lang.password,
                                hintText: lang.password,
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscurePassword =
                                          !_obscurePassword),
                                ),
                              ),
                              enableSuggestions: false,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              validator: FormBuilderValidators.required(),
                              onSaved: (value) =>
                                  (_formData.password = value ?? ''),
                              onSubmitted: (_) => _submitForm(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: kDefaultPadding * 2.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                style: themeData
                                    .extension<AppButtonTheme>()!
                                    .primaryText,
                                onPressed: () =>
                                    _showForgotPasswordDialog(context),
                                child: Text(
                                  lang.forgotPassword,
                                  style: TextStyle(
                                    color: themeData
                                        .extension<AppColorScheme>()!
                                        .hyperlink,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
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
                                child: Text(lang.login),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              style: themeData
                                  .extension<AppButtonTheme>()!
                                  .secondaryText,
                              onPressed: () =>
                                  GoRouter.of(context).go(RouteUri.register),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: '${lang.dontHaveAnAccount} ',
                                  style: TextStyle(
                                    color: themeData.colorScheme.onSurface,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: lang.registerNow,
                                      style: TextStyle(
                                        color: themeData
                                            .extension<AppColorScheme>()!
                                            .hyperlink,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog({
    required this.formKey,
    required this.lang,
    required this.authService,
    required this.onSuccess,
    required this.onError,
  });

  final GlobalKey<FormBuilderState> formKey;
  final Lang lang;
  final AuthService authService;
  final VoidCallback onSuccess;
  final void Function(String message) onError;

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  var _isLoading = false;

  Future<void> _submit() async {
    if (widget.formKey.currentState?.validate() ?? false) {
      widget.formKey.currentState!.save();
      final email = widget.formKey.currentState!.value['email'] as String? ?? '';
      setState(() => _isLoading = true);
      try {
        final (success, errorMessage) =
            await widget.authService.requestPasswordReset(mail: email);
        if (!mounted) return;
        if (success) {
          widget.onSuccess();
        } else {
          widget.onError(errorMessage ?? 'Failed to send reset email.');
        }
      } catch (e) {
        if (mounted) widget.onError(e.toString());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.lang.forgotPasswordTitle),
      content: FormBuilder(
        key: widget.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.lang.forgotPasswordMessage),
            const SizedBox(height: kDefaultPadding),
            FormBuilderTextField(
              name: 'email',
              decoration: InputDecoration(
                labelText: widget.lang.mail,
                hintText: widget.lang.mail,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.email(),
              ]),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(widget.lang.cancel),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.lang.submit),
        ),
      ],
    );
  }
}

class FormData {
  String mail = '';
  String password = '';
}
