/// French UI strings for `accesses_weebi` (default locale).
abstract final class AccessUiStrings {
  static const String accessManagementTitle = 'Gestion des accès utilisateurs';
  static const String userAccessTitle = 'Accès utilisateur';
  static const String noUserDataError = 'Erreur : aucune donnée utilisateur';
  static String userAccessAppBarTitle(String first, String last) =>
      '$first $last — accès';
  static String userAccessModalTitle(String first, String last) =>
      '$first $last — accès';

  static const String standaloneAppTitle = 'Gestion des accès utilisateurs';

  // Liste
  static const String searchUsersHint = 'Rechercher des utilisateurs…';
  static const String currentUser = 'Utilisateur connecté';
  static const String errorLoadingUsers = 'Erreur de chargement des utilisateurs';
  static const String retry = 'Réessayer';
  static const String noUsersFound = 'Aucun utilisateur';
  static const String noUsersAdjustSearch = 'Modifiez votre recherche';
  static const String noUsersForAccess = 'Aucun utilisateur pour la gestion des accès';
  static const String accessUnknown = 'Accès : inconnu';
  static const String fullAccess = 'Accès complet';
  static String limitedAccessSummary(int chains, int boutiques) =>
      'Limité : $chains chaîne(s) de magasins, $boutiques boutique(s)';
  static const String noAccess = 'Aucun accès';

  // User access widget
  static const String changeMyPassword = 'Changer mon mot de passe';
  static const String updateUserPassword = 'Modifier le mot de passe';
  static const String readOnlyCurrentUser = 'Lecture seule pour l’utilisateur connecté';
  static const String summaryChains = 'Chaînes de magasins';
  static const String summaryBoutiques = 'Boutiques';
  static const String accessLevel = 'Niveau d’accès';
  static const String accessFull = 'Complet';
  static const String accessLimited = 'Limité';
  static const String fullAccessToggleTitle = 'Accès complet';
  static const String fullAccessToggleSubtitle =
      'Accorder l’accès à toutes les chaînes de magasins et à toutes les boutiques.';
  static const String chainBoutiqueSectionTitle =
      'Accès par chaîne de magasins et par boutique';
  static String boutiquesSelectedInChain(int n, int total) =>
      '$n / $total boutiques sélectionnées';
  static String boutiqueIdLine(String id) => 'ID : $id';
  static const String savingAccess = 'Enregistrement…';
  static const String saveAccess = 'Enregistrer l’accès';
  static const String saveAccessTooltip = 'Enregistrer les modifications d’accès';
  static const String errorLoadingUserAccess = 'Erreur de chargement des accès';
  static const String unknownError = 'Erreur inconnue';
  static String accessUpdatedFor(String first, String last) =>
      'Accès mis à jour pour $first $last';
  static const String failedSavePermissions = 'Échec de l’enregistrement des droits d’accès';
  static String failedLoadPermissionsGrpc(Object code, String? message) =>
      'Échec du chargement des droits : $code $message';
  static String failedLoadPermissionsGeneric(Object e) =>
      'Échec du chargement des droits : $e';
  static String errorSavingPermissionsGrpc(Object code, String? message) =>
      'Erreur à l’enregistrement : $code $message';
  static String errorSavingPermissionsGeneric(Object e) =>
      'Erreur à l’enregistrement : $e';

  // Change password dialog
  static const String passwordUpdatedSelf = 'Votre mot de passe a été mis à jour';
  static const String passwordUpdatedOther = 'Mot de passe mis à jour';
  static const String noPermissionChangePassword =
      'Vous n’avez pas le droit de modifier ce mot de passe';
  static String invalidPasswordInput(String? message) =>
      message ?? 'Saisie invalide. Vérifiez les mots de passe.';
  static String failedUpdatePassword(String? message) =>
      'Échec de la mise à jour du mot de passe : $message';
  static String errorUpdatingPassword(Object e) =>
      'Erreur lors de la mise à jour du mot de passe : $e';
  static const String passwordRequired = 'Le mot de passe est obligatoire';
  static const String passwordMinLength = 'Au moins 3 caractères';
  static const String passwordsDoNotMatch = 'Les mots de passe ne correspondent pas';
  static const String changeMyPasswordTitle = 'Changer mon mot de passe';
  static const String updateUserPasswordTitle = 'Modifier le mot de passe';
  static const String currentPasswordLabel = 'Mot de passe actuel';
  static const String newPasswordLabel = 'Nouveau mot de passe';
  static const String confirmPasswordLabel = 'Confirmer le nouveau mot de passe';
  static const String requiredField = 'Obligatoire';
  static const String cancel = 'Annuler';
  static const String saving = 'Enregistrement…';
  static const String changePasswordAction = 'Modifier';
  static const String resetPasswordAction = 'Réinitialiser';
}
