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

  static String m0(count) =>
      "${Intl.plural(count, one: 'Button', other: 'Buttons')}";

  static String m1(count) =>
      "${Intl.plural(count, one: 'Color', other: 'Colors')}";

  static String m2(name) =>
      "The enterprise \"${name}\" was created successfully.";

  static String m3(count) =>
      "${Intl.plural(count, one: 'Dialog', other: 'Dialogs')}";

  static String m4(value) => "This field value must be equal to ${value}.";

  static String m5(count) =>
      "${Intl.plural(count, one: 'Extension', other: 'Extensions')}";

  static String m6(count) =>
      "${Intl.plural(count, one: 'Form', other: 'Forms')}";

  static String m7(max) => "Value must be less than or equal to ${max}";

  static String m8(maxLength) =>
      "Value must have a length less than or equal to ${maxLength}";

  static String m9(min) => "Value must be greater than or equal to ${min}.";

  static String m10(minLength) =>
      "Value must have a length greater than or equal to ${minLength}";

  static String m11(count) =>
      "${Intl.plural(count, one: 'New Order', other: 'New Orders')}";

  static String m12(count) =>
      "${Intl.plural(count, one: 'New User', other: 'New Users')}";

  static String m13(value) => "This field value must not be equal to ${value}.";

  static String m14(count) =>
      "${Intl.plural(count, one: 'Page', other: 'Pages')}";

  static String m15(count) =>
      "${Intl.plural(count, one: 'Pending Issue', other: 'Pending Issues')}";

  static String m16(count) =>
      "${Intl.plural(count, one: 'Recent Order', other: 'Recent Orders')}";

  static String m17(ticketId) => "Ticket detail #${ticketId}";

  static String m18(count) => "${count} items";

  static String m19(count) =>
      "${Intl.plural(count, one: '# ticket', other: '# tickets')}";

  static String m20(count) =>
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
    "billingLicenses": MessageLookupByLibrary.simpleMessage("License(s)"),
    "billingLifetime": MessageLookupByLibrary.simpleMessage("Lifetime"),
    "billingMyLicenses": MessageLookupByLibrary.simpleMessage("My licenses"),
    "billingNoAccess": MessageLookupByLibrary.simpleMessage(
      "You don\'t have permission to manage licenses. Ask your enterprise administrator to grant you billing access.",
    ),
    "billingNoUsersAvailable": MessageLookupByLibrary.simpleMessage(
      "No users to assign. Add users in Users first.",
    ),
    "billingNotYetAttributed": MessageLookupByLibrary.simpleMessage(
      "Not yet attributed",
    ),
    "billingPaymentProcessing": MessageLookupByLibrary.simpleMessage(
      "Payment received. We\'re confirming with Stripe — your license(s) will appear shortly; you can then assign seats to users. If they don\'t appear, check your webhook configuration.",
    ),
    "billingPaymentSuccess": MessageLookupByLibrary.simpleMessage(
      "Payment accepted. One or more licenses were purchased successfully: you can assign seats to the relevant users.",
    ),
    "billingPurchase": MessageLookupByLibrary.simpleMessage("Purchase"),
    "billingPurchaseLicense": MessageLookupByLibrary.simpleMessage(
      "Purchase a license",
    ),
    "billingPurchaseLicenseDescription": MessageLookupByLibrary.simpleMessage(
      "Choose a license to unlock Weebi\'s advanced features. Each seat is a one-time purchase: it does not expire, and this is not a subscription—no renewals, no ticking clock.",
    ),
    "billingReassignNoOtherUser": MessageLookupByLibrary.simpleMessage(
      "No other user can receive this seat. Add a user or free a license seat elsewhere first.",
    ),
    "billingReassignSeat": MessageLookupByLibrary.simpleMessage("Reassign"),
    "billingReassignSeatDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Reassign this license seat to another user",
    ),
    "billingRetry": MessageLookupByLibrary.simpleMessage("Retry"),
    "billingSeatsAttributed": MessageLookupByLibrary.simpleMessage(
      "license(s) attributed",
    ),
    "billingUsers": MessageLookupByLibrary.simpleMessage("users"),
    "billingValidUntil": MessageLookupByLibrary.simpleMessage("Valid until"),
    "billingViewFullTerms": MessageLookupByLibrary.simpleMessage(
      "Terms and Conditions of Sale",
    ),
    "billingPlanEntreprise": MessageLookupByLibrary.simpleMessage(
      "Weebi Entreprise",
    ),
    "billingPlanPremium": MessageLookupByLibrary.simpleMessage(
      "Weebi Premium",
    ),
    "billingPerUser": MessageLookupByLibrary.simpleMessage("per user"),
    "buttonEmphasis": MessageLookupByLibrary.simpleMessage("Button Emphasis"),
    "buttons": m0,
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "changeProfilePhoto": MessageLookupByLibrary.simpleMessage("Change photo"),
    "closeNavigationMenu": MessageLookupByLibrary.simpleMessage(
      "Close Navigation Menu",
    ),
    "colorPalette": MessageLookupByLibrary.simpleMessage("Color Palette"),
    "colorScheme": MessageLookupByLibrary.simpleMessage("Color Scheme"),
    "colors": m1,
    "confirmDeleteRecord": MessageLookupByLibrary.simpleMessage(
      "Confirm delete this record?",
    ),
    "confirmSubmitRecord": MessageLookupByLibrary.simpleMessage(
      "Confirm submit this record?",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "createEnterpriseErrorPrefix": MessageLookupByLibrary.simpleMessage(
      "Error while creating the enterprise: ",
    ),
    "createEnterprisePageTitle": MessageLookupByLibrary.simpleMessage(
      "Create an enterprise",
    ),
    "createEnterpriseSuccessTitle": m2,
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
    "dialogs": m3,
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
    "equalErrorText": m4,
    "error404": MessageLookupByLibrary.simpleMessage("Error 404"),
    "error404Message": MessageLookupByLibrary.simpleMessage(
      "Sorry, the page you are looking for has been removed or not exists.",
    ),
    "error404Title": MessageLookupByLibrary.simpleMessage("Page not found"),
    "example": MessageLookupByLibrary.simpleMessage("Example"),
    "extensions": m5,
    "firmCardDescription": MessageLookupByLibrary.simpleMessage(
      "Your enterprise groups your users and your store chains.",
    ),
    "firmErrorCreateHint": MessageLookupByLibrary.simpleMessage(
      "Please create a new enterprise by clicking the \"Add an enterprise\" button.",
    ),
    "firmErrorUnexpected": MessageLookupByLibrary.simpleMessage(
      "An unexpected error occurred.",
    ),
    "firmPageTitle": MessageLookupByLibrary.simpleMessage("My enterprise"),
    "firstName": MessageLookupByLibrary.simpleMessage("First Name"),
    "forgotPassword": MessageLookupByLibrary.simpleMessage("Forgot password?"),
    "forgotPasswordMessage": MessageLookupByLibrary.simpleMessage(
      "Enter your email address to reset your password.",
    ),
    "forgotPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Forgot password",
    ),
    "forms": m6,
    "generalUi": MessageLookupByLibrary.simpleMessage("General UI"),
    "help": MessageLookupByLibrary.simpleMessage("Help"),
    "helpReadFaq": MessageLookupByLibrary.simpleMessage("Read the FAQ"),
    "helpResourcesTitle": MessageLookupByLibrary.simpleMessage("Resources"),
    "helpScopeBody": MessageLookupByLibrary.simpleMessage(
      "The web console lets you manage tickets (view, filter, search). Articles, contacts and operations (sales, purchases, stock movements, etc.) are available in the mobile app for now.",
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
    "maxErrorText": m7,
    "maxLengthErrorText": m8,
    "menuAccesses": MessageLookupByLibrary.simpleMessage("Accesses"),
    "menuBilling": MessageLookupByLibrary.simpleMessage("Weebi licenses"),
    "menuBoutiques": MessageLookupByLibrary.simpleMessage("My Boutiques"),
    "menuDevices": MessageLookupByLibrary.simpleMessage("Devices"),
    "menuFirm": MessageLookupByLibrary.simpleMessage("My enterprise"),
    "menuScopeDisclaimer": MessageLookupByLibrary.simpleMessage(
      "Articles, contacts and operations (sales, purchases, stock movements, etc.) are available in the mobile app for now.",
    ),
    "menuTickets": MessageLookupByLibrary.simpleMessage("Tickets"),
    "menuUsers": MessageLookupByLibrary.simpleMessage("Users"),
    "minErrorText": m9,
    "minLengthErrorText": m10,
    "myProfile": MessageLookupByLibrary.simpleMessage("My Profile"),
    "newOrders": m11,
    "newUsers": m12,
    "notEqualErrorText": m13,
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
    "pages": m14,
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordNotMatch": MessageLookupByLibrary.simpleMessage(
      "Password not match.",
    ),
    "pendingIssues": m15,
    "recentOrders": m16,
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
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "support": MessageLookupByLibrary.simpleMessage("Support"),
    "supportChatWhatsApp": MessageLookupByLibrary.simpleMessage(
      "Chat with Weebi support",
    ),
    "supportEmailUs": MessageLookupByLibrary.simpleMessage("Send us an email"),
    "text": MessageLookupByLibrary.simpleMessage("Text"),
    "textEmphasis": MessageLookupByLibrary.simpleMessage("Text Emphasis"),
    "textTheme": MessageLookupByLibrary.simpleMessage("Text Theme"),
    "ticketDetailTitle": m17,
    "ticketItemsShort": m18,
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
    "ticketsCount": m19,
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
    "uiElements": m20,
    "urlErrorText": MessageLookupByLibrary.simpleMessage(
      "This field requires a valid URL address.",
    ),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
  };
}
