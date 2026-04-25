/// French UI strings for `boutiques_weebi` (default locale).
abstract final class BoutiqueUiStrings {
  static const String appBarBoutiquesChains =
      'Boutiques et chaînes de magasins';

  static String errorPrefix(String detail) => 'Erreur : $detail';
  static const String retry = 'Réessayer';
  static const String noChainsOrBoutiques =
      'Aucune chaîne de magasins ni boutique';
  static const String createChain = 'Créer une chaîne de magasins';
  static const String createBoutique = 'Créer une boutique';
  static const String tooltipCreateChain =
      'Créer une chaîne de magasins pour regrouper plusieurs boutiques';
  static const String tooltipCreateBoutique = 'Créer une boutique';
  static const String selectChainTitle = 'Choisir une chaîne de magasins';
  static String chainBoutiqueCount(int n) => '$n boutiques';
  static const String cancel = 'Annuler';
  static const String searchHint =
      'Rechercher des boutiques ou des chaînes de magasins…';
  static const String noResults = 'Aucun résultat';
  static String addBoutiqueToChain(String chainName) =>
      'Ajouter une boutique à la chaîne de magasins « $chainName »';
  static const String editChain = 'Modifier la chaîne';
  static const String deleteChain = 'Supprimer la chaîne';
  static const String editBoutique = 'Modifier la boutique';
  static const String deleteBoutique = 'Supprimer la boutique';

  static const String deleteChainTitle = 'Supprimer la chaîne';
  static String deleteChainConfirm(String name) =>
      'Supprimer la chaîne « $name » ?';
  static const String warning = 'Attention';
  static String deleteChainWithBoutiquesWarning(int count) =>
      'Cette chaîne de magasins regroupe $count boutique(s). '
      'La supprimer supprimera aussi toutes ces boutiques.';
  static const String actionCannotUndo =
      'Cette action est irréversible.';
  static const String deleteChainAndBoutiques =
      'Supprimer la chaîne de magasins et ses boutiques';
  static const String deleteBoutiqueTitle = 'Supprimer la boutique';
  static String deleteBoutiqueConfirm(String name) =>
      'Supprimer la boutique « $name » ?';

  static const String deleteAction = 'Supprimer';

  static String chainUpdatedSuccess(String name) =>
      'Chaîne « $name » mise à jour.';
  static String boutiqueUpdatedSuccess(String name) =>
      'Boutique « $name » mise à jour.';
  static String chainDeletedSuccess(String name) =>
      'Chaîne « $name » supprimée.';
  static const String failedDeleteChainFallback =
      'Échec de la suppression de la chaîne';
  static const String failedDeleteBoutiqueFallback =
      'Échec de la suppression de la boutique';
  static String unexpectedError(Object e) => 'Erreur inattendue : $e';
  static String boutiqueDeletedSuccess(String name) =>
      'Boutique « $name » supprimée.';

  // Formulaire (dialogue édition)
  static const String editChainDialogTitle = 'Modifier la chaîne';
  static const String editBoutiqueDialogTitle = 'Modifier la boutique';
  static const String chainNameLabel = 'Nom de la chaîne *';
  static const String boutiqueNameLabel = 'Nom de la boutique *';
  static const String nameRequired = 'Le nom est obligatoire';
  static const String emailLabel = 'E-mail';
  static const String streetAddressLabel = 'Adresse';
  static const String cityLabel = 'Ville';
  static const String postalCodeLabel = 'Code postal';
  static const String countryLabel = 'Pays *';
  static const String selectCountryHint = 'Choisir un pays';
  static const String selectCountryError = 'Veuillez choisir un pays';
  static const String phoneLabel = 'Téléphone';
  static const String activeTitle = 'Actif';
  static const String save = 'Enregistrer';

