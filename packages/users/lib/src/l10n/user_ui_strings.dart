/// French UI strings for `users_weebi` (default locale).
abstract final class UserUiStrings {
  // ——— Liste utilisateurs ———
  static const String searchUsersHint = 'Rechercher des utilisateurs…';
  static String errorPrefix(String detail) => 'Erreur : $detail';
  static const String retry = 'Réessayer';
  static const String noUsersFound = 'Aucun utilisateur';
  static const String addUser = 'Ajouter un utilisateur';
  static const String noUsersMatchSearch = 'Aucun résultat pour cette recherche';
  static const String tryAdjustingSearch = 'Modifiez votre recherche';
  static const String editUserTooltip = 'Modifier';
  static const String deleteUserTooltip = 'Supprimer';

  static const String deleteUserTitle = 'Supprimer l’utilisateur';
  static String deleteUserConfirm(String first, String last) =>
      'Supprimer $first $last ?';

  static const String cancel = 'Annuler';
  static const String delete = 'Supprimer';

  // ——— Création utilisateur ———
  static String userCreatedSuccess(String first, String last) =>
      'Utilisateur $first $last créé.';
  static const String ok = 'OK';
  static const String errorDialogTitle = 'Erreur';
  static const String details = 'Détails';
  static String errorCreatingUser(String msg) => 'Échec de la création : $msg';

  static const String discardChangesTitle = 'Abandonner les modifications ?';
  static const String discardChangesBody =
      'Voulez-vous vraiment abandonner les modifications ?';
  static const String discard = 'Abandonner';

  static const String labelFirstName = 'Prénom *';
  static const String labelLastName = 'Nom *';
  static const String labelEmail = 'Adresse e-mail *';
  static const String labelPhone = 'Téléphone';
  static const String firstNameRequired = 'Le prénom est obligatoire';
  static const String lastNameRequired = 'Le nom est obligatoire';
  static const String emailRequired = 'L’e-mail est obligatoire';
  static const String emailInvalid = 'Saisissez une adresse e-mail valide';
  static const String phoneTooShort =
      'Le numéro doit comporter au moins 8 chiffres';

  static const String creating = 'Création…';
  static const String createUser = 'Créer l’utilisateur';

  // ——— Formulaire utilisateur ———
  static const String userUpdatedSuccess = 'Utilisateur mis à jour.';
  static const String userCreatedSuccessShort = 'Utilisateur créé.';
  static String errorGeneric(String msg) => 'Erreur : $msg';
  static const String saving = 'Enregistrement…';
  static const String updateUser = 'Mettre à jour';
  static const String createUserShort = 'Créer';
  static const String save = 'Enregistrer';

  // ——— Détail utilisateur ———
  static const String labelId = 'Identifiant';
  static const String labelLastSignIn = 'Dernière connexion';
  static const String yourPermissions = 'Vos droits';
  static const String selfPermissionsReadOnlyHint =
      'Par précaution, les droits utilisateurs doivent être modifiés par un tiers.';
  static const String firmCreatorReadOnlyHint =
      'Les droits du créateur d’entreprise sont affichés en lecture seule pour rester cohérents.';
  static const String noPermissionsInToken =
      'Aucun droit trouvé dans votre jeton d’authentification';

  static String permissionsTitleForUser(String firstname) =>
      'Droits de $firstname';

  // ——— Barres d’application (routes) ———
  static const String appBarUsers = 'Utilisateurs';
  static const String appBarCreateUser = 'Créer un utilisateur';

  static const String tooltipEditUser = 'Modifier l’utilisateur';
  static const String tooltipDeleteUser = 'Supprimer l’utilisateur';

  /// Préfixe ligne liste (ex. identifiant technique).
  static String userListIdLine(String userId) => '$labelId : $userId';

  // ——— Routes / jeton ———
  static const String sessionExpired = 'Session expirée. Reconnectez-vous.';
  static const String permissionsRefreshed = 'Droits actualisés.';
  static String refreshPermissionsFailed(String e) =>
      'Échec de l’actualisation des droits : $e';
  static const String refreshPermissionsTooltip = 'Actualiser les droits';

  static const String editUserAppBar = 'Modifier';
  static const String deleteUserAppBar = 'Supprimer';

  // ——— Persistance droits ———
  static String permissionsSavedFor(String firstname) =>
      'Droits enregistrés pour $firstname';
  static String permissionsSaveFailed(String e) =>
      'Échec de l’enregistrement des droits : $e';

  static String couldNotExtractFirmId(Object e) =>
      'Impossible d’extraire l’identifiant d’entreprise du jeton : $e';
}
