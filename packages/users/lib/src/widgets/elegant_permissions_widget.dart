import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import '../dynamic_permissions_analyzer.dart';
import '../l10n/permissions_ui_strings.dart';

/// An elegant widget for displaying and editing user permissions with inline controls
class ElegantPermissionsWidget extends StatefulWidget {
  final UserPermissions permissions;
  final bool isEditable;
  final Function(UserPermissions)? onPermissionsChanged;
  final String? title;
  final bool showHeader;

  /// Shown at the top of the « Gestion des utilisateurs » section (e.g. self profile read-only).
  final String? userManagementSectionHint;

  /// When true, only the user-management rows are non-interactive; other sections
  /// still follow [isEditable] (e.g. own profile: edit articles but not who can manage users).
  final bool userManagementReadOnly;

  const ElegantPermissionsWidget({
    super.key,
    required this.permissions,
    this.isEditable = true,
    this.onPermissionsChanged,
    this.title,
    this.showHeader = true,
    this.userManagementSectionHint,
    this.userManagementReadOnly = false,
  });

  @override
  State<ElegantPermissionsWidget> createState() =>
      _ElegantPermissionsWidgetState();
}

class _ElegantPermissionsWidgetState extends State<ElegantPermissionsWidget> {
  late UserPermissions _currentPermissions;

  @override
  void initState() {
    super.initState();
    _currentPermissions = UserPermissions.create()
      ..mergeFromMessage(widget.permissions)
      ..ensureBoolRights();
  }

  @override
  void didUpdateWidget(ElegantPermissionsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.permissions != widget.permissions) {
      _currentPermissions = UserPermissions.create()
        ..mergeFromMessage(widget.permissions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showHeader) ...[
                Row(
                  children: [
                    const Icon(Icons.admin_panel_settings, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      widget.title ??
                          PermissionsUiStrings.defaultUserPermissionsTitle,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              _buildPermissionsBody(),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionsBody() {
    return Column(
      children: [
        _buildExpandableSection(
          title: PermissionsUiStrings.sectionArticles,
          icon: Icons.widgets,
          color: Colors.orange,
          permissions: _buildArticlePermissions(),
          sectionType: 'articles',
        ),
        _buildExpandableSection(
          title: PermissionsUiStrings.sectionContacts,
          icon: Icons.contacts,
          color: Colors.blue,
          permissions: _buildContactPermissions(),
          sectionType: 'contacts',
        ),
        _buildExpandableSection(
          title: PermissionsUiStrings.sectionTickets,
          icon: Icons.receipt,
          color: Colors.grey,
          permissions: _buildTicketPermissions(),
          sectionType: 'tickets',
        ),
        _buildExpandableSection(
          title: PermissionsUiStrings.sectionSpecialRights,
          icon: Icons.star,
          color: Colors.purple,
          permissions: _buildBooleanPermissions(),
          isSpecialRights: true,
        ),
        _buildExpandableSection(
          title: PermissionsUiStrings.sectionUserManagement,
          icon: Icons.group,
          color: Colors.indigo,
          permissions: _buildUserManagementPermissions(),
          sectionType: 'userManagement',
        ),
        _buildExpandableSection(
          title: PermissionsUiStrings.sectionBoutiques,
          icon: Icons.store,
          color: Colors.blueGrey,
          permissions: _buildBoutiquePermissions(),
          sectionType: 'boutiques',
        ),
        _buildExpandableSection(
          title: PermissionsUiStrings.sectionChains,
          icon: Icons.account_tree,
          color: Colors.green,
          permissions: _buildChainPermissions(),
          sectionType: 'chains',
        ),
        _buildExpandableSection(
          title: PermissionsUiStrings.sectionFirm,
          icon: Icons.business,
          color: Colors.teal,
          permissions: _buildFirmPermissions(),
          sectionType: 'firm',
        ),
        _buildExpandableSection(
          title: PermissionsUiStrings.sectionBilling,
          icon: Icons.account_balance,
          color: Colors.amber,
          permissions: _buildBillingPermissions(),
          sectionType: 'billing',
        ),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> permissions,
    bool isSpecialRights = false,
    String? sectionType,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.only(bottom: 16),
        leading: Icon(icon, color: color, size: 20),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              fit: FlexFit.loose,
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: isSpecialRights
                      ? _buildSpecialRightsCount()
                      : _buildCrudPermissionsCountForSection(
                          sectionType, color),
                ),
              ),
            ),
          ],
        ),
        children: permissions,
      ),
    );
  }