  // Création / édition plein écran
  static const String basicInformation = 'Informations générales';
  static String enterNameTooltip(bool isChain) => isChain
      ? 'Nom affiché pour la chaîne de magasins (groupe de boutiques)'
      : 'Saisir le nom de la boutique';
  static String nameLabelForType(bool isChain) =>
      isChain ? 'Nom de la chaîne *' : 'Nom de la boutique *';
  static const String hintChainNameExample =
      'Ex. : Réseau centre-ville';
  static const String hintBoutiqueNameExample =
      'Ex. : Magasin rue principale';
  static String pleaseEnterName(bool isChain) => isChain
      ? 'Veuillez saisir le nom de la chaîne'
      : 'Veuillez saisir le nom de la boutique';
  static const String nameMinLength = 'Au moins 2 caractères';
  static const String emailAddressLabel = 'Adresse e-mail';
  static const String enterBoutiqueEmailHint = 'E-mail de la boutique';
  static const String enterBoutiqueEmailTooltip = 'E-mail de la boutique';
  static const String billingCurrencyLabel = 'Devise';
  static const String billingCurrencyTooltip =
      'Code ISO 4217. Vide : héritage chaîne, puis société, puis plateforme.';
  static const String secondaryDisplayCurrencyLabel =
      'Devise d’affichage secondaire';
  static const String secondaryDisplayCurrencyTooltip =
      'Ex. USD — montants de référence affichés en complément de la devise principale.';
  static const String dualCurrencySwitchTitle =
      'Afficher une devise secondaire';
  static const String dualCurrencySwitchSubtitle =
      'Souvent pour afficher aussi les montants en dollars US.';
  static const String currencySectionTitle = 'Devise(s)';
  static const String chainAssignment =
      'Rattachement à une chaîne de magasins';
  static const String noChainsCreateFirst =
      'Aucune chaîne de magasins. Créez d’abord une chaîne pour y rattacher des boutiques.';
  static const String selectChainLabel = 'Chaîne de magasins';
  static String chainDropdownSubtitle(String name, int count) =>
      '$name ($count boutiques)';
  static const String pleaseSelectChain =
      'Veuillez choisir une chaîne de magasins';
  static const String streetAddressStar = 'Adresse *';
  static const String enterStreetHint = 'Saisir l’adresse';
  static const String enterStreetTooltip = 'Saisir l’adresse de la boutique';
  static const String pleaseEnterStreet = 'Veuillez saisir l’adresse';
  static const String cityStar = 'Ville *';
  static const String pleaseEnterCity = 'Veuillez saisir la ville';
  static const String enterPhoneTooltip = 'Numéro de téléphone de la boutique';
  static const String enterPhoneHint = 'Numéro (chiffres uniquement)';
  static const String phoneNumbersOnly = 'Chiffres uniquement';
  static const String phoneLengthRange =
      'Le numéro doit comporter entre 7 et 15 chiffres';
  static const String creating = 'Création…';
  static const String saveChanges = 'Enregistrer les modifications';
  static String createType(bool isChain) =>
      isChain ? createChain : createBoutique;
  static String deleteTypeTitle(bool isChain) =>
      isChain ? 'Supprimer la chaîne' : 'Supprimer la boutique';
  static String deleteChainBody() =>
      'Voulez-vous vraiment supprimer cette chaîne de magasins ?\n\n$actionCannotUndo';
  static String deleteBoutiqueBody() =>
      'Voulez-vous vraiment supprimer cette boutique ?\n\n$actionCannotUndo';

  static String submitSuccess(bool isChain, bool editing) {
    if (isChain) {
      return editing ? 'Chaîne mise à jour.' : 'Chaîne créée.';
    }
    return editing ? 'Boutique mise à jour.' : 'Boutique créée.';
  }

  static String submitFailed(bool isChain, bool editing) => isChain
      ? (editing
          ? 'Échec de la mise à jour de la chaîne'
          : 'Échec de la création de la chaîne')
      : (editing
          ? 'Échec de la mise à jour de la boutique'
          : 'Échec de la création de la boutique');

  static const String pleaseSelectChainError = pleaseSelectChain;
  static String deleteSuccess(bool isChain) =>
      isChain ? 'Chaîne supprimée.' : 'Boutique supprimée.';
  static String deleteFailed(bool isChain) => isChain
      ? 'Échec de la suppression de la chaîne'
      : 'Échec de la suppression de la boutique';

  // Routes (démo)
  static String deleteConfirmTitle(String type) => 'Supprimer $type';
  static String deleteConfirmContent(String name) =>
      'Voulez-vous vraiment supprimer « $name » ?\n\n$actionCannotUndo';
  static String demoDeleted(String type, String name) =>
      'Démo : $type « $name » serait supprimé';

  static String demoDeletedChain(String name) =>
      'Démo : la chaîne « $name » serait supprimée';

  static String demoDeletedBoutique(String name) =>
      'Démo : la boutique « $name » serait supprimée';
}
