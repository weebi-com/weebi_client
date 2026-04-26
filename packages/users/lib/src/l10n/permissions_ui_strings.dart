/// French labels for permission sections and rows (`elegant_permissions_widget`, chips).
///
/// Proto `Firm` → libellés **entreprise** en UI (jamais « firme », trop anglicisant / juridique à froid).
abstract final class PermissionsUiStrings {
  static const String defaultUserPermissionsTitle = 'Droits utilisateur';

  static String specialRightsCount(int enabled, int total) =>
      '$enabled sur $total';

  // Sections
  static const String sectionArticles = 'Articles';
  static const String sectionContacts = 'Contacts';
  static const String sectionTickets = 'Tickets';
  static const String sectionSpecialRights = 'Droits spéciaux';
  static const String sectionUserManagement = 'Gestion des utilisateurs';
  static const String sectionBoutiques = 'Boutiques';
  static const String sectionChains = 'Chaînes de magasins';
  static const String sectionFirm = 'Entreprise';
  static const String sectionBilling = 'Licenses';

  // Articles CRUD
  static const String createArticles = 'Créer des articles';
  static const String readArticles = 'Consulter les articles';
  static const String updateArticles = 'Modifier les articles';
  static const String deleteArticles = 'Supprimer des articles';

  // Contacts CRUD
  static const String createContacts = 'Créer des contacts';
  static const String readContacts = 'Consulter les contacts';
  static const String updateContacts = 'Modifier les contacts';
  static const String deleteContacts = 'Supprimer des contacts';

  // Tickets CRUD
  static const String createTickets = 'Créer des tickets';
  static const String readTickets = 'Consulter les tickets';
  static const String updateTickets = 'Modifier les tickets';
  static const String deleteTickets = 'Supprimer des tickets';

  // Boutiques CRUD
  static const String createBoutique = 'Créer une boutique';
  static const String readBoutique = 'Consulter les boutiques';
  static const String updateBoutique = 'Modifier les boutiques';
  static const String deleteBoutique = 'Supprimer des boutiques';

  // Chaînes de magasins (proto `Chain`)
  static const String createChain = 'Créer une chaîne de magasins';
  static const String readChain = 'Consulter les chaînes de magasins';
  static const String updateChain = 'Modifier les chaînes de magasins';
  static const String deleteChain = 'Supprimer des chaînes de magasins';

  // User management
  static const String createUsers = 'Créer des utilisateurs';
  static const String readUsers = 'Consulter les utilisateurs';
  static const String updateUsers = 'Modifier les utilisateurs';
  static const String deleteUsers = 'Supprimer des utilisateurs';
  static const String canUpdateUserPassword =
      'Modifier le mot de passe des utilisateurs';

  // Firm CRUD
  static const String createFirm = 'Créer une entreprise';
  static const String readFirm = 'Consulter l’entreprise';
  static const String updateFirm = 'Modifier l’entreprise';
  static const String deleteFirm = 'Supprimer l’entreprise';

  // Billing CRUD
  static const String createBilling = 'Acheter une license';
  static const String readBilling = 'Consulter les licenses';
  static const String updateBilling = "Modifier l'attribution d'une license";
  static const String deleteBilling = 'Supprimer une license';

  // Boolean / special rights
  static const String seeStatistics = 'Voir les statistiques';
  static const String exportData = 'Exporter les données';
  static const String giveDiscount = 'Accorder des remises';
  static const String setPromotions = 'Gérer les promotions';
  static const String stockMovement = 'Saisir des entrées/sorties de stock';
  static const String stockInventory = 'Saisir un inventaire';
  static const String spendOutOfCatalog = 'Saisir une dépense hors catalogue';
  static const String purchase = 'Saisir des achats';
  static const String importTickets = 'Importer des tickets';
  static const String sellOutOfCatalog = 'Saisir une vente hors catalogue';
  static const String updateContactBalanceOffline =
      'Mettre à jour le solde contact hors ligne';
}
