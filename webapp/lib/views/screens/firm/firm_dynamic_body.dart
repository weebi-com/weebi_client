import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:intl/intl.dart';

class FirmDynamicBody extends StatelessWidget {
  final Firm firm;

  const FirmDynamicBody({super.key, required this.firm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoTile(
          context,
          Icons.business,
          'Nom',
          firm.name,
        ),
        _buildInfoTile(
          context,
          Icons.fingerprint,
          'ID Entreprise',
          firm.firmId,
          isSelectable: true,
        ),
        if (firm.hasCurrency())
          _buildInfoTile(
            context,
            Icons.monetization_on_outlined,
            'Devise par défaut',
            firm.currency.toUpperCase(),
          ),
        _buildInfoTile(
          context,
          firm.status ? Icons.check_circle : Icons.cancel,
          'Statut',
          firm.status ? 'Actif' : 'Inactif',
          iconColor: firm.status ? Colors.green : Colors.red,
        ),
        if (firm.hasCreationDateUTC())
          _buildInfoTile(
            context,
            Icons.calendar_today,
            'Date de création',
            DateFormat('yyyy-MM-dd HH:mm').format(firm.creationDateUTC.toDateTime()),
          ),
        if (firm.isMailVerified)
          _buildInfoTile(
            context,
            Icons.verified_user,
            'Email vérifié',
            'Oui',
            iconColor: Colors.blue,
          ),
        if (firm.hasIsDualCurrencyEnabled() && firm.isDualCurrencyEnabled) ...[
          _buildInfoTile(
            context,
            Icons.currency_exchange,
            'Double devise activée',
            'Oui',
          ),
          if (firm.hasSecondaryDisplayCurrency())
            _buildInfoTile(
              context,
              Icons.currency_exchange,
              'Devise secondaire',
              firm.secondaryDisplayCurrency.toUpperCase(),
            ),
        ],
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? iconColor,
    bool isSelectable = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label),
      subtitle: isSelectable ? SelectableText(value) : Text(value),
    );
  }
}
