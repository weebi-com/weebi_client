// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:protos_weebi/protos_weebi_io.dart';

// Project imports:
import 'access_token_provider.dart';
import '../extensions/user_permissions_extensions.dart';
import '../utils/permissions_helper.dart';

/// Provider for managing user permissions from JWT token
/// Single source of truth for permissions - reads from AccessTokenProvider
/// 
/// Works offline-first: permissions are cached in the token and don't require
/// connectivity checks. The server validates on sync if needed.
/// 
/// Provides default permissions when no token exists (offline + no previous login)
class PermissionProvider extends ChangeNotifier {
  final AccessTokenProvider _accessTokenProvider;
  final UserPermissions _defaultPermissions;
  UserPermissions? _bffPermissions;

  PermissionProvider(
    this._accessTokenProvider, {
    UserPermissions? defaultPermissions,
  }) : _defaultPermissions = defaultPermissions ?? UserPermissions.create() {
    // Listen to token changes to update permissions
    _accessTokenProvider.addListener(_onTokenChanged);
  }

  void _onTokenChanged() {
    notifyListeners();
  }

  /// Update permissions for BFF mode (where permissions come from server session)
  void updateBffPermissions(UserPermissions permissions) {
    _bffPermissions = permissions;
    notifyListeners();
  }

  @override
  void dispose() {
    _accessTokenProvider.removeListener(_onTokenChanged);
    super.dispose();
  }

  /// Get user permissions from token or BFF override
  /// Falls back to default permissions when no token exists
  UserPermissions get userPermissions => 
      _bffPermissions ?? (hasToken ? _accessTokenProvider.permissions : _defaultPermissions);

  /// Check if user has any token at all
  bool get hasToken => _accessTokenProvider.accessToken.isNotEmpty;

  /// Check if user is considered authenticated (either via JWT token or BFF session)
  bool get isAuthenticated => hasToken || _bffPermissions != null;

  /// Context properties from token
  String get firmId => userPermissions.firmId;
  String get userId => userPermissions.userId;

  // === Generic Permission Check ===
  
  /// Check if user has a specific permission
  /// Example: hasPermission('article_create')
  bool hasPermission(String permission) {
    if (!isAuthenticated) return false;
    
    final permissions = userPermissions;
    
    // Check boolean rights
    if (permissions.hasBoolRights()) {
      final boolRights = permissions.boolRights;
      switch (permission) {
        case 'canSeeStats':
          return boolRights.canSeeStats;
        case 'canExportData':
          return boolRights.canExportData;
        case 'canGiveDiscount':
          return boolRights.canGiveDiscount;
        case 'canSetPromo':
          return boolRights.canSetPromo;
        case 'canStockMovement':
          return boolRights.canStockMovement;
        case 'canStockInventory':
          return boolRights.canStockInventory;
        case 'canSpendOutOfCatalog':
          return boolRights.canSpendOutOfCatalog;
        case 'canPurchase':
          return boolRights.canPurchase;
        case 'canImportTickets':
          return boolRights.canImportTickets;
        case 'canSellOutOfCatalog':
          return boolRights.canSellOutOfCatalog;
        case 'canUpdateContactBalanceOffline':
          return boolRights.canUpdateContactBalanceOffline;
      }
    }

    // Check CRUD rights for different resources
    if (permission.startsWith('article_')) {
      return _hasResourceRight(permissions.articleRights.rights, permission.substring(8));
    }
    if (permission.startsWith('boutique_')) {
      return _hasResourceRight(permissions.boutiqueRights.rights, permission.substring(9));
    }
    if (permission.startsWith('ticket_')) {
      return _hasResourceRight(permissions.ticketRights.rights, permission.substring(7));
    }
    if (permission.startsWith('chain_')) {
      return _hasResourceRight(permissions.chainRights.rights, permission.substring(6));
    }
    if (permission.startsWith('firm_')) {
      return _hasResourceRight(permissions.firmRights.rights, permission.substring(5));
    }
    if (permission.startsWith('contact_')) {
      return _hasResourceRight(permissions.contactRights.rights, permission.substring(8));
    }
    if (permission.startsWith('userManagement_')) {
      return _hasResourceRight(permissions.userManagementRights.rights, permission.substring(15));
    }
    if (permission.startsWith('billing_')) {
      return _hasResourceRight(permissions.billingRights.rights, permission.substring(8));
    }

    return false;
  }

