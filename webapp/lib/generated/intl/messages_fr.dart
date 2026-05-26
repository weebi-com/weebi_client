// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'fr';

  static String m0(count) =>
      "${Intl.plural(count, one: 'Bouton', other: 'Boutons')}";

  static String m1(count) =>
      "${Intl.plural(count, one: 'Couleur', other: 'Couleurs')}";

  static String m2(name) => "L\'entreprise « ${name} » a bien été créée.";

  static String m3(count) =>
      "${Intl.plural(count, one: 'Dialogue', other: 'Dialogues')}";

  static String m4(value) =>
      "La valeur de ce champ doit être égale à ${value}.";

  static String m5(count) =>
      "${Intl.plural(count, one: 'Extension', other: 'Extensions')}";

  static String m6(count) =>
      "${Intl.plural(count, one: 'Formulaire', other: 'Formulaires')}";

  static String m7(max) => "La valeur doit être inférieure ou égale à ${max}.";

  static String m8(maxLength) =>
      "La longueur doit être inférieure ou égale à ${maxLength}.";

  static String m9(min) => "La valeur doit être supérieure ou égale à ${min}.";

  static String m10(minLength) =>
      "La longueur doit être supérieure ou égale à ${minLength}.";

  static String m11(count) =>
      "${Intl.plural(count, one: 'Nouvelle Commande', other: 'Nouvelles Commandes')}";

  static String m12(count) =>
      "${Intl.plural(count, one: 'Nouvel Utilisateur', other: 'Nouveaux Utilisateurs')}";

  static String m13(value) =>
      "La valeur de ce champ ne doit pas être égale à ${value}.";

  static String m14(count) =>
      "${Intl.plural(count, one: 'Page', other: 'Pages')}";

  static String m15(count) =>
      "${Intl.plural(count, one: 'Problème en Attente', other: 'Problèmes en Attente')}";

  static String m16(count) =>
      "${Intl.plural(count, one: 'Commande Récente', other: 'Commandes Récentes')}";

  static String m17(ticketId) => "Détail du ticket n°${ticketId}";

  static String m18(count) => "${count} art.";

  static String m19(count) =>
      "${Intl.plural(count, one: '# ticket', other: '# tickets')}";

  static String m20(count) =>
      "${Intl.plural(count, one: 'Élément UI', other: 'Éléments UI')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("À propos"),
    "aboutBlog": MessageLookupByLibrary.simpleMessage("Blog"),
    "aboutPartners": MessageLookupByLibrary.simpleMessage(
      "Partenaires historiques",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Mon Compte"),
    "adminPortalLogin": MessageLookupByLibrary.simpleMessage(
      "Connexion au Portail Administrateur",
    ),
    "backToLogin": MessageLookupByLibrary.simpleMessage(
      "Retour à la Connexion",
    ),
    "billingAcceptEnterpriseTerms": MessageLookupByLibrary.simpleMessage(
      "J\'ai lu et j\'accepte les Conditions Générales de Vente applicables à l\'achat d\'une licence Entreprise.",
    ),
    "billingAcceptTermsToContinue": MessageLookupByLibrary.simpleMessage(
      "Veuillez accepter les conditions générales pour continuer.",
    ),
    "billingActionNotPermitted": MessageLookupByLibrary.simpleMessage(
      "Vous n\'avez pas l\'autorisation d\'effectuer cette action.",
    ),
    "billingAllUsersAlreadyAssigned": MessageLookupByLibrary.simpleMessage(
      "Tous les utilisateurs ont déjà une licence attribuée.",
    ),
    "billingAssignSeatDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Attribuer la licence à un utilisateur",
    ),
    "billingAssignSeats": MessageLookupByLibrary.simpleMessage(
      "Attribuer la licence à un utilisateur",
    ),
    "billingAssignSeatsCta": MessageLookupByLibrary.simpleMessage(
      "Attribuez vos nouvelles licences aux utilisateurs ci‑dessous.",
    ),
    "billingAttributedTo": MessageLookupByLibrary.simpleMessage("Attribué à"),
    "billingLicenses": MessageLookupByLibrary.simpleMessage("Licence(s)"),
    "billingLifetime": MessageLookupByLibrary.simpleMessage("À vie"),
    "billingMyLicenses": MessageLookupByLibrary.simpleMessage("Mes licences"),
    "billingNoAccess": MessageLookupByLibrary.simpleMessage(
      "Vous n\'avez pas l\'autorisation de gérer les licences. Demandez à l\'administrateur de votre entreprise de vous accorder l\'accès.",
    ),
    "billingNoUsersAvailable": MessageLookupByLibrary.simpleMessage(
      "Aucun utilisateur à attribuer. Ajoutez des utilisateurs dans Utilisateurs d\'abord.",
    ),
    "billingNotYetAttributed": MessageLookupByLibrary.simpleMessage(
      "Pas encore attribuée(s)",
    ),
    "billingPaymentProcessing": MessageLookupByLibrary.simpleMessage(
      "Paiement reçu. Votre ou vos licences apparaîtront sous peu ; vous pourrez ensuite attribuer les places aux utilisateurs.",
    ),
    "billingPaymentSuccess": MessageLookupByLibrary.simpleMessage(
      "Paiement accepté. Une ou plusieurs licences ont bien été achetées : vous pouvez les attribuer aux utilisateurs concernés.",
    ),
    "billingPurchase": MessageLookupByLibrary.simpleMessage("Acheter"),
    "billingPurchaseLicense": MessageLookupByLibrary.simpleMessage(
      "Acheter une licence",
    ),
    "billingPurchaseLicenseDescription": MessageLookupByLibrary.simpleMessage(
      "Choisissez une licence pour débloquer les fonctions avancées de Weebi. Chaque license est un achat unique : il n\'expire pas, et ce n\'est pas un abonnement — pas de renouvellement, pas de date limite.",
    ),
    "billingReassignNoOtherUser": MessageLookupByLibrary.simpleMessage(
      "Aucun autre utilisateur ne peut recevoir cette license. Ajoutez un utilisateur ou libérez une license ailleurs d’abord.",
    ),
    "billingReassignSeat": MessageLookupByLibrary.simpleMessage("Réattribuer"),
    "billingReassignSeatDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Réattribuer cette license à un autre utilisateur",
    ),
    "billingRetry": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "billingSeatsAttributed": MessageLookupByLibrary.simpleMessage(
      "licence(s) attribuée(s)",
    ),
    "billingUsers": MessageLookupByLibrary.simpleMessage("utilisateur(s)"),
    "billingValidUntil": MessageLookupByLibrary.simpleMessage(
      "Valide jusqu\'au",
    ),
    "billingViewFullTerms": MessageLookupByLibrary.simpleMessage(
      "Conditions Générales de Vente",
    ),
    "billingPlanEntreprise": MessageLookupByLibrary.simpleMessage(
      "Weebi Entreprise",
    ),
    "billingPlanPremium": MessageLookupByLibrary.simpleMessage(
      "Weebi Premium",
    ),
    "billingPerUser": MessageLookupByLibrary.simpleMessage("par utilisateur"),
    "buttonEmphasis": MessageLookupByLibrary.simpleMessage(
      "Accentuation du Bouton",
    ),
    "buttons": m0,
    "cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
    "changeProfilePhoto": MessageLookupByLibrary.simpleMessage(
      "Changer la photo",
    ),
    "closeNavigationMenu": MessageLookupByLibrary.simpleMessage(
      "Fermer le Menu de Navigation",
    ),
    "colorPalette": MessageLookupByLibrary.simpleMessage("Palette de Couleurs"),
    "colorScheme": MessageLookupByLibrary.simpleMessage("Schéma de Couleurs"),
    "colors": m1,
    "confirmDeleteRecord": MessageLookupByLibrary.simpleMessage(
      "Confirmer la suppression de cet enregistrement?",
    ),
    "confirmSubmitRecord": MessageLookupByLibrary.simpleMessage(
      "Confirmer la soumission de cet enregistrement?",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copier"),
    "createEnterpriseErrorPrefix": MessageLookupByLibrary.simpleMessage(
      "Erreur lors de la création de l\'entreprise : ",
    ),
    "createEnterprisePageTitle": MessageLookupByLibrary.simpleMessage(
      "Créer une entreprise",
    ),
    "createEnterpriseSuccessTitle": m2,
    "creditCardErrorText": MessageLookupByLibrary.simpleMessage(
      "Ce champ nécessite un numéro de carte de crédit valide.",
    ),
    "crudBack": MessageLookupByLibrary.simpleMessage("Retour"),
    "crudDelete": MessageLookupByLibrary.simpleMessage("Supprimer"),
    "crudDetail": MessageLookupByLibrary.simpleMessage("Détail"),
    "crudNew": MessageLookupByLibrary.simpleMessage("Nouveau"),
    "darkTheme": MessageLookupByLibrary.simpleMessage("Thème Sombre"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Tableau de Bord"),
    "dashboardCardBoutiquesValue": MessageLookupByLibrary.simpleMessage(
      "Mes boutiques",
    ),
    "dashboardCardDevicesValue": MessageLookupByLibrary.simpleMessage(
      "Appareils",
    ),
    "dashboardCardMyFirmValue": MessageLookupByLibrary.simpleMessage(
      "Mon entreprise",
    ),
    "dashboardCardTicketsShort": MessageLookupByLibrary.simpleMessage(
      "Tickets",
    ),
    "dashboardCardTicketsToday": MessageLookupByLibrary.simpleMessage(
      "Tickets du jour",
    ),
    "dashboardCardUserAccess": MessageLookupByLibrary.simpleMessage(
      "Accès utilisateurs",
    ),
    "dashboardCardUsersValue": MessageLookupByLibrary.simpleMessage(
      "Utilisateurs",
    ),
    "dateStringErrorText": MessageLookupByLibrary.simpleMessage(
      "Ce champ nécessite une chaîne de date valide.",
    ),
    "dialogs": m3,
    "dontHaveAnAccount": MessageLookupByLibrary.simpleMessage(
      "Vous n\'avez pas de compte ?",
    ),
    "email": MessageLookupByLibrary.simpleMessage("E-mail"),
    "emailErrorText": MessageLookupByLibrary.simpleMessage(
      "Ce champ nécessite une adresse e-mail valide.",
    ),
    "enterpriseNameFieldHint": MessageLookupByLibrary.simpleMessage(
      "Nom de l\'entreprise",
    ),
    "enterpriseNameFieldLabel": MessageLookupByLibrary.simpleMessage(
      "Entreprise",
    ),
    "equalErrorText": m4,
    "error404": MessageLookupByLibrary.simpleMessage("Erreur 404"),
    "error404Message": MessageLookupByLibrary.simpleMessage(
      "Désolé, la page que vous recherchez a été supprimée ou n\'existe pas.",
    ),
    "error404Title": MessageLookupByLibrary.simpleMessage("Page non trouvée"),
    "example": MessageLookupByLibrary.simpleMessage("Exemple"),
    "extensions": m5,
    "firmCardDescription": MessageLookupByLibrary.simpleMessage(
      "Votre entreprise regroupe vos utilisateurs et vos chaînes ou boutiques.",
    ),
    "firmErrorCreateHint": MessageLookupByLibrary.simpleMessage(
      "Veuillez créer une nouvelle entreprise en cliquant sur le bouton « Ajouter une entreprise ».",
    ),
    "firmErrorUnexpected": MessageLookupByLibrary.simpleMessage(
      "Une erreur inattendue est survenue.",
    ),
    "firmPageTitle": MessageLookupByLibrary.simpleMessage("Mon entreprise"),
    "firstName": MessageLookupByLibrary.simpleMessage("Prénom"),
    "forgotPassword": MessageLookupByLibrary.simpleMessage(
      "Mot de passe oublié ?",
    ),
    "forgotPasswordMessage": MessageLookupByLibrary.simpleMessage(
      "Saisissez votre adresse e-mail pour réinitialiser votre mot de passe.",
    ),
    "forgotPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Mot de passe oublié",
    ),
    "forms": m6,
    "generalUi": MessageLookupByLibrary.simpleMessage("UI Générale"),
    "help": MessageLookupByLibrary.simpleMessage("Aide"),
    "helpReadFaq": MessageLookupByLibrary.simpleMessage("Lire la FAQ"),
    "helpResourcesTitle": MessageLookupByLibrary.simpleMessage("Ressources"),
    "helpScopeBody": MessageLookupByLibrary.simpleMessage(
      "La console web permet de gérer les tickets (consultation, filtres, recherche). Les articles, contacts et opérations (ventes, achats, mouvements de stock, etc.) sont uniquement disponibles sur l\'application de caisse pour l\'instant.",
    ),
    "helpScopeTitle": MessageLookupByLibrary.simpleMessage(
      "Que puis-je faire depuis la console web ?",
    ),
    "helpWatchDemos": MessageLookupByLibrary.simpleMessage(
      "Voir les démos vidéo",
    ),
    "hi": MessageLookupByLibrary.simpleMessage("Salut"),
    "homePage": MessageLookupByLibrary.simpleMessage("Accueil"),
    "iframeDemo": MessageLookupByLibrary.simpleMessage("Démo IFrame"),
    "integerErrorText": MessageLookupByLibrary.simpleMessage(
      "Ce champ nécessite un entier valide.",
    ),
    "ipErrorText": MessageLookupByLibrary.simpleMessage(
      "Ce champ nécessite une IP valide.",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Langue"),
    "lastName": MessageLookupByLibrary.simpleMessage("Nom"),
    "legalDocTitleCgvFr": MessageLookupByLibrary.simpleMessage(
      "Conditions Générales de Vente",
    ),
    "legalDocTitleTermsEn": MessageLookupByLibrary.simpleMessage(
      "Terms and Conditions of Sale",
    ),
    "legalDocumentVersionId": MessageLookupByLibrary.simpleMessage(
      "Référence du document",
    ),
    "lightTheme": MessageLookupByLibrary.simpleMessage("Thème Clair"),
    "login": MessageLookupByLibrary.simpleMessage("Connexion"),
    "loginNow": MessageLookupByLibrary.simpleMessage("Connectez-vous"),
    "logout": MessageLookupByLibrary.simpleMessage("Déconnexion"),
    "loremIpsum": MessageLookupByLibrary.simpleMessage(
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
    ),
    "mail": MessageLookupByLibrary.simpleMessage("E-mail"),
    "matchErrorText": MessageLookupByLibrary.simpleMessage(
      "La valeur ne correspond pas au motif.",
    ),
    "maxErrorText": m7,
    "maxLengthErrorText": m8,
    "menuAccesses": MessageLookupByLibrary.simpleMessage("Accès"),
    "menuBilling": MessageLookupByLibrary.simpleMessage("Licences Weebi"),
    "menuBoutiques": MessageLookupByLibrary.simpleMessage("Mes Boutiques"),
    "menuDevices": MessageLookupByLibrary.simpleMessage("Appareils"),
    "menuFirm": MessageLookupByLibrary.simpleMessage("Mon entreprise"),
    "menuScopeDisclaimer": MessageLookupByLibrary.simpleMessage(
      "Les articles, contacts et opérations (ventes, achats, mouvements de stock, etc.) sont uniquement disponibles sur l\'application de caisse pour l\'instant.",
    ),
    "menuTickets": MessageLookupByLibrary.simpleMessage("Tickets"),
    "menuUsers": MessageLookupByLibrary.simpleMessage("Utilisateurs"),
    "minErrorText": m9,
    "minLengthErrorText": m10,
    "myProfile": MessageLookupByLibrary.simpleMessage("Mon Profil"),
    "newOrders": m11,
    "newUsers": m12,
    "notEqualErrorText": m13,
    "numericErrorText": MessageLookupByLibrary.simpleMessage(
      "La valeur doit être numérique.",
    ),
    "openInNewTab": MessageLookupByLibrary.simpleMessage(
      "Ouvrir dans un nouvel onglet",
    ),
    "operationalLicenseBlockedBody": MessageLookupByLibrary.simpleMessage(
      "L\'administrateur de votre entreprise doit vous attribuer une license active, ou vous devez vous connecter avec le compte créateur de l\'entreprise, avant d\'accéder aux tickets, articles et contacts. Ouvrez Facturation si vous gérez les licences.",
    ),
    "operationalLicenseBlockedTitle": MessageLookupByLibrary.simpleMessage(
      "Licence active requise",
    ),
    "operationalLicenseOpenBilling": MessageLookupByLibrary.simpleMessage(
      "Facturation",
    ),
    "operationalLicenseRetry": MessageLookupByLibrary.simpleMessage(
      "Réessayer",
    ),
    "pages": m14,
    "password": MessageLookupByLibrary.simpleMessage("Mot de Passe"),
    "passwordNotMatch": MessageLookupByLibrary.simpleMessage(
      "Les mots de passe ne correspondent pas.",
    ),
    "pendingIssues": m15,
    "recentOrders": m16,
    "recordDeletedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Enregistrement supprimé avec succès.",
    ),
    "recordSavedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Enregistrement sauvegardé avec succès.",
    ),
    "recordSubmittedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Enregistrement soumis avec succès.",
    ),
    "refreshAction": MessageLookupByLibrary.simpleMessage("Actualiser"),
    "register": MessageLookupByLibrary.simpleMessage("S\'inscrire"),
    "registerANewAccount": MessageLookupByLibrary.simpleMessage(
      "Créer un nouveau compte",
    ),
    "registerNow": MessageLookupByLibrary.simpleMessage("Inscrivez-vous"),
    "requiredErrorText": MessageLookupByLibrary.simpleMessage(
      "Ce champ ne peut pas être vide.",
    ),
    "retypePassword": MessageLookupByLibrary.simpleMessage(
      "Retaper le Mot de Passe",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Sauvegarder"),
    "search": MessageLookupByLibrary.simpleMessage("Rechercher"),
    "submit": MessageLookupByLibrary.simpleMessage("Soumettre"),
    "support": MessageLookupByLibrary.simpleMessage("Support"),
    "supportChatWhatsApp": MessageLookupByLibrary.simpleMessage(
      "Discuter avec le support Weebi",
    ),
    "supportEmailUs": MessageLookupByLibrary.simpleMessage(
      "Nous envoyer un e-mail",
    ),
    "text": MessageLookupByLibrary.simpleMessage("Texte"),
    "textEmphasis": MessageLookupByLibrary.simpleMessage(
      "Accentuation du Texte",
    ),
    "textTheme": MessageLookupByLibrary.simpleMessage("Thème du Texte"),
    "ticketDetailTitle": m17,
    "ticketItemsShort": m18,
    "ticketNotProvided": MessageLookupByLibrary.simpleMessage(
      "Ticket non fourni",
    ),
    "ticketTypeDefault": MessageLookupByLibrary.simpleMessage("Ticket"),
    "ticketsBoutiqueAll": MessageLookupByLibrary.simpleMessage(
      "Toutes les boutiques",
    ),
    "ticketsBoutiqueFallback": MessageLookupByLibrary.simpleMessage("Boutique"),
    "ticketsChainUnavailable": MessageLookupByLibrary.simpleMessage(
      "Chaîne non disponible",
    ),
    "ticketsColumnAmount": MessageLookupByLibrary.simpleMessage("Montant"),
    "ticketsColumnBoutique": MessageLookupByLibrary.simpleMessage("Boutique"),
    "ticketsColumnContact": MessageLookupByLibrary.simpleMessage("Contact"),
    "ticketsColumnDateAndNumber": MessageLookupByLibrary.simpleMessage(
      "Date · n°",
    ),
    "ticketsColumnType": MessageLookupByLibrary.simpleMessage("Type"),
    "ticketsCount": m19,
    "ticketsDateAll": MessageLookupByLibrary.simpleMessage("Toutes les dates"),
    "ticketsDeletedChip": MessageLookupByLibrary.simpleMessage("Supprimés"),
    "ticketsDeletedExclude": MessageLookupByLibrary.simpleMessage(
      "Non supprimés",
    ),
    "ticketsDeletedOnly": MessageLookupByLibrary.simpleMessage(
      "Supprimés uniquement",
    ),
    "ticketsEmpty": MessageLookupByLibrary.simpleMessage("Aucun ticket"),
    "ticketsFiltersTitle": MessageLookupByLibrary.simpleMessage("Filtres"),
    "ticketsGroupByBoutique": MessageLookupByLibrary.simpleMessage(
      "Grouper par boutique",
    ),
    "ticketsPaymentCard": MessageLookupByLibrary.simpleMessage("Carte"),
    "ticketsPaymentCash": MessageLookupByLibrary.simpleMessage("Espèces"),
    "ticketsPaymentCheque": MessageLookupByLibrary.simpleMessage("Chèque"),
    "ticketsPaymentCredit": MessageLookupByLibrary.simpleMessage("Crédit"),
    "ticketsPaymentGoods": MessageLookupByLibrary.simpleMessage("Marchandises"),
    "ticketsPaymentMobileMoney": MessageLookupByLibrary.simpleMessage(
      "Mobile Money",
    ),
    "ticketsPaymentUnknown": MessageLookupByLibrary.simpleMessage("—"),
    "ticketsSeatEntitlementSubtitle": MessageLookupByLibrary.simpleMessage(
      "Licence active requise",
    ),
    "ticketsSeatGatedBoutiqueViewsDetail": MessageLookupByLibrary.simpleMessage(
      "Le filtre et le groupement par boutique exigent une licence.",
    ),
    "ticketsSeatGatedBoutiqueViewsTitle": MessageLookupByLibrary.simpleMessage(
      "Filtre et groupement par boutique",
    ),
    "ticketsSortChronological": MessageLookupByLibrary.simpleMessage(
      "Ordre chronologique",
    ),
    "ticketsStatusActive": MessageLookupByLibrary.simpleMessage("Actifs"),
    "ticketsStatusAll": MessageLookupByLibrary.simpleMessage("Tous"),
    "ticketsStatusInactive": MessageLookupByLibrary.simpleMessage("Inactifs"),
    "ticketsTooltipClearDates": MessageLookupByLibrary.simpleMessage(
      "Toutes les dates",
    ),
    "ticketsTooltipFilterBoutique": MessageLookupByLibrary.simpleMessage(
      "Filtrer par boutique",
    ),
    "ticketsTooltipFilterByStatus": MessageLookupByLibrary.simpleMessage(
      "Filtrer par statut",
    ),
    "ticketsTooltipFilterDeleted": MessageLookupByLibrary.simpleMessage(
      "Filtrer par tickets supprimés",
    ),
    "ticketsTooltipRefresh": MessageLookupByLibrary.simpleMessage("Actualiser"),
    "todaySales": MessageLookupByLibrary.simpleMessage(
      "Ventes d\'Aujourd\'hui",
    ),
    "typography": MessageLookupByLibrary.simpleMessage("Typographie"),
    "uiElements": m20,
    "urlErrorText": MessageLookupByLibrary.simpleMessage(
      "Ce champ nécessite une adresse URL valide.",
    ),
    "username": MessageLookupByLibrary.simpleMessage("Nom d\'Utilisateur"),
    "yes": MessageLookupByLibrary.simpleMessage("Oui"),
  };
}