  Widget _buildSpecialRightsCount() {
    final boolRights = DynamicPermissionsAnalyzer.getBoolRights(
        _currentPermissions.boolRights);
    final enabledCount = boolRights.values.where((enabled) => enabled).length;
    final totalCount = boolRights.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        PermissionsUiStrings.specialRightsCount(enabledCount, totalCount),
        style: TextStyle(
          color: Colors.purple[700],
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildCrudPermissionsCountForSection(
      String? sectionType, Color color) {
    List<Widget> availableIcons = [];

    bool hasCreate = false;
    bool hasRead = false;
    bool hasUpdate = false;
    bool hasDelete = false;

    // Check specific section type for available CRUD operations
    switch (sectionType) {
      case 'articles':
        hasCreate =
            _currentPermissions.articleRights.rights.contains(Right.create);
        hasRead = _currentPermissions.articleRights.rights.contains(Right.read);
        hasUpdate =
            _currentPermissions.articleRights.rights.contains(Right.update);
        hasDelete =
            _currentPermissions.articleRights.rights.contains(Right.delete);
        break;
      case 'contacts':
        hasCreate =
            _currentPermissions.contactRights.rights.contains(Right.create);
        hasRead = _currentPermissions.contactRights.rights.contains(Right.read);
        hasUpdate =
            _currentPermissions.contactRights.rights.contains(Right.update);
        hasDelete =
            _currentPermissions.contactRights.rights.contains(Right.delete);
        break;
      case 'tickets':
        hasCreate =
            _currentPermissions.ticketRights.rights.contains(Right.create);
        hasRead = _currentPermissions.ticketRights.rights.contains(Right.read);
        hasUpdate =
            _currentPermissions.ticketRights.rights.contains(Right.update);
        hasDelete =
            _currentPermissions.ticketRights.rights.contains(Right.delete);
        break;
      case 'boutiques':
        hasCreate =
            _currentPermissions.boutiqueRights.rights.contains(Right.create);
        hasRead =
            _currentPermissions.boutiqueRights.rights.contains(Right.read);
        hasUpdate =
            _currentPermissions.boutiqueRights.rights.contains(Right.update);
        hasDelete =
            _currentPermissions.boutiqueRights.rights.contains(Right.delete);
        break;
      case 'userManagement':
        hasCreate = _currentPermissions.userManagementRights.rights
            .contains(Right.create);
        hasRead = _currentPermissions.userManagementRights.rights
            .contains(Right.read);
        hasUpdate = _currentPermissions.userManagementRights.rights
            .contains(Right.update);
        hasDelete = _currentPermissions.userManagementRights.rights
            .contains(Right.delete);
        break;
      case 'chains':
        hasCreate =
            _currentPermissions.chainRights.rights.contains(Right.create);
        hasRead = _currentPermissions.chainRights.rights.contains(Right.read);
        hasUpdate =
            _currentPermissions.chainRights.rights.contains(Right.update);
        hasDelete =
            _currentPermissions.chainRights.rights.contains(Right.delete);
        break;
      case 'firm':
        hasCreate =
            _currentPermissions.firmRights.rights.contains(Right.create);
        hasRead = _currentPermissions.firmRights.rights.contains(Right.read);
        hasUpdate =
            _currentPermissions.firmRights.rights.contains(Right.update);
        hasDelete =
            _currentPermissions.firmRights.rights.contains(Right.delete);
        break;
      case 'billing':
        hasCreate =
            _currentPermissions.billingRights.rights.contains(Right.create);
        hasRead = _currentPermissions.billingRights.rights.contains(Right.read);
        hasUpdate =
            _currentPermissions.billingRights.rights.contains(Right.update);
        hasDelete =
            _currentPermissions.billingRights.rights.contains(Right.delete);
        break;
    }

    if (hasCreate) {
      availableIcons.add(Icon(Icons.add_circle,
          size: 16, color: color.withValues(alpha: 0.7)));
      if (hasRead || hasUpdate || hasDelete) {
        availableIcons.add(const SizedBox(width: 2));
      }
    }
    if (hasRead) {
      availableIcons.add(Icon(Icons.visibility,
          size: 16, color: color.withValues(alpha: 0.7)));
      if (hasUpdate || hasDelete) availableIcons.add(const SizedBox(width: 2));
    }
    if (hasUpdate) {
      availableIcons
          .add(Icon(Icons.edit, size: 16, color: color.withValues(alpha: 0.7)));
      if (hasDelete) availableIcons.add(const SizedBox(width: 2));
    }
    if (hasDelete) {
      availableIcons.add(
          Icon(Icons.delete, size: 16, color: color.withValues(alpha: 0.7)));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: availableIcons,
      ),
    );
  }

  List<Widget> _buildArticlePermissions() {
    return [
      _buildPermissionRow(
        mainIcon: Icons.widgets,
        mainColor: Colors.orange,
        permissionIcon: Icons.add_circle,
        permissionName: PermissionsUiStrings.createArticles,
        hasPermission:
            _currentPermissions.articleRights.rights.contains(Right.create),
        onChanged: (value) => _updateArticleRight(Right.create, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.widgets,
        mainColor: Colors.orange,
        permissionIcon: Icons.visibility,
        permissionName: PermissionsUiStrings.readArticles,
        hasPermission:
            _currentPermissions.articleRights.rights.contains(Right.read),
        onChanged: (value) => _updateArticleRight(Right.read, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.widgets,
        mainColor: Colors.orange,
        permissionIcon: Icons.edit,
        permissionName: PermissionsUiStrings.updateArticles,
        hasPermission:
            _currentPermissions.articleRights.rights.contains(Right.update),
        onChanged: (value) => _updateArticleRight(Right.update, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.widgets,
        mainColor: Colors.orange,
        permissionIcon: Icons.delete,
        permissionName: PermissionsUiStrings.deleteArticles,
        hasPermission:
            _currentPermissions.articleRights.rights.contains(Right.delete),
        onChanged: (value) => _updateArticleRight(Right.delete, value),
      ),
    ];
  }

  List<Widget> _buildContactPermissions() {
    return [
      _buildPermissionRow(
        mainIcon: Icons.contacts,
        mainColor: Colors.blue,
        permissionIcon: Icons.add_circle,
        permissionName: PermissionsUiStrings.createContacts,
        hasPermission:
            _currentPermissions.contactRights.rights.contains(Right.create),
        onChanged: (value) => _updateContactRight(Right.create, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.contacts,
        mainColor: Colors.blue,
        permissionIcon: Icons.visibility,
        permissionName: PermissionsUiStrings.readContacts,
        hasPermission:
            _currentPermissions.contactRights.rights.contains(Right.read),
        onChanged: (value) => _updateContactRight(Right.read, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.contacts,
        mainColor: Colors.blue,
        permissionIcon: Icons.edit,
        permissionName: PermissionsUiStrings.updateContacts,
        hasPermission:
            _currentPermissions.contactRights.rights.contains(Right.update),
        onChanged: (value) => _updateContactRight(Right.update, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.contacts,
        mainColor: Colors.blue,
        permissionIcon: Icons.delete,
        permissionName: PermissionsUiStrings.deleteContacts,
        hasPermission:
            _currentPermissions.contactRights.rights.contains(Right.delete),
        onChanged: (value) => _updateContactRight(Right.delete, value),
      ),
    ];
  }

  List<Widget> _buildTicketPermissions() {
    return [
      _buildPermissionRow(
        mainIcon: Icons.receipt,
        mainColor: Colors.grey,
        permissionIcon: Icons.add_circle,
        permissionName: PermissionsUiStrings.createTickets,
        hasPermission:
            _currentPermissions.ticketRights.rights.contains(Right.create),
        onChanged: (value) => _updateTicketRight(Right.create, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.receipt,
        mainColor: Colors.grey,
        permissionIcon: Icons.visibility,
        permissionName: PermissionsUiStrings.readTickets,
        hasPermission:
            _currentPermissions.ticketRights.rights.contains(Right.read),
        onChanged: (value) => _updateTicketRight(Right.read, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.receipt,
        mainColor: Colors.grey,
        permissionIcon: Icons.edit,
        permissionName: PermissionsUiStrings.updateTickets,
        hasPermission:
            _currentPermissions.ticketRights.rights.contains(Right.update),
        onChanged: (value) => _updateTicketRight(Right.update, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.receipt,
        mainColor: Colors.grey,
        permissionIcon: Icons.delete,
        permissionName: PermissionsUiStrings.deleteTickets,
        hasPermission:
            _currentPermissions.ticketRights.rights.contains(Right.delete),
        onChanged: (value) => _updateTicketRight(Right.delete, value),
      ),
    ];
  }

  List<Widget> _buildBoutiquePermissions() {
    return [
      _buildPermissionRow(
        mainIcon: Icons.store,
        mainColor: Colors.blueGrey,
        permissionIcon: Icons.add_circle,
        permissionName: PermissionsUiStrings.createBoutique,
        hasPermission:
            _currentPermissions.boutiqueRights.rights.contains(Right.create),
        onChanged: (value) => _updateBoutiqueRight(Right.create, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.store,
        mainColor: Colors.blueGrey,
        permissionIcon: Icons.visibility,
        permissionName: PermissionsUiStrings.readBoutique,
        hasPermission:
            _currentPermissions.boutiqueRights.rights.contains(Right.read),
        onChanged: (value) => _updateBoutiqueRight(Right.read, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.store,
        mainColor: Colors.blueGrey,
        permissionIcon: Icons.edit,
        permissionName: PermissionsUiStrings.updateBoutique,
        hasPermission:
            _currentPermissions.boutiqueRights.rights.contains(Right.update),
        onChanged: (value) => _updateBoutiqueRight(Right.update, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.store,
        mainColor: Colors.blueGrey,
        permissionIcon: Icons.delete,
        permissionName: PermissionsUiStrings.deleteBoutique,
        hasPermission:
            _currentPermissions.boutiqueRights.rights.contains(Right.delete),
        onChanged: (value) => _updateBoutiqueRight(Right.delete, value),
      ),
    ];
  }

  List<Widget> _buildChainPermissions() {
    return [
      _buildPermissionRow(
        mainIcon: Icons.account_tree,
        mainColor: Colors.green,
        permissionIcon: Icons.add_circle,
        permissionName: PermissionsUiStrings.createChain,
        hasPermission:
            _currentPermissions.chainRights.rights.contains(Right.create),
        onChanged: (value) => _updateChainRight(Right.create, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.account_tree,
        mainColor: Colors.green,
        permissionIcon: Icons.visibility,
        permissionName: PermissionsUiStrings.readChain,
        hasPermission:
            _currentPermissions.chainRights.rights.contains(Right.read),
        onChanged: (value) => _updateChainRight(Right.read, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.account_tree,
        mainColor: Colors.green,
        permissionIcon: Icons.edit,
        permissionName: PermissionsUiStrings.updateChain,
        hasPermission:
            _currentPermissions.chainRights.rights.contains(Right.update),
        onChanged: (value) => _updateChainRight(Right.update, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.account_tree,
        mainColor: Colors.green,
        permissionIcon: Icons.delete,
        permissionName: PermissionsUiStrings.deleteChain,
        hasPermission:
            _currentPermissions.chainRights.rights.contains(Right.delete),
        onChanged: (value) => _updateChainRight(Right.delete, value),
      ),
    ];
  }

  List<Widget> _buildUserManagementPermissions() {
    final hint = widget.userManagementSectionHint;
    return [
      if (hint != null && hint.isNotEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Text(
            hint,
            style: TextStyle(
              color: Colors.grey[800],
              height: 1.35,
              fontSize: 13,
            ),
          ),
        ),
      _buildPermissionRow(
        mainIcon: Icons.group,
        mainColor: Colors.indigo,
        permissionIcon: Icons.person_add,
        permissionName: PermissionsUiStrings.createUsers,
        hasPermission: _currentPermissions.userManagementRights.rights
            .contains(Right.create),
        onChanged: (value) => _updateUserManagementRight(Right.create, value),
        readOnlyOverride: widget.userManagementReadOnly,
      ),
      _buildPermissionRow(
        mainIcon: Icons.people,
        mainColor: Colors.indigo,
        permissionIcon: Icons.visibility,
        permissionName: PermissionsUiStrings.readUsers,
        hasPermission: _currentPermissions.userManagementRights.rights
            .contains(Right.read),
        onChanged: (value) => _updateUserManagementRight(Right.read, value),
        readOnlyOverride: widget.userManagementReadOnly,
      ),
      _buildPermissionRow(
        mainIcon: Icons.people,
        mainColor: Colors.indigo,
        permissionIcon: Icons.edit,
        permissionName: PermissionsUiStrings.updateUsers,
        hasPermission: _currentPermissions.userManagementRights.rights
            .contains(Right.update),
        onChanged: (value) => _updateUserManagementRight(Right.update, value),
        readOnlyOverride: widget.userManagementReadOnly,
      ),
      _buildPermissionRow(
        mainIcon: Icons.people,
        mainColor: Colors.indigo,
        permissionIcon: Icons.person_remove,
        permissionName: PermissionsUiStrings.deleteUsers,
        hasPermission: _currentPermissions.userManagementRights.rights
            .contains(Right.delete),
        onChanged: (value) => _updateUserManagementRight(Right.delete, value),
        readOnlyOverride: widget.userManagementReadOnly,
      ),
      // Exceptional admin action (boolean flag)
      _buildPermissionRow(
        mainIcon: Icons.lock_reset,
        mainColor: Colors.indigo,
        permissionIcon: Icons.check_circle,
        permissionName: PermissionsUiStrings.canUpdateUserPassword,
        hasPermission:
            _currentPermissions.userManagementRights.canUpdateUserPassword,
        onChanged: (value) =>
            _updateUserManagementBool('canUpdateUserPassword', value),
        readOnlyOverride: widget.userManagementReadOnly,
      ),
    ];
  }

  List<Widget> _buildFirmPermissions() {
    return [
      _buildPermissionRow(
        mainIcon: Icons.business,
        mainColor: Colors.teal,
        permissionIcon: Icons.add_business,
        permissionName: PermissionsUiStrings.createFirm,
        hasPermission:
            _currentPermissions.firmRights.rights.contains(Right.create),
        onChanged: (value) => _updateFirmRight(Right.create, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.business,
        mainColor: Colors.teal,
        permissionIcon: Icons.visibility,
        permissionName: PermissionsUiStrings.readFirm,
        hasPermission:
            _currentPermissions.firmRights.rights.contains(Right.read),
        onChanged: (value) => _updateFirmRight(Right.read, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.business,
        mainColor: Colors.teal,
        permissionIcon: Icons.edit,
        permissionName: PermissionsUiStrings.updateFirm,
        hasPermission:
            _currentPermissions.firmRights.rights.contains(Right.update),
        onChanged: (value) => _updateFirmRight(Right.update, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.business,
        mainColor: Colors.teal,
        permissionIcon: Icons.delete,
        permissionName: PermissionsUiStrings.deleteFirm,
        hasPermission:
            _currentPermissions.firmRights.rights.contains(Right.delete),
        onChanged: (value) => _updateFirmRight(Right.delete, value),
      ),
    ];
  }

  List<Widget> _buildBillingPermissions() {
    return [
      _buildPermissionRow(
        mainIcon: Icons.account_balance,
        mainColor: Colors.amber,
        permissionIcon: Icons.add_circle,
        permissionName: PermissionsUiStrings.createBilling,
        hasPermission:
            _currentPermissions.billingRights.rights.contains(Right.create),
        onChanged: (value) => _updateBillingRight(Right.create, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.receipt_long,
        mainColor: Colors.amber,
        permissionIcon: Icons.visibility,
        permissionName: PermissionsUiStrings.readBilling,
        hasPermission:
            _currentPermissions.billingRights.rights.contains(Right.read),
        onChanged: (value) => _updateBillingRight(Right.read, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.receipt_long,
        mainColor: Colors.amber,
        permissionIcon: Icons.edit,
        permissionName: PermissionsUiStrings.updateBilling,
        hasPermission:
            _currentPermissions.billingRights.rights.contains(Right.update),
        onChanged: (value) => _updateBillingRight(Right.update, value),
      ),
      _buildPermissionRow(
        mainIcon: Icons.receipt_long,
        mainColor: Colors.amber,
        permissionIcon: Icons.delete,
        permissionName: PermissionsUiStrings.deleteBilling,
        hasPermission:
            _currentPermissions.billingRights.rights.contains(Right.delete),
        onChanged: (value) => _updateBillingRight(Right.delete, value),
      ),
    ];
  }

  List<Widget> _buildBooleanPermissions() {
    // Dynamically discover all boolean rights fields
    final boolRights = DynamicPermissionsAnalyzer.getBoolRights(
        _currentPermissions.boolRights);

    // Build a widget for each discovered permission
    return boolRights.entries.map((entry) {
      final fieldName = entry.key;
      final hasPermission = entry.value;

      // Get icon and display name for this permission
      final permissionInfo = _getPermissionInfo(fieldName);

      return _buildPermissionRow(
        mainIcon: permissionInfo.mainIcon,
        mainColor: Colors.purple,
        permissionIcon: permissionInfo.permissionIcon,
        permissionName: permissionInfo.displayName,
        hasPermission: hasPermission,
        onChanged: (value) => _updateBoolRight(fieldName, value),
      );
    }).toList();
  }

  /// Get icon and display name for a permission field
  _PermissionInfo _getPermissionInfo(String fieldName) {
    switch (fieldName) {
      case 'canSeeStats':
        return _PermissionInfo(
          mainIcon: Icons.analytics,
          permissionIcon: Icons.visibility,
          displayName: PermissionsUiStrings.seeStatistics,
        );
      case 'canExportData':
        return _PermissionInfo(
          mainIcon: Icons.file_download,
          permissionIcon: Icons.download,
          displayName: PermissionsUiStrings.exportData,
        );
      case 'canGiveDiscount':
        return _PermissionInfo(
          mainIcon: Icons.local_offer,
          permissionIcon: Icons.percent,
          displayName: PermissionsUiStrings.giveDiscount,
        );
      case 'canSetPromo':
        return _PermissionInfo(
          mainIcon: Icons.campaign,
          permissionIcon: Icons.local_offer,
          displayName: PermissionsUiStrings.setPromotions,
        );
      case 'canStockMovement':
        return _PermissionInfo(
          mainIcon: Icons.move_up,
          permissionIcon: Icons.swap_vert,
          displayName: PermissionsUiStrings.stockMovement,
        );
      case 'canStockInventory':
        return _PermissionInfo(
          mainIcon: Icons.inventory_2,
          permissionIcon: Icons.checklist,
          displayName: PermissionsUiStrings.stockInventory,
        );
      case 'canSpendOutOfCatalog':
        return _PermissionInfo(
          mainIcon: Icons.shopping_bag,
          permissionIcon: Icons.add_shopping_cart,
          displayName: PermissionsUiStrings.spendOutOfCatalog,
        );
      case 'canPurchase':
        return _PermissionInfo(
          mainIcon: Icons.shopping_cart,
          permissionIcon: Icons.shopping_basket,
          displayName: PermissionsUiStrings.purchase,
        );
      case 'canImportTickets':
        return _PermissionInfo(
          mainIcon: Icons.upload_file,
          permissionIcon: Icons.receipt,
          displayName: PermissionsUiStrings.importTickets,
        );
      case 'canSellOutOfCatalog':
        return _PermissionInfo(
          mainIcon: Icons.point_of_sale,
          permissionIcon: Icons.sell,
          displayName: PermissionsUiStrings.sellOutOfCatalog,
        );
      case 'canUpdateContactBalanceOffline':
        return _PermissionInfo(
          mainIcon: Icons.account_balance_wallet,
          permissionIcon: Icons.offline_bolt,
          displayName: PermissionsUiStrings.updateContactBalanceOffline,
        );
      default:
        // Fallback for any new permission that doesn't have a mapping yet
        return _PermissionInfo(
          mainIcon: Icons.lock,
          permissionIcon: Icons.check_circle,
          displayName: DynamicPermissionsAnalyzer.formatFieldName(fieldName),
        );
    }
  }

  Widget _buildPermissionRow({
    required IconData mainIcon,
    required Color mainColor,
    required IconData permissionIcon,
    required String permissionName,
    required bool hasPermission,
    required Function(bool) onChanged,
    bool readOnlyOverride = false,
  }) {
    final interactive = widget.isEditable && !readOnlyOverride;
    const paddingVerticalLine = EdgeInsets.symmetric(vertical: 4.0);

    return Padding(
      padding: paddingVerticalLine,
      child: Container(
        decoration: BoxDecoration(
          color: hasPermission
              ? mainColor.withValues(alpha: 0.05)
              : Colors.grey.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasPermission
                ? mainColor.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: <Widget>[
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Icon(mainIcon, color: mainColor, size: 20),
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Icon(
                permissionIcon,
                color: hasPermission ? mainColor : Colors.grey,
                size: 18,
              ),
            ),
            const SizedBox(width: 20),
            Flexible(
              flex: 4,
              fit: FlexFit.tight,
              child: Text(
                permissionName,
                style: TextStyle(
                  fontWeight:
                      hasPermission ? FontWeight.w600 : FontWeight.normal,
                  color: hasPermission ? Colors.black87 : Colors.grey[600],
                ),
              ),
            ),
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: interactive
                  ? Switch(
                      value: hasPermission,
                      onChanged: onChanged,
                      activeColor: mainColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )
                  : Checkbox(
                      value: hasPermission,
                      onChanged: null,
                      activeColor: mainColor,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateArticleRight(Right right, bool value) {
    setState(() {
      final newRights = value
          ? [..._currentPermissions.articleRights.rights, right]
          : _currentPermissions.articleRights.rights
              .where((r) => r != right)
              .toList();
      _currentPermissions.articleRights = ArticleRights(rights: newRights);
    });
    _notifyPermissionsChanged();
  }

  void _updateContactRight(Right right, bool value) {
    setState(() {
      final newRights = value
          ? [..._currentPermissions.contactRights.rights, right]
          : _currentPermissions.contactRights.rights
              .where((r) => r != right)
              .toList();
      _currentPermissions.contactRights = ContactRights(rights: newRights);
    });
    _notifyPermissionsChanged();
  }

  void _updateTicketRight(Right right, bool value) {
    setState(() {
      final newRights = value
          ? [..._currentPermissions.ticketRights.rights, right]
          : _currentPermissions.ticketRights.rights
              .where((r) => r != right)
              .toList();
      _currentPermissions.ticketRights = TicketRights(rights: newRights);
    });
    _notifyPermissionsChanged();
  }

  void _updateBoutiqueRight(Right right, bool value) {
    setState(() {
      final newRights = value
          ? [..._currentPermissions.boutiqueRights.rights, right]
          : _currentPermissions.boutiqueRights.rights
              .where((r) => r != right)
              .toList();
      _currentPermissions.boutiqueRights = BoutiqueRights(rights: newRights);
    });
    _notifyPermissionsChanged();
  }

  void _updateChainRight(Right right, bool value) {
    setState(() {
      final newRights = value
          ? [..._currentPermissions.chainRights.rights, right]
          : _currentPermissions.chainRights.rights
              .where((r) => r != right)
              .toList();
      _currentPermissions.chainRights = ChainRights(rights: newRights);
    });
    _notifyPermissionsChanged();
  }

  void _updateUserManagementRight(Right right, bool value) {
    setState(() {
      final um = _currentPermissions.ensureUserManagementRights();
      if (value) {
        if (!um.rights.contains(right)) {
          um.rights.add(right);
        }
      } else {
        um.rights.removeWhere((r) => r == right);
      }
    });
    _notifyPermissionsChanged();
  }

  void _updateUserManagementBool(String fieldName, bool value) {
    if (fieldName != 'canUpdateUserPassword') return;
    setState(() {
      _currentPermissions.ensureUserManagementRights().canUpdateUserPassword =
          value;
    });
    _notifyPermissionsChanged();
  }

  void _updateFirmRight(Right right, bool value) {
    setState(() {
      final newRights = value
          ? [..._currentPermissions.firmRights.rights, right]
          : _currentPermissions.firmRights.rights
              .where((r) => r != right)
              .toList();
      _currentPermissions.firmRights = FirmRights(rights: newRights);
    });
    _notifyPermissionsChanged();
  }

  void _updateBillingRight(Right right, bool value) {
    setState(() {
      final newRights = value
          ? [..._currentPermissions.billingRights.rights, right]
          : _currentPermissions.billingRights.rights
              .where((r) => r != right)
              .toList();
      _currentPermissions.billingRights = BillingRights(rights: newRights);
    });
    _notifyPermissionsChanged();
  }

  void _updateBoolRight(String rightName, bool value) {
    setState(() {
      // Dynamically set the field value based on the field name
      switch (rightName) {
        case 'canSeeStats':
          _currentPermissions.ensureBoolRights().canSeeStats = value;
          break;
        case 'canExportData':
          _currentPermissions.ensureBoolRights().canExportData = value;
          break;
        case 'canGiveDiscount':
          _currentPermissions.ensureBoolRights().canGiveDiscount = value;
          break;
        case 'canSetPromo':
          _currentPermissions.ensureBoolRights().canSetPromo = value;
          break;
        case 'canStockMovement':
          _currentPermissions.ensureBoolRights().canStockMovement = value;
          break;
        case 'canStockInventory':
          _currentPermissions.ensureBoolRights().canStockInventory = value;
          break;
        case 'canSpendOutOfCatalog':
          _currentPermissions.ensureBoolRights().canSpendOutOfCatalog = value;
          break;
        case 'canPurchase':
          _currentPermissions.ensureBoolRights().canPurchase = value;
          break;
        case 'canImportTickets':
          _currentPermissions.ensureBoolRights().canImportTickets = value;
          break;
        case 'canSellOutOfCatalog':
          _currentPermissions.ensureBoolRights().canSellOutOfCatalog = value;
          break;
        case 'canUpdateContactBalanceOffline':
          _currentPermissions
              .ensureBoolRights()
              .canUpdateContactBalanceOffline = value;
          break;
      }
    });
    _notifyPermissionsChanged();
  }

  void _notifyPermissionsChanged() {
    widget.onPermissionsChanged?.call(_currentPermissions);
  }
}

/// Enhanced editable version of the PermissionWidget from the auth package
class EditablePermissionWidget extends StatelessWidget {
  final Icon icon;
  final Icon permissionIcon;
  final Text permissionName;
  final bool hasPermission;
  final Function(bool)? onChanged;
  final bool isEditable;

  const EditablePermissionWidget({
    super.key,
    required this.icon,
    required this.permissionIcon,
    required this.permissionName,
    required this.hasPermission,
    this.onChanged,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    const paddingVerticalLine = EdgeInsets.symmetric(vertical: 4.0);

    return Padding(
      padding: paddingVerticalLine,
      child: Container(
        decoration: BoxDecoration(
          color: hasPermission
              ? Colors.green.withValues(alpha: 0.05)
              : Colors.grey.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasPermission
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: <Widget>[
            Flexible(flex: 1, fit: FlexFit.tight, child: icon),
            Flexible(flex: 1, fit: FlexFit.tight, child: permissionIcon),
            const SizedBox(width: 20),
            Flexible(flex: 4, fit: FlexFit.tight, child: permissionName),
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: isEditable && onChanged != null
                  ? Switch(
                      value: hasPermission,
                      onChanged: onChanged,
                      activeColor: Colors.green,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )
                  : Checkbox(
                      value: hasPermission,
                      onChanged: null,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class to store permission display information
class _PermissionInfo {
  final IconData mainIcon;
  final IconData permissionIcon;
  final String displayName;

  _PermissionInfo({
    required this.mainIcon,
    required this.permissionIcon,
    required this.displayName,
  });
}
