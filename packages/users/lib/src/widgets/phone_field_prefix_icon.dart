import 'package:flutter/material.dart';

/// Phone icon (left) + country dial code control for [TextFormField.prefixIcon].
///
/// Keeps the same structural layout as other outlined fields (single `prefixIcon`
/// slot only — no [InputDecoration.prefix]), so hint/label and text align consistently.
class PhoneFieldPrefixIcon extends StatelessWidget {
  const PhoneFieldPrefixIcon({
    super.key,
    required this.dialCode,
    required this.onPickDialCode,
  });

  final String dialCode;
  final VoidCallback onPickDialCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outline.withValues(alpha: 0.45);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Icon(Icons.phone, color: theme.iconTheme.color),
        ),
        Container(
          width: 1,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: outline,
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPickDialCode,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 4, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(dialCode, style: theme.textTheme.bodyLarge),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 22,
                    color: theme.hintColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}
