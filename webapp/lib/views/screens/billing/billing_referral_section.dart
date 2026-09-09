import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';

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

/// Referral code field + own-code display (ValueKeys for Patrol / widget tests).
class BillingReferralSection extends StatelessWidget {
  const BillingReferralSection({
    super.key,
    required this.controller,
    required this.ownReferralCode,
    required this.creditBalanceCents,
    required this.errorText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String? ownReferralCode;
  final int creditBalanceCents;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final lang = Lang.of(context);
    final balanceEuros = (creditBalanceCents / 100).toStringAsFixed(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.billingReferralTitle,
          style: themeData.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (ownReferralCode != null && ownReferralCode!.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  '${lang.billingReferralYourCode}: $ownReferralCode',
                  key: const Key('billingOwnReferralCode'),
                  style: themeData.textTheme.bodyMedium,
                ),
              ),
              TextButton.icon(
                key: const Key('billingCopyReferralCode'),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: ownReferralCode!),
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(lang.billingReferralCopyCode)),
                  );
                },
                icon: const Icon(Icons.copy, size: 18),
                label: Text(lang.billingReferralCopyCode),
              ),
            ],
          ),
          Text(
            '${lang.billingReferralCreditBalance}: €$balanceEuros',
            style: themeData.textTheme.bodySmall?.copyWith(
              color: themeData.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: kDefaultPadding),
        ],
        TextField(
          key: const Key('billingReferralTextField'),
          controller: controller,
          decoration: InputDecoration(
            labelText: lang.billingReferralCodeHint,
            helperText: lang.billingReferralDiscountHint,
            errorText: errorText,
            border: const OutlineInputBorder(),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
