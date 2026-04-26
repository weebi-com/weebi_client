import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import '../../boutique.dart';
import '../../dynamic_body.dart';
import 'detail_view_components.dart';

/// Widget for displaying detailed information about a boutique using dynamic body
class BoutiqueDetailWidget extends StatelessWidget {
  final BoutiqueMongo boutique;
  final bool showEditButton;
  final VoidCallback? onEdit;

  const BoutiqueDetailWidget({
    super.key,
    required this.boutique,
    this.showEditButton = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(boutique.displayName),
        actions: [
          if (showEditButton)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
              tooltip: 'Modifier la boutique',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(context),
          Expanded(
            child: BoutiqueDynamicBody<BoutiqueMongo>(pbObject: boutique),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return DetailViewComponents.buildSummaryCard(
      title: boutique.displayName,
      subtitle: boutique.formattedAddress.isNotEmpty 
          ? boutique.formattedAddress 
          : 'Aucune adresse',
      icon: Icons.store,
      avatar: boutique.logo.isNotEmpty && boutique.logoExtension.isNotEmpty
          ? Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  Uint8List.fromList(boutique.logo),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.store, size: 56),
                ),
              ),
            )
          : null,
      additionalInfo: [
        if (boutique.formattedPhone.isNotEmpty)
          DetailViewComponents.buildInfoRow(
            icon: Icons.phone,
            label: 'Téléphone',
            value: boutique.formattedPhone,
          ),
        if (boutique.formattedEmail.isNotEmpty)
          DetailViewComponents.buildInfoRow(
            icon: Icons.email,
            label: 'Email',
            value: boutique.formattedEmail,
          ),
        if (boutique.currencyCode.isNotEmpty)
          DetailViewComponents.buildInfoRow(
            icon: Icons.monetization_on_outlined,
            label: 'Devise',
            value: boutique.currencyCode,
          ),
        if (boutique.devices.isNotEmpty)
          DetailViewComponents.buildInfoRow(
            icon: Icons.devices,
            label: 'Appareils',
            value: '${boutique.devices.length} appareil(s)',
          ),
        DetailViewComponents.buildInfoRow(
          icon: Icons.fingerprint,
          label: 'ID',
          value: boutique.boutiqueId,
        ),
      ],
    );
  }
} 