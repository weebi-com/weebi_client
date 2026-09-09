// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(price) => "With referral: ${price}";

  static String m1(count) =>
      "${Intl.plural(count, one: 'Button', other: 'Buttons')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'Selection', one: 'Selection (1)', other: 'Selection (${count})')}";

  static String m3(count) =>
      "${Intl.plural(count, one: 'Color', other: 'Colors')}";

  static String m4(name) =>
      "The enterprise \"${name}\" was created successfully.";

  static String m5(count) =>
      "${Intl.plural(count, one: 'Dialog', other: 'Dialogs')}";

  static String m6(value) => "This field value must be equal to ${value}.";

  static String m7(count) =>
      "${Intl.plural(count, one: 'Extension', other: 'Extensions')}";

  static String m8(count) =>
      "${Intl.plural(count, one: 'Form', other: 'Forms')}";

  static String m9(max) => "Value must be less than or equal to ${max}";

  static String m10(maxLength) =>
      "Value must have a length less than or equal to ${maxLength}";

  static String m11(min) => "Value must be greater than or equal to ${min}.";

  static String m12(minLength) =>
      "Value must have a length greater than or equal to ${minLength}";

  static String m13(count) =>
      "${Intl.plural(count, one: 'New Order', other: 'New Orders')}";

  static String m14(count) =>
      "${Intl.plural(count, one: 'New User', other: 'New Users')}";

  static String m15(value) => "This field value must not be equal to ${value}.";

  static String m16(count) =>
      "${Intl.plural(count, one: 'Page', other: 'Pages')}";

  static String m17(count) =>
      "${Intl.plural(count, one: 'Pending Issue', other: 'Pending Issues')}";

  static String m18(count) =>
      "${Intl.plural(count, one: 'Recent Order', other: 'Recent Orders')}";

  static String m19(ticketId) => "Ticket detail #${ticketId}";

  static String m20(count) => "${count} items";

  static String m21(count) =>
      "${Intl.plural(count, one: '# ticket', other: '# tickets')}";

  static String m22(count) =>
      "${Intl.plural(count, one: 'UI Element', other: 'UI Elements')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "aboutBlog": MessageLookupByLibrary.simpleMessage("Blog"),
    "aboutPartners": MessageLookupByLibrary.simpleMessage(
      "Historical Partners",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "adminPortalLogin": MessageLookupByLibrary.simpleMessage(
      "Admin Portal Login",
    ),
    "backToLogin": MessageLookupByLibrary.simpleMessage("Back to Login"),
    "billingAcceptAccountingReportTerms": MessageLookupByLibrary.simpleMessage(
      "I have read and accept the Terms and Conditions of Sale for the cash report.",
    ),
    "billingAcceptEnterpriseTerms": MessageLookupByLibrary.simpleMessage(
      "I have read and accept the Terms and Conditions of Sale for the Enterprise license.",
    ),
    "billingAcceptTermsToContinue": MessageLookupByLibrary.simpleMessage(
      "Please accept the terms and conditions to continue.",
    ),
    "billingActionNotPermitted": MessageLookupByLibrary.simpleMessage(
      "You don\'t have permission for this action.",
    ),
    "billingAllUsersAlreadyAssigned": MessageLookupByLibrary.simpleMessage(
      "All users already have a license assigned.",
    ),
    "billingAssignSeatDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Assign the license to a user",
    ),
    "billingAssignSeats": MessageLookupByLibrary.simpleMessage(
      "Assign the license to a user",
    ),
    "billingAssignSeatsCta": MessageLookupByLibrary.simpleMessage(
      "Assign your new licenses to users below.",
    ),
    "billingAttributedTo": MessageLookupByLibrary.simpleMessage(
      "Attributed to",
    ),
    "billingChoosePaymentMethod": MessageLookupByLibrary.simpleMessage(
      "How do you want to pay?",
    ),
    "billingHistoryNoLicenses": MessageLookupByLibrary.simpleMessage(
      "No Premium licenses purchased yet.",
    ),
    "billingHistoryNoSyscohadaYears": MessageLookupByLibrary.simpleMessage(
      "No fiscal years paid yet.",
    ),
    "billingLicenses": MessageLookupByLibrary.simpleMessage("License(s)"),
    "billingLifetime": MessageLookupByLibrary.simpleMessage("Lifetime"),
    "billingMyLicenses": MessageLookupByLibrary.simpleMessage(
      "My Premium licenses",
    ),
    "billingNoAccess": MessageLookupByLibrary.simpleMessage(
      "You don\'t have permission to manage licenses. Ask your enterprise administrator to grant you billing access.",
    ),
    "billingNoUsersAvailable": MessageLookupByLibrary.simpleMessage(
      "No users to assign. Add users in Users first.",
    ),
    "billingNotYetAttributed": MessageLookupByLibrary.simpleMessage(
      "Not yet attributed",
    ),
    "billingPayWithCard": MessageLookupByLibrary.simpleMessage("Card/Bank"),
    "billingPayWithMobileMoney": MessageLookupByLibrary.simpleMessage(
      "Mobile Money",
    ),
    "billingPaymentProcessing": MessageLookupByLibrary.simpleMessage(
      "Payment received. We\'re confirming it — your license(s) will appear shortly; you can then assign seats to users.",
    ),
    "billingPaymentSuccess": MessageLookupByLibrary.simpleMessage(
      "Payment accepted. One or more licenses were purchased successfully: you can assign seats to the relevant users.",
    ),
    "billingPerUser": MessageLookupByLibrary.simpleMessage("per user"),
    "billingPlanEntreprise": MessageLookupByLibrary.simpleMessage(
      "Weebi Entreprise",
    ),
    "billingPlanPremium": MessageLookupByLibrary.simpleMessage("Weebi Premium"),
    "billingPurchase": MessageLookupByLibrary.simpleMessage("Purchase"),
    "billingPurchaseLicense": MessageLookupByLibrary.simpleMessage(
      "Purchase Premium",
    ),
    "billingPurchaseLicenseDescription": MessageLookupByLibrary.simpleMessage(
      "The Premium license unlocks remote tracking, multi-store management and the advanced dashboard. One-time purchase per user: no subscription, no expiry.",
    ),
    "billingReassignNoOtherUser": MessageLookupByLibrary.simpleMessage(
      "No other user can receive this seat. Add a user or free a license seat elsewhere first.",
    ),
    "billingReassignSeat": MessageLookupByLibrary.simpleMessage("Reassign"),
    "billingReassignSeatDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Reassign this license seat to another user",
    ),
    "billingReferralCodeHint": MessageLookupByLibrary.simpleMessage(
      "Referrer firm ID (optional)",
    ),
    "billingReferralCopyCode": MessageLookupByLibrary.simpleMessage(
      "Copy code",
    ),
    "billingReferralCreditBalance": MessageLookupByLibrary.simpleMessage(
      "Referral credit balance",
    ),
    "billingReferralDiscountHint": MessageLookupByLibrary.simpleMessage(
      "10% off when you enter a valid referrer code",
    ),
    "billingReferralDiscountedPrice": m0,
    "billingReferralSelfError": MessageLookupByLibrary.simpleMessage(
      "You cannot use your own referral code",
    ),
    "billingReferralTitle": MessageLookupByLibrary.simpleMessage("Referral"),
    "billingReferralYourCode": MessageLookupByLibrary.simpleMessage(
      "Your referral code",
    ),
    "billingRetry": MessageLookupByLibrary.simpleMessage("Retry"),
    "billingSeatsAttributed": MessageLookupByLibrary.simpleMessage(
      "license(s) attributed",
    ),
    "billingSyscohadaCurrentYearDisclaimer":
        MessageLookupByLibrary.simpleMessage(
          "This report cannot be generated until the fiscal year is over.",
        ),
    "billingSyscohadaPerReport": MessageLookupByLibrary.simpleMessage(
      "per fiscal year",
    ),
    "billingSyscohadaPrice": MessageLookupByLibrary.simpleMessage(
      "1,900 XOF / 2.90 EUR",
    ),
    "billingSyscohadaPurchase": MessageLookupByLibrary.simpleMessage(
      "Pay for this year",
    ),
    "billingSyscohadaPurchasedYears": MessageLookupByLibrary.simpleMessage(
      "Years already paid",
    ),
    "billingSyscohadaSelectYear": MessageLookupByLibrary.simpleMessage(
      "Fiscal year",
    ),
    "billingSyscohadaSubtitle": MessageLookupByLibrary.simpleMessage(
      "Minimum Cash System — one-time purchase per fiscal year (not a subscription)",
    ),
    "billingSyscohadaTitle": MessageLookupByLibrary.simpleMessage(
      "SYSCOHADA financial statements",
    ),
    "billingTabHistory": MessageLookupByLibrary.simpleMessage(
      "Purchases / License assignment",
    ),
    "billingTabOffers": MessageLookupByLibrary.simpleMessage("Offers"),
    "billingUsers": MessageLookupByLibrary.simpleMessage("users"),
    "billingValidUntil": MessageLookupByLibrary.simpleMessage("Valid until"),
    "billingViewFullTerms": MessageLookupByLibrary.simpleMessage(
      "Terms and Conditions of Sale",
    ),
    "buttonEmphasis": MessageLookupByLibrary.simpleMessage("Button Emphasis"),
    "buttons": m1,
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "catalogAddToCatalog": MessageLookupByLibrary.simpleMessage(
      "Add to catalog",
    ),
    "catalogAllCategories": MessageLookupByLibrary.simpleMessage("All"),
    "catalogAlreadyInCatalog": MessageLookupByLibrary.simpleMessage(
      "Already in catalog",
    ),
    "catalogClearSelection": MessageLookupByLibrary.simpleMessage("Clear"),
    "catalogColumnBarcode": MessageLookupByLibrary.simpleMessage("Code barre"),
    "catalogColumnDesignation": MessageLookupByLibrary.simpleMessage(
      "Désignation",
    ),
    "catalogColumnKind": MessageLookupByLibrary.simpleMessage("Type"),
    "catalogColumnPrice": MessageLookupByLibrary.simpleMessage("Prix de vente"),
    "catalogColumnStatus": MessageLookupByLibrary.simpleMessage("Statut"),
    "catalogColumnTitle": MessageLookupByLibrary.simpleMessage("Libellé"),
    "catalogCost": MessageLookupByLibrary.simpleMessage("Coût d\'achat"),
    "catalogDiscoverySubtitle": MessageLookupByLibrary.simpleMessage(
      "Pick the FMCG products you sell, adjust price and cost, then add them to your chain catalog.",
    ),
    "catalogEditProduct": MessageLookupByLibrary.simpleMessage(
      "Modifier l\'article",
    ),
    "catalogEnterPrice": MessageLookupByLibrary.simpleMessage(
      "Saisir le prix de vente",
    ),
    "catalogEnterTitle": MessageLookupByLibrary.simpleMessage(
      "Saisir le libellé",
    ),
    "catalogIdentity": MessageLookupByLibrary.simpleMessage("Caractéristiques"),
    "catalogInvalidNumber": MessageLookupByLibrary.simpleMessage("erreur"),
    "catalogInvalidUnits": MessageLookupByLibrary.simpleMessage(
      "exemple : 1.5 et non pas 1,5",
    ),
    "catalogNewProduct": MessageLookupByLibrary.simpleMessage(
      "Créer un article",
    ),
    "catalogNoProductsMatch": MessageLookupByLibrary.simpleMessage(
      "No products match your search.",
    ),
    "catalogPick": MessageLookupByLibrary.simpleMessage("Pick"),
    "catalogPicked": MessageLookupByLibrary.simpleMessage("Picked"),
    "catalogPrice": MessageLookupByLibrary.simpleMessage("Price"),
    "catalogRemove": MessageLookupByLibrary.simpleMessage("Remove"),
    "catalogSelectChain": MessageLookupByLibrary.simpleMessage("Chain"),
    "catalogSelectionEmpty": MessageLookupByLibrary.simpleMessage(
      "Pick products from the grid to build your catalog.",
    ),
    "catalogSelectionTitle": m2,
    "catalogSelling": MessageLookupByLibrary.simpleMessage("Vente"),
    "catalogStockUnit": MessageLookupByLibrary.simpleMessage("Unité de compte"),
    "catalogTitleTaken": MessageLookupByLibrary.simpleMessage(
      "Un article avec ce libellé existe déjà",
    ),
    "catalogUnitsInOnePiece": MessageLookupByLibrary.simpleMessage(
      "Unités/article",
    ),
    "catalogVariants": MessageLookupByLibrary.simpleMessage("Sous-articles"),
    "changeProfilePhoto": MessageLookupByLibrary.simpleMessage("Change photo"),
    "closeNavigationMenu": MessageLookupByLibrary.simpleMessage(
      "Close Navigation Menu",
    ),
    "colorPalette": MessageLookupByLibrary.simpleMessage("Color Palette"),
    "colorScheme": MessageLookupByLibrary.simpleMessage("Color Scheme"),
    "colors": m3,
    "confirmDeleteRecord": MessageLookupByLibrary.simpleMessage(
      "Confirm delete this record?",
    ),
    "confirmSubmitRecord": MessageLookupByLibrary.simpleMessage(
      "Confirm submit this record?",
    ),
    "contactAddress": MessageLookupByLibrary.simpleMessage("Adresse"),
    "contactCity": MessageLookupByLibrary.simpleMessage("Ville"),
    "contactCountry": MessageLookupByLibrary.simpleMessage("Pays"),
    "contactDetails": MessageLookupByLibrary.simpleMessage("Détails"),
    "contactEdit": MessageLookupByLibrary.simpleMessage("Modifier le contact"),
    "contactEmailInvalid": MessageLookupByLibrary.simpleMessage(
      "L\'adresse mail n\'est pas correcte",
    ),
    "contactEnterFirstName": MessageLookupByLibrary.simpleMessage(
      "Saisir le prénom",
    ),
    "contactEnterLastName": MessageLookupByLibrary.simpleMessage(
      "Saisir le nom de famille",
    ),
    "contactFirstName": MessageLookupByLibrary.simpleMessage("Prénom"),
    "contactIsClient": MessageLookupByLibrary.simpleMessage("Client"),
    "contactIsSupplier": MessageLookupByLibrary.simpleMessage("Fournisseur"),
    "contactLastName": MessageLookupByLibrary.simpleMessage("Nom de famille"),
    "contactMail": MessageLookupByLibrary.simpleMessage("Mail"),
    "contactNew": MessageLookupByLibrary.simpleMessage("Créer un contact"),
    "contactOverdraft": MessageLookupByLibrary.simpleMessage("Crédit maximum"),
    "contactPhone": MessageLookupByLibrary.simpleMessage("Téléphone"),
    "contactPhoneTooShort": MessageLookupByLibrary.simpleMessage(
      "Le numéro doit comporter au moins 8 chiffres",
    ),
    "contactPostCode": MessageLookupByLibrary.simpleMessage("Code postal"),
    "contactStreet": MessageLookupByLibrary.simpleMessage("Rue"),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "createEnterpriseErrorPrefix": MessageLookupByLibrary.simpleMessage(
      "Error while creating the enterprise: ",
    ),
    "createEnterprisePageTitle": MessageLookupByLibrary.simpleMessage(
      "Create an enterprise",
    ),
    "createEnterpriseSuccessTitle": m4,
    "creditCardErrorText": MessageLookupByLibrary.simpleMessage(
      "This field requires a valid credit card number.",
    ),
    "crudBack": MessageLookupByLibrary.simpleMessage("Back"),
    "crudDelete": MessageLookupByLibrary.simpleMessage("Delete"),
    "crudDetail": MessageLookupByLibrary.simpleMessage("Detail"),
    "crudNew": MessageLookupByLibrary.simpleMessage("New"),
    "darkTheme": MessageLookupByLibrary.simpleMessage("Dark Theme"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "dashboardCardBoutiquesValue": MessageLookupByLibrary.simpleMessage(
      "My stores",
    ),
    "dashboardCardDevicesValue": MessageLookupByLibrary.simpleMessage(
      "Devices",
    ),
    "dashboardCardMyFirmValue": MessageLookupByLibrary.simpleMessage(
      "My enterprise",
    ),
    "dashboardCardTicketsShort": MessageLookupByLibrary.simpleMessage(
      "Tickets",
    ),
    "dashboardCardTicketsToday": MessageLookupByLibrary.simpleMessage(
      "Today\'s tickets",
    ),
    "dashboardCardUserAccess": MessageLookupByLibrary.simpleMessage(
      "User access",
    ),
    "dashboardCardUsersValue": MessageLookupByLibrary.simpleMessage("Users"),
    "dateStringErrorText": MessageLookupByLibrary.simpleMessage(
      "This field requires a valid date string.",
    ),
    "dialogs": m5,
    "dontHaveAnAccount": MessageLookupByLibrary.simpleMessage(
      "Don\'t have an account?",
    ),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "emailErrorText": MessageLookupByLibrary.simpleMessage(
      "This field requires a valid email address.",
    ),
    "enterpriseNameFieldHint": MessageLookupByLibrary.simpleMessage(
      "Enterprise name",
    ),
    "enterpriseNameFieldLabel": MessageLookupByLibrary.simpleMessage(
      "Enterprise",
    ),
    "entityAddSku": MessageLookupByLibrary.simpleMessage(
      "Ajouter un sous-article",
    ),
    "entityConfirmDelete": MessageLookupByLibrary.simpleMessage(
      "Supprimer cet enregistrement ?",
    ),
    "entityCreate": MessageLookupByLibrary.simpleMessage("Créer"),
    "entityDelete": MessageLookupByLibrary.simpleMessage("Supprimer"),
    "entityEdit": MessageLookupByLibrary.simpleMessage("Modifier"),
    "entityEmptyHint": MessageLookupByLibrary.simpleMessage(
      "Cliquez sur + pour créer un enregistrement.",
    ),
    "equalErrorText": m6,
    "error404": MessageLookupByLibrary.simpleMessage("Error 404"),
    "error404Message": MessageLookupByLibrary.simpleMessage(
      "Sorry, the page you are looking for has been removed or not exists.",
    ),
    "error404Title": MessageLookupByLibrary.simpleMessage("Page not found"),
    "example": MessageLookupByLibrary.simpleMessage("Example"),
    "extensions": m7,
    "firmCardDescription": MessageLookupByLibrary.simpleMessage(
      "Your enterprise groups your users and your store chains.",
    ),
    "firmCreatedAtLabel": MessageLookupByLibrary.simpleMessage("Created on"),
    "firmCurrencyLabel": MessageLookupByLibrary.simpleMessage(
      "Default currency",
    ),
    "firmDualCurrencyLabel": MessageLookupByLibrary.simpleMessage(
      "Dual currency",
    ),
    "firmEmailVerifiedLabel": MessageLookupByLibrary.simpleMessage(
      "Email verified",
    ),
    "firmErrorCreateHint": MessageLookupByLibrary.simpleMessage(
      "Please create a new enterprise by clicking the \"Add an enterprise\" button.",
    ),
    "firmErrorUnexpected": MessageLookupByLibrary.simpleMessage(
      "An unexpected error occurred.",
    ),
    "firmIdLabel": MessageLookupByLibrary.simpleMessage("Enterprise ID"),
    "firmNameLabel": MessageLookupByLibrary.simpleMessage("Name"),
    "firmPageTitle": MessageLookupByLibrary.simpleMessage("My enterprise"),
    "firmSecondaryCurrencyLabel": MessageLookupByLibrary.simpleMessage(
      "Secondary currency",
    ),
    "firmStatusActive": MessageLookupByLibrary.simpleMessage("Active"),
    "firmStatusInactive": MessageLookupByLibrary.simpleMessage("Inactive"),
    "firmStatusLabel": MessageLookupByLibrary.simpleMessage("Status"),
    "firstName": MessageLookupByLibrary.simpleMessage("First Name"),
    "forgotPassword": MessageLookupByLibrary.simpleMessage("Forgot password?"),
    "forgotPasswordMessage": MessageLookupByLibrary.simpleMessage(
      "Enter your email address to reset your password.",
    ),
    "forgotPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Forgot password",
    ),
    "forms": m8,
    "generalUi": MessageLookupByLibrary.simpleMessage("General UI"),
    "help": MessageLookupByLibrary.simpleMessage("Help"),
    "helpReadFaq": MessageLookupByLibrary.simpleMessage("Read the FAQ"),
    "helpResourcesTitle": MessageLookupByLibrary.simpleMessage("Resources"),
    "helpScopeBody": MessageLookupByLibrary.simpleMessage(
      "The web console lets you manage tickets (view, filter, search). Articles, contacts and operations (sales, purchases, stock movements, etc.) are available in the mobile app for now.",
    ),
    "helpScopeBodyDev": MessageLookupByLibrary.simpleMessage(
      "The web console lets you manage tickets (view, filter, search) and discover prepared catalog products to set up your POS. Contacts and operations (sales, purchases, stock movements, etc.) remain available in the mobile app for now.",
    ),
    "helpScopeTitle": MessageLookupByLibrary.simpleMessage(
      "What can I do from the web console?",
    ),
    "helpWatchDemos": MessageLookupByLibrary.simpleMessage("Watch video demos"),
    "hi": MessageLookupByLibrary.simpleMessage("Hi"),
    "homePage": MessageLookupByLibrary.simpleMessage("Home"),
    "iframeDemo": MessageLookupByLibrary.simpleMessage("IFrame Demo"),
    "integerErrorText": MessageLookupByLibrary.simpleMessage(
      "This field requires a valid integer.",
    ),
    "ipErrorText": MessageLookupByLibrary.simpleMessage(
      "This field requires a valid IP.",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "lastName": MessageLookupByLibrary.simpleMessage("Last Name"),
    "legalDocTitleCgvAccountingReportFr": MessageLookupByLibrary.simpleMessage(
      "Terms and Conditions of Sale - Cash Report",
    ),
    "legalDocTitleCgvFr": MessageLookupByLibrary.simpleMessage(
      "Conditions Générales de Vente",
    ),
    "legalDocTitleTermsEn": MessageLookupByLibrary.simpleMessage(
      "Terms and Conditions of Sale",
    ),
    "legalDocumentVersionId": MessageLookupByLibrary.simpleMessage(
      "Document version ID",
    ),
    "lightTheme": MessageLookupByLibrary.simpleMessage("Light Theme"),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "loginNow": MessageLookupByLibrary.simpleMessage("Login now!"),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "loremIpsum": MessageLookupByLibrary.simpleMessage(
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
    ),
    "mail": MessageLookupByLibrary.simpleMessage("E-mail"),
    "matchErrorText": MessageLookupByLibrary.simpleMessage(
      "Value does not match pattern.",
    ),
    "maxErrorText": m9,
    "maxLengthErrorText": m10,
    "menuAccesses": MessageLookupByLibrary.simpleMessage("Accesses"),
    "menuBilling": MessageLookupByLibrary.simpleMessage("Weebi offers"),
    "menuBoutiques": MessageLookupByLibrary.simpleMessage("My Boutiques"),
    "menuCatalog": MessageLookupByLibrary.simpleMessage("Articles"),
    "menuContacts": MessageLookupByLibrary.simpleMessage("Contacts"),
    "menuDevices": MessageLookupByLibrary.simpleMessage("Devices"),
    "menuFirm": MessageLookupByLibrary.simpleMessage("My enterprise"),
    "menuScopeDisclaimer": MessageLookupByLibrary.simpleMessage(
      "Articles, contacts and operations (sales, purchases, stock movements, etc.) are available in the mobile app for now.",
    ),
    "menuScopeDisclaimerDev": MessageLookupByLibrary.simpleMessage(
      "Contacts and operations (sales, purchases, stock movements, etc.) are available in the mobile app for now. Catalog discovery and tickets are available here.",
    ),
    "menuStats": MessageLookupByLibrary.simpleMessage("Statistics"),
    "menuTickets": MessageLookupByLibrary.simpleMessage("Tickets"),
    "menuUsers": MessageLookupByLibrary.simpleMessage("Users"),
    "minErrorText": m11,
    "minLengthErrorText": m12,
    "myProfile": MessageLookupByLibrary.simpleMessage("My Profile"),
    "newOrders": m13,
    "newUsers": m14,
    "notEqualErrorText": m15,
    "numericErrorText": MessageLookupByLibrary.simpleMessage(
      "Value must be numeric.",
    ),
    "openInNewTab": MessageLookupByLibrary.simpleMessage("Open in new tab"),
    "operationalLicenseBlockedBody": MessageLookupByLibrary.simpleMessage(
      "Your enterprise administrator must assign you an active license seat, or you need to sign in as the user who created the enterprise, before you can use tickets, articles, or contacts. Open Billing if you manage licenses.",
    ),
    "operationalLicenseBlockedTitle": MessageLookupByLibrary.simpleMessage(
      "Active license required",
    ),
    "operationalLicenseOpenBilling": MessageLookupByLibrary.simpleMessage(
      "Billing",
    ),
    "operationalLicenseRetry": MessageLookupByLibrary.simpleMessage(
      "Try again",
    ),
    "pages": m16,
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordNotMatch": MessageLookupByLibrary.simpleMessage(
      "Password not match.",
    ),
    "passwordResetEmailSent": MessageLookupByLibrary.simpleMessage(
      "Password reset email sent.",
    ),
    "pendingIssues": m17,
    "recentOrders": m18,
    "recordDeletedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Record deleted successfully.",
    ),
    "recordSavedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Record saved successfully.",
    ),
    "recordSubmittedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Record submitted successfully.",
    ),
    "refreshAction": MessageLookupByLibrary.simpleMessage("Refresh"),
    "register": MessageLookupByLibrary.simpleMessage("Register"),
    "registerANewAccount": MessageLookupByLibrary.simpleMessage(
      "Register a new account",
    ),
    "registerNow": MessageLookupByLibrary.simpleMessage("Register now!"),
    "requiredErrorText": MessageLookupByLibrary.simpleMessage(
      "This field cannot be empty.",
    ),
    "retypePassword": MessageLookupByLibrary.simpleMessage("Retype Password"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "statsAll": MessageLookupByLibrary.simpleMessage("All"),
    "statsMetricAllIncome": MessageLookupByLibrary.simpleMessage("All Income"),
    "statsMetricAllSpending": MessageLookupByLibrary.simpleMessage(
      "All Spending",
    ),
    "statsMetricCashflowIncome": MessageLookupByLibrary.simpleMessage(
      "Cashflow Income",
    ),
    "statsMetricCashflowSpending": MessageLookupByLibrary.simpleMessage(
      "Cashflow Spending",
    ),
    "statsNoAccess": MessageLookupByLibrary.simpleMessage(
      "You don\'t have permission to view statistics. Ask your enterprise administrator to grant you access.",
    ),
    "statsNoDataAvailable": MessageLookupByLibrary.simpleMessage(
      "No data available",
    ),
    "statsPeriodDay": MessageLookupByLibrary.simpleMessage("Day"),
    "statsPeriodMonth": MessageLookupByLibrary.simpleMessage("Month"),
    "statsPeriodWeek": MessageLookupByLibrary.simpleMessage("Week"),
    "statsSelectBoutiques": MessageLookupByLibrary.simpleMessage(
      "Select Boutiques:",
    ),
    "statsStackedByBoutique": MessageLookupByLibrary.simpleMessage(
      "Stacked by Boutique",
    ),
    "statusActive": MessageLookupByLibrary.simpleMessage("Active"),
    "statusAll": MessageLookupByLibrary.simpleMessage("All"),
    "statusInactive": MessageLookupByLibrary.simpleMessage("Inactive"),
    "stayConnected": MessageLookupByLibrary.simpleMessage("Stay connected"),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "support": MessageLookupByLibrary.simpleMessage("Support"),
    "supportChatWhatsApp": MessageLookupByLibrary.simpleMessage(
      "Chat with Weebi support",
    ),
    "supportEmailUs": MessageLookupByLibrary.simpleMessage("Send us an email"),
    "text": MessageLookupByLibrary.simpleMessage("Text"),
    "textEmphasis": MessageLookupByLibrary.simpleMessage("Text Emphasis"),
    "textTheme": MessageLookupByLibrary.simpleMessage("Text Theme"),
    "ticketDetailTitle": m19,
    "ticketItemsShort": m20,
    "ticketNotProvided": MessageLookupByLibrary.simpleMessage(
      "No ticket provided",
    ),
    "ticketTypeDefault": MessageLookupByLibrary.simpleMessage("Ticket"),
    "ticketsBoutiqueAll": MessageLookupByLibrary.simpleMessage("All stores"),
    "ticketsBoutiqueFallback": MessageLookupByLibrary.simpleMessage("Store"),
    "ticketsChainUnavailable": MessageLookupByLibrary.simpleMessage(
      "Chain unavailable",
    ),
    "ticketsColumnAmount": MessageLookupByLibrary.simpleMessage("Amount"),
    "ticketsColumnBoutique": MessageLookupByLibrary.simpleMessage("Store"),
    "ticketsColumnContact": MessageLookupByLibrary.simpleMessage("Contact"),
    "ticketsColumnDateAndNumber": MessageLookupByLibrary.simpleMessage(
      "Date · no.",
    ),
    "ticketsColumnType": MessageLookupByLibrary.simpleMessage("Type"),
    "ticketsCount": m21,
    "ticketsDateAll": MessageLookupByLibrary.simpleMessage("All dates"),
    "ticketsDeletedChip": MessageLookupByLibrary.simpleMessage("Deleted"),
    "ticketsDeletedExclude": MessageLookupByLibrary.simpleMessage(
      "Not deleted",
    ),
    "ticketsDeletedOnly": MessageLookupByLibrary.simpleMessage("Deleted only"),
    "ticketsEmpty": MessageLookupByLibrary.simpleMessage("No tickets"),
    "ticketsFiltersTitle": MessageLookupByLibrary.simpleMessage("Filters"),
    "ticketsGroupByBoutique": MessageLookupByLibrary.simpleMessage(
      "Group by store",
    ),
    "ticketsPaymentCard": MessageLookupByLibrary.simpleMessage("Card"),
    "ticketsPaymentCash": MessageLookupByLibrary.simpleMessage("Cash"),
    "ticketsPaymentCheque": MessageLookupByLibrary.simpleMessage("Check"),
    "ticketsPaymentCredit": MessageLookupByLibrary.simpleMessage("Credit"),
    "ticketsPaymentGoods": MessageLookupByLibrary.simpleMessage("Goods"),
    "ticketsPaymentMobileMoney": MessageLookupByLibrary.simpleMessage(
      "Mobile money",
    ),
    "ticketsPaymentUnknown": MessageLookupByLibrary.simpleMessage("—"),
    "ticketsSeatEntitlementSubtitle": MessageLookupByLibrary.simpleMessage(
      "Active license seat required",
    ),
    "ticketsSeatGatedBoutiqueViewsDetail": MessageLookupByLibrary.simpleMessage(
      "Store filter and grouping require an active license seat. The firm creator can use core sync without a seat; these views are for seated team members. Open Billing or ask your administrator to assign you a seat.",
    ),
    "ticketsSeatGatedBoutiqueViewsTitle": MessageLookupByLibrary.simpleMessage(
      "Store filter & grouping",
    ),
    "ticketsSortChronological": MessageLookupByLibrary.simpleMessage(
      "Chronological order",
    ),
    "ticketsStatusActive": MessageLookupByLibrary.simpleMessage("Active"),
    "ticketsStatusAll": MessageLookupByLibrary.simpleMessage("All"),
    "ticketsStatusInactive": MessageLookupByLibrary.simpleMessage("Inactive"),
    "ticketsTooltipClearDates": MessageLookupByLibrary.simpleMessage(
      "All dates",
    ),
    "ticketsTooltipFilterBoutique": MessageLookupByLibrary.simpleMessage(
      "Filter by store",
    ),
    "ticketsTooltipFilterByStatus": MessageLookupByLibrary.simpleMessage(
      "Filter by status",
    ),
    "ticketsTooltipFilterDeleted": MessageLookupByLibrary.simpleMessage(
      "Filter by deleted tickets",
    ),
    "ticketsTooltipRefresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "todaySales": MessageLookupByLibrary.simpleMessage("Today Sales"),
    "typography": MessageLookupByLibrary.simpleMessage("Typography"),
    "uiElements": m22,
    "urlErrorText": MessageLookupByLibrary.simpleMessage(
      "This field requires a valid URL address.",
    ),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
  };
}
