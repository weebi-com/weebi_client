// Package imports:
import 'package:protos_weebi/protos_weebi_io.dart';

// Project imports:
import '../models/jwt_token.dart';

/// Helper class for checking user permissions
class PermissionsHelper {
  /// Check if user has specific permission based on JWT token
  static bool hasPermission(String accessToken, String permission) {
    if (accessToken.isEmpty) return false;
    
    try {
      final jwt = JsonWebToken.parse(accessToken);
      if (jwt.isTokenExpired) return false;
      
      final userPermissions = jwt.permissions;
      
      // Check boolean rights
      if (userPermissions.hasBoolRights()) {
        final boolRights = userPermissions.boolRights;
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
        return _hasResourceRight(userPermissions.articleRights.rights, permission.substring(8));
      }
      if (permission.startsWith('boutique_')) {
        return _hasResourceRight(userPermissions.boutiqueRights.rights, permission.substring(9));
      }
      if (permission.startsWith('ticket_')) {
        return _hasResourceRight(userPermissions.ticketRights.rights, permission.substring(7));
      }
      if (permission.startsWith('chain_')) {
        return _hasResourceRight(userPermissions.chainRights.rights, permission.substring(6));
      }
      if (permission.startsWith('firm_')) {
        return _hasResourceRight(userPermissions.firmRights.rights, permission.substring(5));
      }
      if (permission.startsWith('contact_')) {
        return _hasResourceRight(userPermissions.contactRights.rights, permission.substring(8));
      }
      if (permission.startsWith('userManagement_')) {
        return _hasResourceRight(userPermissions.userManagementRights.rights, permission.substring(15));
      }
      if (permission.startsWith('billing_')) {
        return _hasResourceRight(userPermissions.billingRights.rights, permission.substring(8));
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Helper method to check if user has a specific right for a resource
  static bool _hasResourceRight(List<Right> rights, String operation) {
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
} 