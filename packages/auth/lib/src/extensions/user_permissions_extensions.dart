// Package imports:
import 'package:protos_weebi/protos_weebi_io.dart';

/// Convenience extension to query CRUD and boolean permissions
extension UserPermissionsX on UserPermissions {
  // Articles
  bool get canCreateArticle => articleRights.rights.contains(Right.create);
  bool get canReadArticle => articleRights.rights.contains(Right.read);
  bool get canUpdateArticle => articleRights.rights.contains(Right.update);
  bool get canDeleteArticle => articleRights.rights.contains(Right.delete);

  // Boutiques
  bool get canCreateBoutique => boutiqueRights.rights.contains(Right.create);
  bool get canReadBoutique => boutiqueRights.rights.contains(Right.read);
  bool get canUpdateBoutique => boutiqueRights.rights.contains(Right.update);
  bool get canDeleteBoutique => boutiqueRights.rights.contains(Right.delete);

  // Contacts
  bool get canCreateContact => contactRights.rights.contains(Right.create);
  bool get canReadContact => contactRights.rights.contains(Right.read);
  bool get canUpdateContact => contactRights.rights.contains(Right.update);
  bool get canDeleteContact => contactRights.rights.contains(Right.delete);

  // Tickets
  bool get canCreateTicket => ticketRights.rights.contains(Right.create);
  bool get canReadTicket => ticketRights.rights.contains(Right.read);
  bool get canUpdateTicket => ticketRights.rights.contains(Right.update);
  bool get canDeleteTicket => ticketRights.rights.contains(Right.delete);

  // Chains
  bool get canCreateChain => chainRights.rights.contains(Right.create);
  bool get canReadChain => chainRights.rights.contains(Right.read);
  bool get canUpdateChain => chainRights.rights.contains(Right.update);
  bool get canDeleteChain => chainRights.rights.contains(Right.delete);

  // Firm
  bool get canCreateFirm => firmRights.rights.contains(Right.create);
  bool get canReadFirm => firmRights.rights.contains(Right.read);
  bool get canUpdateFirm => firmRights.rights.contains(Right.update);
  bool get canDeleteFirm => firmRights.rights.contains(Right.delete);

  // User management
  bool get canCreateUserManagement => userManagementRights.rights.contains(Right.create);
  bool get canReadUserManagement => userManagementRights.rights.contains(Right.read);
  bool get canUpdateUserManagement => userManagementRights.rights.contains(Right.update);
  bool get canDeleteUserManagement => userManagementRights.rights.contains(Right.delete);
  bool get canUpdateUserPassword => userManagementRights.canUpdateUserPassword;

  // Billing
  bool get canCreateBilling => billingRights.rights.contains(Right.create);
  bool get canReadBilling => billingRights.rights.contains(Right.read);
  bool get canUpdateBilling => billingRights.rights.contains(Right.update);
  bool get canDeleteBilling => billingRights.rights.contains(Right.delete);

  // Special boolean rights (if present)
  bool get canSeeStats => hasBoolRights() ? boolRights.canSeeStats : false;
  bool get canExportData => hasBoolRights() ? boolRights.canExportData : false;
  bool get canGiveDiscount => hasBoolRights() ? boolRights.canGiveDiscount : false;
  bool get canSetPromo => hasBoolRights() ? boolRights.canSetPromo : false;
  bool get canStockMovement => hasBoolRights() ? boolRights.canStockMovement : false;
  bool get canStockInventory => hasBoolRights() ? boolRights.canStockInventory : false;
  bool get canSpendOutOfCatalog => hasBoolRights() ? boolRights.canSpendOutOfCatalog : false;
  bool get canPurchase => hasBoolRights() ? boolRights.canPurchase : false;
  bool get canImportTickets => hasBoolRights() ? boolRights.canImportTickets : false;
  bool get canSellOutOfCatalog => hasBoolRights() ? boolRights.canSellOutOfCatalog : false;
  bool get canUpdateContactBalanceOffline => hasBoolRights() ? boolRights.canUpdateContactBalanceOffline : false;
}