  /// Helper method to check if user has a specific right for a resource
  bool _hasResourceRight(List<Right> rights, String operation) {
    switch (operation) {
      case 'create':
        return rights.contains(Right.create);
      case 'read':
        return rights.contains(Right.read);
      case 'update':
        return rights.contains(Right.update);
      case 'delete':
        return rights.contains(Right.delete);
      default:
        return false;
    }
  }

  // === Article Rights (using extension) ===
  bool get canCreateArticle =>  userPermissions.canCreateArticle;
  bool get canReadArticle =>  userPermissions.canReadArticle;
  bool get canUpdateArticle =>  userPermissions.canUpdateArticle;
  bool get canDeleteArticle =>  userPermissions.canDeleteArticle;

  // === Boutique Rights ===
  bool get canCreateBoutique =>  userPermissions.canCreateBoutique;
  bool get canReadBoutique =>  userPermissions.canReadBoutique;
  bool get canUpdateBoutique =>  userPermissions.canUpdateBoutique;
  bool get canDeleteBoutique =>  userPermissions.canDeleteBoutique;

  // === Contact Rights ===
  bool get canCreateContact =>  userPermissions.canCreateContact;
  bool get canReadContact =>  userPermissions.canReadContact;
  bool get canUpdateContact =>  userPermissions.canUpdateContact;
  bool get canDeleteContact =>  userPermissions.canDeleteContact;

  // === Ticket Rights ===
  bool get canCreateTicket =>  userPermissions.canCreateTicket;
  bool get canReadTicket =>  userPermissions.canReadTicket;
  bool get canUpdateTicket =>  userPermissions.canUpdateTicket;
  bool get canDeleteTicket =>  userPermissions.canDeleteTicket;

  // === Chain Rights ===
  bool get canCreateChain =>  userPermissions.canCreateChain;
  bool get canReadChain =>  userPermissions.canReadChain;
  bool get canUpdateChain =>  userPermissions.canUpdateChain;
  bool get canDeleteChain =>  userPermissions.canDeleteChain;

  // === Firm Rights ===
  bool get canCreateFirm =>  userPermissions.canCreateFirm;
  bool get canReadFirm =>  userPermissions.canReadFirm;
  bool get canUpdateFirm =>  userPermissions.canUpdateFirm;
  bool get canDeleteFirm =>  userPermissions.canDeleteFirm;

  // === User Management Rights ===
  bool get canCreateUserManagement =>  userPermissions.canCreateUserManagement;
  bool get canReadUserManagement =>  userPermissions.canReadUserManagement;
  bool get canUpdateUserManagement =>  userPermissions.canUpdateUserManagement;
  bool get canDeleteUserManagement =>  userPermissions.canDeleteUserManagement;
  bool get canUpdateUserPassword =>  userPermissions.canUpdateUserPassword;

  // === Billing Rights ===
  bool get canCreateBilling =>  userPermissions.canCreateBilling;
  bool get canReadBilling =>  userPermissions.canReadBilling;
  bool get canUpdateBilling =>  userPermissions.canUpdateBilling;
  bool get canDeleteBilling =>  userPermissions.canDeleteBilling;

  // === Boolean Rights ===
  bool get canSeeStats =>  userPermissions.canSeeStats;
  bool get canExportData =>  userPermissions.canExportData;
  bool get canGiveDiscount =>  userPermissions.canGiveDiscount;
  bool get canSetPromo =>  userPermissions.canSetPromo;
  bool get canStockMovement =>  userPermissions.canStockMovement;
  bool get canStockInventory =>  userPermissions.canStockInventory;
  bool get canSpendOutOfCatalog =>  userPermissions.canSpendOutOfCatalog;
  bool get canPurchase =>  userPermissions.canPurchase;
  bool get canImportTickets =>  userPermissions.canImportTickets;
  bool get canSellOutOfCatalog =>  userPermissions.canSellOutOfCatalog;
  bool get canUpdateContactBalanceOffline =>  userPermissions.canUpdateContactBalanceOffline;

  // === Helper Methods ===

  /// Check if user has any admin rights
  bool get hasAdminRights =>
      canDeleteFirm || canCreateBoutique || canDeleteBoutique || canExportData;

  /// Check if user has any create rights
  bool get hasCreateRights =>
      canCreateArticle ||
      canCreateBoutique ||
      canCreateContact ||
      canCreateTicket;

  /// Get a summary of user's main permissions (for debugging)
  Map<String, bool> get permissionSummary {
    return {
      'Articles': canReadArticle,
      'Contacts': canReadContact,
      'Tickets': canReadTicket,
      'Stats': canSeeStats,
      'Discounts': canGiveDiscount,
      'Export': canExportData,
    };
  }
}
