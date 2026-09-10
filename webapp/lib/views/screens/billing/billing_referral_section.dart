import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/views/screens/billing/billing_plan_label.dart';

/// Resolves the referral code sent to checkout (null = omit / empty).
String? referralCodeForCheckout({
  required String entered,
  required String? ownReferralCode,
}) {
  final code = entered.trim();
  if (code.isEmpty) return null;
  if (ownReferralCode != null && code == ownReferralCode) return null;
  return code;
}

bool isSelfReferralCode({
  required String entered,
  required String? ownReferralCode,
}) {
  final code = entered.trim();
  if (code.isEmpty || ownReferralCode == null) return false;
  return code == ownReferralCode;
}

/// Buyer discount preview (must match server referral buyer discount %).
const int kReferralBuyerDiscountPercentPreview = 10;

int referralBuyerDiscountCents(int catalogAmountCents) {
  if (catalogAmountCents <= 0) return 0;
  return (catalogAmountCents * kReferralBuyerDiscountPercentPreview / 100)
      .round();
}

int referralBuyerChargeCents(int catalogAmountCents) {
  final charge =
      catalogAmountCents - referralBuyerDiscountCents(catalogAmountCents);
  return charge < 0 ? 0 : charge;
}

Future<void> showReferralProgramDialog(BuildContext context) {
  final lang = Lang.of(context);
  final themeData = Theme.of(context);
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(lang.billingReferralTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 420),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.billingReferralIntro,
                  style: themeData.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
                const SizedBox(height: kDefaultPadding),
                Text(
                  lang.billingReferralHowTitle,
                  style: themeData.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _ReferralStep(index: 1, text: lang.billingReferralStepShare),
                _ReferralStep(index: 2, text: lang.billingReferralStepDiscount),
                _ReferralStep(index: 3, text: lang.billingReferralStepCredit),
                const SizedBox(height: 8),
                Text(
                  lang.billingReferralCreditHint,
                  style: themeData.textTheme.bodySmall?.copyWith(
                    color: themeData.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(lang.billingReferralDialogClose),
          ),
        ],
      );
    },
  );
}

/// Compact distributor card: own code + crédits weebi, details on demand.
class BillingReferralSection extends StatelessWidget {
  const BillingReferralSection({
    super.key,
    required this.ownReferralCode,
    required this.creditBalanceCents,
  });

  final String? ownReferralCode;
  final int creditBalanceCents;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final lang = Lang.of(context);
    final hasOwnCode =
        ownReferralCode != null && ownReferralCode!.isNotEmpty;
    final valueStyle = themeData.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      height: 1.2,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeData.colorScheme.outline.withValues(alpha: 0.45),
        ),
        color: themeData.colorScheme.primaryContainer.withValues(alpha: 0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  lang.billingReferralTitle,
                  style: themeData.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                key: const Key('billingReferralLearnMore'),
                onPressed: () => showReferralProgramDialog(context),
                child: Text(lang.billingReferralHowTitle),
              ),
            ],
          ),
          Text(
            lang.billingReferralTease,
            style: themeData.textTheme.bodySmall?.copyWith(
              color: themeData.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          if (hasOwnCode) ...[
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 700;
                const valueRowHeight = 48.0;
                final codeBlock = _MetricTile(
                  label: lang.billingReferralYourCode,
                  child: SizedBox(
                    height: valueRowHeight,
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SelectableText(
                              ownReferralCode!,
                              key: const Key('billingOwnReferralCode'),
                              style: valueStyle,
                            ),
                          ),
                        ),
                        IconButton(
                          key: const Key('billingCopyReferralCode'),
                          tooltip: lang.billingReferralCopyCode,
                          visualDensity: VisualDensity.compact,
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: ownReferralCode!),
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(lang.billingReferralCopied),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 20),
                        ),
                      ],
                    ),
                  ),
                );
                final creditBlock = _MetricTile(
                  label: lang.billingReferralCreditBalance,
                  child: SizedBox(
                    height: valueRowHeight,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatWeebiCredit(creditBalanceCents),
                        key: const Key('billingWeebiCreditAmount'),
                        style: valueStyle,
                      ),
                    ),
                  ),
                );
                if (stacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      codeBlock,
                      const SizedBox(height: 12),
                      creditBlock,
                    ],
                  );
                }
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: codeBlock),
                      const SizedBox(width: 12),
                      Expanded(child: creditBlock),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Sponsor code field for the Weebi Premium purchase card.
class BillingReferrerCodeField extends StatelessWidget {
  const BillingReferrerCodeField({
    super.key,
    required this.controller,
    required this.errorText,
    required this.onChanged,
    this.style,
  });

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final BillingReferrerFieldStyle? style;

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);
    final colors = style;
    final labelColor = colors?.labelColor ??
        themeData.colorScheme.onSurfaceVariant;
    final textColor = colors?.textColor ?? themeData.colorScheme.onSurface;
    final borderColor = colors?.borderColor ?? themeData.colorScheme.outline;

    return TextField(
      key: const Key('billingReferralTextField'),
      controller: controller,
      style: themeData.textTheme.bodyMedium?.copyWith(color: textColor),
      cursorColor: textColor,
      decoration: InputDecoration(
        labelText: lang.billingReferralCodeHint,
        labelStyle: themeData.textTheme.bodySmall?.copyWith(color: labelColor),
        helperText: lang.billingReferralDiscountHint,
        helperStyle: themeData.textTheme.bodySmall?.copyWith(color: labelColor),
        errorText: errorText,
        filled: true,
        fillColor: colors?.fillColor ?? themeData.colorScheme.surface,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor.withValues(alpha: 0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: textColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: themeData.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: themeData.colorScheme.error, width: 1.5),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class BillingReferrerFieldStyle {
  const BillingReferrerFieldStyle({
    required this.labelColor,
    required this.textColor,
    required this.borderColor,
    required this.fillColor,
  });

  final Color labelColor;
  final Color textColor;
  final Color borderColor;
  final Color fillColor;
}

class _ReferralStep extends StatelessWidget {
  const _ReferralStep({
    required this.index,
    required this.text,
  });

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: themeData.colorScheme.primary,
            foregroundColor: themeData.colorScheme.onPrimary,
            child: Text(
              '$index',
              style: themeData.textTheme.labelSmall?.copyWith(
                color: themeData.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(text, style: themeData.textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: themeData.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: themeData.dividerColor.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: themeData.textTheme.bodySmall?.copyWith(
              color: themeData.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
