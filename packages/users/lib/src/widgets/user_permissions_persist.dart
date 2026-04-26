import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import '../l10n/user_ui_strings.dart';
import '../providers/user_provider.dart';

/// Saves permissions via [UserProvider] and shows success / error snack bars.
Future<void> persistUserPermissionsWithFeedback(
  BuildContext context,
  UserPublic user,
  UserPermissions permissions,
  UserProvider userProvider,
) async {
  try {
    var success =
        await userProvider.updateUserPermissions(user.userId, permissions);

    if (!success) {
      await userProvider.updateUser(user);
    }

    if (!context.mounted) return;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(UserUiStrings.permissionsSavedFor(user.firstname)),
              ),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.fixed,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  } catch (e) {
    if (!context.mounted) return;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(UserUiStrings.permissionsSaveFailed('$e')),
              ),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.fixed,
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }
}
