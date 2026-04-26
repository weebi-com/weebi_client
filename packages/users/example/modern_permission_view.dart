import 'package:flutter/material.dart';
import 'package:users_weebi/src/dynamic_permissions_analyzer.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

class PermissionView extends StatelessWidget {
  final UserPermissions  userPermissions;
  const PermissionView(this.userPermissions, {super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    return Scaffold(
      drawer: DrawerWeebi(),
      appBar: AppBar(
          title: Text(context.l10n.permissionsUpper),
          backgroundColor: Colors.grey[700]),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // User/Device Info Section
            // _buildUserInfoSection(context, cloudHub),
            
            const Divider(),
            const SizedBox(height: 12),
            
            // Articles Permissions
            _buildPermissionSection(
              context: context,
              title: context.l10n.articlesUpper,
              icon: Icons.widgets,
              color: ColorsWeebi.orangeArticle,
              rights: userPermissions.articleRights,
            ),
            
            const SizedBox(height: 12),
            
            // Contacts Permissions
            _buildPermissionSection(
              context: context,
              title: context.l10n.contactsUpper,
              icon: Icons.contacts,
              color: ColorsWeebi.blueContact,
              rights: userPermissions.contactRights,
            ),
            
            const SizedBox(height: 12),
            
            // Tickets Permissions
            _buildPermissionSection(
              context: context,
              title: context.l10n.ticketsUpper,
              icon: Icons.receipt,
              color: ColorsWeebi.greyTicket,
              rights: userPermissions.ticketRights,
            ),
            
            const SizedBox(height: 12),
            
            // Boutique Permissions
            _buildPermissionSection(
              context: context,
              title: context.l10n.magasinUpper,
              icon: Icons.store,
              color: Colors.blueGrey,
              rights: userPermissions.boutiqueRights,
            ),
            
            const SizedBox(height: 12),
            
            // Boolean/Special Permissions (Dynamic Discovery!)
            _buildBooleanPermissionsSection(context, userPermissions.boolRights),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }


  Widget _buildPermissionSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required dynamic rights, // ArticleRights, ContactRights, etc.
  }) {
    // If rights is null or empty, don't show the section
    if (rights == null) return const SizedBox.shrink();
    
    // Extract the rights list
    List<Right> rightsList = [];
    if (rights is ArticleRights) {
      rightsList = rights.rights;
    } else if (rights is ContactRights) {
      rightsList = rights.rights;
    } else if (rights is TicketRights) {
      rightsList = rights.rights;
    } else if (rights is BoutiqueRights) {
      rightsList = rights.rights;
    } else if (rights is ChainRights) {
      rightsList = rights.rights;
    } else if (rights is FirmRights) {
      rightsList = rights.rights;
    } else if (rights is UserManagementRights) {
      rightsList = rights.rights;
    } else if (rights is BillingRights) {
      rightsList = rights.rights;
    }

    return Column(
      children: [
        Text(title, style: TextStyleWeebi.blackBoldBig),
        const SizedBox(height: 2),
        // Build permission widgets for each right type
        if (rightsList.contains(Right.create))
          PermissionWidget(
            icon: Icon(icon, color: color),
            permissionName: Text(_getRightLabel(context, Right.create)),
            permissionIcon: const Icon(Icons.add_circle),
            hasPermission: true,
          ),
        if (rightsList.contains(Right.read))
          PermissionWidget(
            icon: Icon(icon, color: color),
            permissionName: Text(_getRightLabel(context, Right.read)),
            permissionIcon: const Icon(Icons.remove_red_eye),
            hasPermission: true,
          ),
        if (rightsList.contains(Right.update))
          PermissionWidget(
            icon: Icon(icon, color: color),
            permissionName: Text(_getRightLabel(context, Right.update)),
            permissionIcon: const Icon(Icons.edit),
            hasPermission: true,
          ),
        if (rightsList.contains(Right.delete))
          PermissionWidget(
            icon: Icon(icon, color: color),
            permissionName: Text(_getRightLabel(context, Right.delete)),
            permissionIcon: const Icon(Icons.delete),
            hasPermission: true,
          ),
      ],
    );
  }

