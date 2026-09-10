import 'package:flutter/material.dart';
import 'package:web_admin/core/constants/dimens.dart';

class EntityEmptyState extends StatelessWidget {
  const EntityEmptyState({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onCreate,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: kDefaultPadding),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class EntityEditHeader extends StatelessWidget {
  const EntityEditHeader({
    super.key,
    required this.title,
    required this.onSave,
    required this.onCancel,
    required this.saveLabel,
    required this.cancelLabel,
    this.isSaving = false,
    this.onBack,
  });

  final String title;
  final VoidCallback? onSave;
  final VoidCallback onCancel;
  final String saveLabel;
  final String cancelLabel;
  final bool isSaving;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null)
          IconButton(
            onPressed: isSaving ? null : onBack,
            icon: const Icon(Icons.arrow_back),
          ),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        TextButton(onPressed: isSaving ? null : onCancel, child: Text(cancelLabel)),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: isSaving ? null : onSave,
          child: isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(saveLabel),
        ),
      ],
    );
  }
}

class EntityViewHeader extends StatelessWidget {
  const EntityViewHeader({
    super.key,
    required this.title,
    required this.onEdit,
    required this.editLabel,
    this.onDelete,
    this.deleteLabel,
    this.onBack,
  });

  final String title;
  final VoidCallback onEdit;
  final String editLabel;
  final VoidCallback? onDelete;
  final String? deleteLabel;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null)
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        if (onDelete != null)
          TextButton(
            onPressed: onDelete,
            child: Text(deleteLabel ?? 'Delete'),
          ),
        FilledButton(onPressed: onEdit, child: Text(editLabel)),
      ],
    );
  }
}
