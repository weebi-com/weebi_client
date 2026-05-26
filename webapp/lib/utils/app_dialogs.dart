import 'package:flutter/material.dart';
import '../core/constants/dimens.dart';

enum AppDialogType {
  success,
  error,
  info,
  warning,
  question,
}

class AppDialog {
  static Future<void> show({
    required BuildContext context,
    required AppDialogType dialogType,
    String? title,
    String? desc,
    Widget? body,
    String? btnOkText,
    VoidCallback? btnOkOnPress,
    String? btnCancelText,
    VoidCallback? btnCancelOnPress,
    double? width,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        
        IconData iconData;
        Color iconColor;
        
        switch (dialogType) {
          case AppDialogType.success:
            iconData = Icons.check_circle_outline;
            iconColor = Colors.green;
            break;
          case AppDialogType.error:
            iconData = Icons.error_outline;
            iconColor = Colors.red;
            break;
          case AppDialogType.info:
            iconData = Icons.info_outline;
            iconColor = Colors.blue;
            break;
          case AppDialogType.warning:
            iconData = Icons.warning_amber_outlined;
            iconColor = Colors.orange;
            break;
          case AppDialogType.question:
            iconData = Icons.help_outline;
            iconColor = Colors.blue;
            break;
        }

        return AlertDialog(
          title: Column(
            children: [
              Icon(iconData, color: iconColor, size: 64),
              if (title != null) ...[
                const SizedBox(height: kDefaultPadding),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width ?? kDialogWidth),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (desc != null)
                    Text(
                      desc,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  if (body != null) body,
                ],
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            if (btnCancelText != null || btnCancelOnPress != null)
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  btnCancelOnPress?.call();
                },
                child: Text(btnCancelText ?? 'Cancel'),
              ),
            if (btnOkText != null || btnOkOnPress != null)
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  btnOkOnPress?.call();
                },
                child: Text(btnOkText ?? 'OK'),
              ),
          ],
        );
      },
    );
  }
}
