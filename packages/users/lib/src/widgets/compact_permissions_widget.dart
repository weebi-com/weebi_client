import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import '../l10n/permissions_ui_strings.dart';

class CompactPermissionsWidget extends StatelessWidget {
  final UserPermissions permissions;

  const CompactPermissionsWidget({
    super.key,
    required this.permissions,
  });

  @override
  Widget build(BuildContext context) {
    final rights = <String>[];

    if (permissions.articleRights.rights.isNotEmpty) {
      rights.add(PermissionsUiStrings.sectionArticles);
    }
    if (permissions.boutiqueRights.rights.isNotEmpty) {
      rights.add(PermissionsUiStrings.sectionBoutiques);
    }
    if (permissions.contactRights.rights.isNotEmpty) {
      rights.add(PermissionsUiStrings.sectionContacts);
    }
    if (permissions.ticketRights.rights.isNotEmpty) {
      rights.add(PermissionsUiStrings.sectionTickets);
    }
    if (permissions.chainRights.rights.isNotEmpty) {
      rights.add(PermissionsUiStrings.sectionChains);
    }
    if (permissions.firmRights.rights.isNotEmpty) {
      rights.add(PermissionsUiStrings.sectionFirm);
    }
    if (permissions.boolRights.canSeeStats ||
        permissions.boolRights.canExportData ||
        permissions.boolRights.canGiveDiscount ||
        permissions.boolRights.canSetPromo ||
        permissions.boolRights.canStockMovement ||
        permissions.boolRights.canStockInventory ||
        permissions.boolRights.canSpendOutOfCatalog ||
        permissions.boolRights.canPurchase ||
        permissions.boolRights.canImportTickets ||
        permissions.boolRights.canSellOutOfCatalog ||
        permissions.boolRights.canUpdateContactBalanceOffline) {
      rights.add(PermissionsUiStrings.sectionSpecialRights);
    }

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: rights
          .map((right) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                // TODO consider adapting permissions with the appropriate colors
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  right,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
    );
  }
}
