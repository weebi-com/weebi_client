import 'package:flutter/material.dart';
import 'package:protos_weebi/grpc.dart' show GrpcError, StatusCode;
import 'package:protos_weebi/protos_weebi_io.dart'
    show PasswordUpdateRequest, StatusResponse_Type, FenceServiceClient;
import 'package:provider/provider.dart';
import 'package:users_weebi/weebi_users.dart' show UserProvider;
import 'package:users_weebi/fence_client_provider.dart'
    show FenceServiceClientProviderV2;

import '../l10n/access_ui_strings.dart';

class ChangePasswordDialog extends StatefulWidget {
  final String selectedUserId;
  final String firmId;
  final bool isSelfService;
  final VoidCallback? onPasswordChanged;

  const ChangePasswordDialog({
    super.key,
    required this.selectedUserId,
    required this.firmId,
    required this.isSelfService,
    this.onPasswordChanged,
  });

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final ok = await _updateUserPassword(
        selectedUserId: widget.selectedUserId,
        firmId: widget.firmId,
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      if (ok && mounted) {
        widget.onPasswordChanged?.call();
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check, color: Colors.white),
                const SizedBox(width: 8),
                Text(widget.isSelfService
                    ? AccessUiStrings.passwordUpdatedSelf
                    : AccessUiStrings.passwordUpdatedOther),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<bool> _updateUserPassword({
    required String selectedUserId,
    required String firmId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final req = PasswordUpdateRequest()
      ..firmId = firmId
      ..userId = selectedUserId
      ..passwordCurrent = currentPassword
      ..passwordNew = newPassword;

    try {
      FenceServiceClient fenceClient;
      try {
        final p =
            Provider.of<FenceServiceClientProviderV2>(context, listen: false);
        fenceClient = p.fenceServiceClient;
      } catch (_) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        fenceClient = userProvider.fenceServiceClient;
      }
      final res = await fenceClient.updateUserPassword(req);
      return res.type == StatusResponse_Type.UPDATED;
    } on GrpcError catch (e) {
      if (e.code == StatusCode.permissionDenied) {
        throw Exception(AccessUiStrings.noPermissionChangePassword);
      }
      if (e.code == StatusCode.invalidArgument) {
        throw Exception(
            AccessUiStrings.invalidPasswordInput(e.message));
      }
      throw Exception(
          AccessUiStrings.failedUpdatePassword(e.message));
    } catch (e) {
      throw Exception(AccessUiStrings.errorUpdatingPassword(e));
    }
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) return AccessUiStrings.passwordRequired;
    if (value.length < 3) return AccessUiStrings.passwordMinLength;
    // let them be in peace
    // if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
    //   return 'Needs uppercase, lowercase, and number';
    // }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value != _newPasswordController.text) {
      return AccessUiStrings.passwordsDoNotMatch;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isSelfService
          ? AccessUiStrings.changeMyPasswordTitle
          : AccessUiStrings.updateUserPasswordTitle),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: AccessUiStrings.currentPasswordLabel,
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? AccessUiStrings.requiredField
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: AccessUiStrings.newPasswordLabel,
                  border: OutlineInputBorder(),
                ),
                validator: _validateNewPassword,
                onChanged: (_) => _formKey.currentState?.validate(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: AccessUiStrings.confirmPasswordLabel,
                  border: OutlineInputBorder(),
                ),
                validator: _validateConfirm,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMessage!,
                          style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text(AccessUiStrings.cancel),
        ),
        FilledButton.icon(
          onPressed: _isSubmitting ? null : _submit,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.lock_reset),
          label: Text(_isSubmitting
              ? AccessUiStrings.saving
              : (widget.isSelfService
                  ? AccessUiStrings.changePasswordAction
                  : AccessUiStrings.resetPasswordAction)),
        ),
      ],
    );
  }
}
