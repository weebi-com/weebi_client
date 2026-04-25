import 'package:flutter/material.dart';

import '../l10n/boutique_ui_strings.dart';
import '../utils/drc_secondary_currency.dart';
import 'billing_currency_field.dart';

/// Secondary display currency (e.g. USD) when [eligible] is true.
///
/// Soft card, border, and accent icon/switch — same family as `users_weebi`
/// permission rows, kept minimal for boutique forms.
class SecondaryDisplayCurrencyFields extends StatelessWidget {
  const SecondaryDisplayCurrencyFields({
    super.key,
    required this.eligible,
    required this.dualEnabled,
    required this.onDualChanged,
    required this.secondaryController,
    this.isDecorationBorderless = false,
  });

  final bool eligible;
  final bool dualEnabled;
  final bool isDecorationBorderless;
  final ValueChanged<bool> onDualChanged;
  final TextEditingController secondaryController;

  @override
  Widget build(BuildContext context) {
    if (!eligible) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = scheme.primary;
    final borderColor = dualEnabled
        ? accent.withValues(alpha: 0.32)
        : scheme.outlineVariant.withValues(alpha: 0.9);
    final fillColor = dualEnabled
        ? accent.withValues(alpha: 0.07)
        : scheme.surfaceContainerHighest.withValues(alpha: 0.42);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor, width: 1),
      ),
      color: fillColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Theme(
            data: theme.copyWith(
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return accent;
                  }
                  return scheme.outline;
                }),
                trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return accent.withValues(alpha: 0.38);
                  }
                  return scheme.surfaceContainerHighest;
                }),
              ),
            ),
            child: SwitchListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              secondary: Icon(
                Icons.currency_exchange,
                color: dualEnabled ? accent : scheme.onSurfaceVariant,
                size: 24,
              ),
              title: Text(
                BoutiqueUiStrings.dualCurrencySwitchTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              subtitle:   Text(
                BoutiqueUiStrings.dualCurrencySwitchSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              value: dualEnabled,
              onChanged: (v) {
                onDualChanged(v);
                if (v && secondaryController.text.trim().isEmpty) {
                  secondaryController.text =
                      kDefaultSecondaryDisplayCurrencyUsd;
                }
              },
            ),
          ),
          if (dualEnabled) ...[
            Divider(
                height: 1,
                thickness: 1,
                color: borderColor.withValues(alpha: 0.5)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: BillingCurrencyField(
                controller: secondaryController,
                labelText: BoutiqueUiStrings.secondaryDisplayCurrencyLabel,
                tooltip: BoutiqueUiStrings.secondaryDisplayCurrencyTooltip,
                isDecorationBorderless: isDecorationBorderless,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
