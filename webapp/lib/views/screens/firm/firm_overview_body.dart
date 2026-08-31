import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/generated/l10n.dart';

/// Hardcoded enterprise overview: name, id, currency, status, dates — nothing else.
///
/// Intentionally does **not** render licenses, Stripe/product/price ids, or other
/// billing internals (those belong on the Billing screen).
class FirmOverviewBody extends StatelessWidget {
  final Firm firm;

  const FirmOverviewBody({super.key, required this.firm});

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .add_Hm();

    return Column(
      key: const Key('firmOverviewBody'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(
          icon: Icons.business,
          label: lang.firmNameLabel,
          value: firm.name,
          valueKey: const Key('firmNameValue'),
        ),
        _InfoRow(
          icon: Icons.fingerprint,
          label: lang.firmIdLabel,
          value: firm.firmId,
          selectable: true,
          valueKey: const Key('firmIdValue'),
        ),
        if (firm.hasCurrency() && firm.currency.trim().isNotEmpty)
          _InfoRow(
            icon: Icons.monetization_on_outlined,
            label: lang.firmCurrencyLabel,
            value: firm.currency.toUpperCase(),
          ),
        _InfoRow(
          icon: firm.status ? Icons.check_circle : Icons.cancel,
          label: lang.firmStatusLabel,
          value: firm.status ? lang.firmStatusActive : lang.firmStatusInactive,
          iconColor: firm.status ? Colors.green : Colors.red,
        ),
        if (firm.hasCreationDateUTC())
          _InfoRow(
            icon: Icons.calendar_today,
            label: lang.firmCreatedAtLabel,
            value: dateFormat.format(firm.creationDateUTC.toDateTime().toLocal()),
          ),
        if (firm.isMailVerified)
          _InfoRow(
            icon: Icons.verified_user,
            label: lang.firmEmailVerifiedLabel,
            value: lang.yes,
            iconColor: Colors.blue,
          ),
        if (firm.hasIsDualCurrencyEnabled() && firm.isDualCurrencyEnabled) ...[
          _InfoRow(
            icon: Icons.currency_exchange,
            label: lang.firmDualCurrencyLabel,
            value: lang.yes,
          ),
          if (firm.hasSecondaryDisplayCurrency() &&
              firm.secondaryDisplayCurrency.trim().isNotEmpty)
            _InfoRow(
              icon: Icons.currency_exchange,
              label: lang.firmSecondaryCurrencyLabel,
              value: firm.secondaryDisplayCurrency.toUpperCase(),
            ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final bool selectable;
  final Key? valueKey;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.selectable = false,
    this.valueKey,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor),
      title: Text(label),
      subtitle: selectable
          ? SelectableText(value, key: valueKey)
          : Text(value, key: valueKey),
    );
  }
}