  /// Dynamically build boolean/special permissions using reflection
  Widget _buildBooleanPermissionsSection(BuildContext context, BoolRights boolRights) {
    // Dynamically discover all boolean rights fields
    final discoveredRights = DynamicPermissionsAnalyzer.getBoolRights(boolRights);
    
    // Filter only the permissions that are granted (true)
    final grantedRights = discoveredRights.entries
        .where((entry) => entry.value == true)
        .toList();
    
    // If no special permissions, don't show the section
    if (grantedRights.isEmpty) return const SizedBox.shrink();
    
    return Column(
      children: [
        Text(context.l10n.specialPermissions ?? 'Permissions spéciales', 
            style: TextStyleWeebi.blackBoldBig),
        const SizedBox(height: 2),
        // Build a widget for each granted permission
        ...grantedRights.map((entry) {
          final fieldName = entry.key;
          final permissionInfo = _getBooleanPermissionInfo(context, fieldName);
          
          return PermissionWidget(
            icon: Icon(permissionInfo.icon, color: Colors.purple),
            permissionName: Text(permissionInfo.displayName),
            permissionIcon: Icon(permissionInfo.permissionIcon),
            hasPermission: true,
          );
        }),
      ],
    );
  }

  /// Get localized label for standard rights (Create, Read, Update, Delete)
  String _getRightLabel(BuildContext context, Right right) {
    switch (right) {
      case Right.create:
        return  'Créer';
      case Right.read:
        return  'Lire';
      case Right.update:
        return  'Modifier';
      case Right.delete:
        return  'Supprimer';
      default:
        return right.name;
    }
  }

  /// Get icon and display name for boolean permissions
  _BooleanPermissionInfo _getBooleanPermissionInfo(BuildContext context, String fieldName) {
    switch (fieldName) {
      case 'canSeeStats':
        return _BooleanPermissionInfo(
          icon: Icons.analytics,
          permissionIcon: Icons.visibility,
          displayName: context.l10n.seeStatistics ?? 'Voir les statistiques',
        );
      case 'canExportData':
        return _BooleanPermissionInfo(
          icon: Icons.file_download,
          permissionIcon: Icons.download,
          displayName: context.l10n.exportData ?? 'Exporter les données',
        );
      case 'canGiveDiscount':
        return _BooleanPermissionInfo(
          icon: Icons.local_offer,
          permissionIcon: Icons.percent,
          displayName: context.l10n.giveDiscount ?? 'Accorder une remise',
        );
      case 'canSetPromo':
        return _BooleanPermissionInfo(
          icon: Icons.campaign,
          permissionIcon: Icons.local_offer,
          displayName: context.l10n.setPromo ?? 'Définir des promotions',
        );
      case 'canStockMovement':
        return _BooleanPermissionInfo(
          icon: Icons.move_up,
          permissionIcon: Icons.swap_vert,
          displayName: context.l10n.stockMovement ?? 'Mouvement de stock',
        );
      case 'canStockInventory':
        return _BooleanPermissionInfo(
          icon: Icons.inventory_2,
          permissionIcon: Icons.checklist,
          displayName: context.l10n.stockInventory ?? 'Inventaire de stock',
        );
      case 'canSpendOutOfCatalog':
        return _BooleanPermissionInfo(
          icon: Icons.shopping_bag,
          permissionIcon: Icons.add_shopping_cart,
          displayName: context.l10n.spendOutOfCatalog ?? 'Dépenser hors catalogue',
        );
      case 'canPurchase':
        return _BooleanPermissionInfo(
          icon: Icons.shopping_cart,
          permissionIcon: Icons.shopping_basket,
          displayName: context.l10n.purchase ?? 'Acheter',
        );
      case 'canImportTickets':
        return _BooleanPermissionInfo(
          icon: Icons.upload_file,
          permissionIcon: Icons.receipt_long,
          displayName: context.l10n.importTickets ?? 'Importer des tickets',
        );
      case 'canSellOutOfCatalog':
        return _BooleanPermissionInfo(
          icon: Icons.point_of_sale,
          permissionIcon: Icons.sell,
          displayName: context.l10n.sellOutOfCatalog ?? 'Vendre hors catalogue',
        );
      case 'canUpdateContactBalanceOffline':
        return _BooleanPermissionInfo(
          icon: Icons.account_balance_wallet,
          permissionIcon: Icons.offline_bolt,
          displayName: context.l10n.updateContactBalanceOffline ?? 
                      'Mettre à jour le solde du contact hors ligne',
        );
      default:
        // Fallback for any new permission that doesn't have a mapping yet
        return _BooleanPermissionInfo(
          icon: Icons.lock,
          permissionIcon: Icons.check_circle,
          displayName: DynamicPermissionsAnalyzer.formatFieldName(fieldName),
        );
    }
  }
}

/// Helper class to store boolean permission display information
class _BooleanPermissionInfo {
  final IconData icon;
  final IconData permissionIcon;
  final String displayName;

  _BooleanPermissionInfo({
    required this.icon,
    required this.permissionIcon,
    required this.displayName,
  });
}

// Placeholder widgets/classes that would exist in your app
class CloudHub {
  final String firmName = '';
  final String firmId = '';
  final String username = '';
  final String userId = '';
  final String deviceId = '';
  final UserPermissions permissions = UserPermissions();
  
  // Legacy getters for backward compatibility
  bool get canCreateArticle => permissions.articleRights.rights.contains(Right.create);
  bool get canReadArticle => permissions.articleRights.rights.contains(Right.read);
  bool get canUpdateArticle => permissions.articleRights.rights.contains(Right.update);
  bool get canDeleteArticle => permissions.articleRights.rights.contains(Right.delete);
  
  bool get canCreateContact => permissions.contactRights.rights.contains(Right.create);
  bool get canReadContact => permissions.contactRights.rights.contains(Right.read);
  bool get canUpdateContact => permissions.contactRights.rights.contains(Right.update);
  bool get canDeleteContact => permissions.contactRights.rights.contains(Right.delete);
  
  bool get canCreateTicket => permissions.ticketRights.rights.contains(Right.create);
  bool get canReadTicket => permissions.ticketRights.rights.contains(Right.read);
  bool get canUpdateTicket => permissions.ticketRights.rights.contains(Right.update);
  bool get canDeleteTicket => permissions.ticketRights.rights.contains(Right.delete);
  
  bool get canUpdateBoutique => permissions.boutiqueRights.rights.contains(Right.update);
}

class DrawerWeebi extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Drawer();
}

class FieldValueWidget extends StatelessWidget {
  final IconData icon;
  final Widget label;
  final Widget value;
  
  const FieldValueWidget(this.icon, this.label, this.value, {super.key});
  
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: label,
    subtitle: value,
  );
}

class PermissionWidget extends StatelessWidget {
  final Icon icon;
  final Widget permissionName;
  final Icon permissionIcon;
  final bool hasPermission;
  
  const PermissionWidget({
    super.key,
    required this.icon,
    required this.permissionName,
    required this.permissionIcon,
    required this.hasPermission,
  });
  
  @override
  Widget build(BuildContext context) => ListTile(
    leading: icon,
    title: permissionName,
    trailing: hasPermission ? permissionIcon : const Icon(Icons.close, color: Colors.red),
  );
}

class IconsWeebi {
  static const firm = Icons.business;
  static const user = Icons.person;
  static const deviceIcon = Icons.devices;
}

class ColorsWeebi {
  static const orangeArticle = Colors.orange;
  static const blueContact = Colors.blue;
  static const greyTicket = Colors.grey;
}

class TextStyleWeebi {
  static const blackBoldBig = TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
}

extension LocalizationExtension on BuildContext {
  _AppLocalizations get l10n => _AppLocalizations();
}

class _AppLocalizations {
  String get permissionsUpper => 'PERMISSIONS';
  String get articlesUpper => 'ARTICLES';
  String get contactsUpper => 'CONTACTS';
  String get ticketsUpper => 'TICKETS';
  String get magasinUpper => 'MAGASIN';
  String get creerUnArticle => 'Créer un article';
  String get readUpper => 'LIRE';
  String get update => 'Modifier';
  String get supprimerLArticle => 'Supprimer l\'article';
  String get creerUnContact => 'Créer un contact';
  String get supprimerLeContact => 'Supprimer le contact';
  String get add => 'Ajouter';
  String get desactiverLeTicket => 'Désactiver le ticket';
  String get effacerLeTicket => 'Effacer le ticket';
  String? get specialPermissions => 'Permissions spéciales';
  String? get seeStatistics => null;
  String? get exportData => null;
  String? get giveDiscount => null;
  String? get setPromo => null;
  String? get stockMovement => null;
  String? get stockInventory => null;
  String? get spendOutOfCatalog => null;
  String? get purchase => null;
  String? get importTickets => null;
  String? get sellOutOfCatalog => null;
  String? get updateContactBalanceOffline => null;
  String? get delete => null;
}



