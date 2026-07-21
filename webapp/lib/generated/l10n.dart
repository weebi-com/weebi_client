// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class Lang {
  Lang();

  static Lang? _current;

  static Lang get current {
    assert(
      _current != null,
      'No instance of Lang was loaded. Try to initialize the Lang delegate before accessing Lang.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<Lang> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = Lang();
      Lang._current = instance;

      return instance;
    });
  }

  static Lang of(BuildContext context) {
    final instance = Lang.maybeOf(context);
    assert(
      instance != null,
      'No instance of Lang present in the widget tree. Did you add Lang.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static Lang? maybeOf(BuildContext context) {
    return Localizations.of<Lang>(context, Lang);
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `Blog`
  String get aboutBlog {
    return Intl.message('Blog', name: 'aboutBlog', desc: '', args: []);
  }

  /// `Historical Partners`
  String get aboutPartners {
    return Intl.message(
      'Historical Partners',
      name: 'aboutPartners',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `Admin Portal Login`
  String get adminPortalLogin {
    return Intl.message(
      'Admin Portal Login',
      name: 'adminPortalLogin',
      desc: '',
      args: [],
    );
  }

  /// `Back to Login`
  String get backToLogin {
    return Intl.message(
      'Back to Login',
      name: 'backToLogin',
      desc: '',
      args: [],
    );
  }

  /// `I have read and accept the Terms and Conditions of Sale for the Enterprise license.`
  String get billingAcceptEnterpriseTerms {
    return Intl.message(
      'I have read and accept the Terms and Conditions of Sale for the Enterprise license.',
      name: 'billingAcceptEnterpriseTerms',
      desc: '',
      args: [],
    );
  }

  /// `Please accept the terms and conditions to continue.`
  String get billingAcceptTermsToContinue {
    return Intl.message(
      'Please accept the terms and conditions to continue.',
      name: 'billingAcceptTermsToContinue',
      desc: '',
      args: [],
    );
  }

  /// `All users already have a license assigned.`
  String get billingAllUsersAlreadyAssigned {
    return Intl.message(
      'All users already have a license assigned.',
      name: 'billingAllUsersAlreadyAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Assign the license to a user`
  String get billingAssignSeatDialogTitle {
    return Intl.message(
      'Assign the license to a user',
      name: 'billingAssignSeatDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Assign the license to a user`
  String get billingAssignSeats {
    return Intl.message(
      'Assign the license to a user',
      name: 'billingAssignSeats',
      desc: '',
      args: [],
    );
  }

  /// `Assign your new licenses to users below.`
  String get billingAssignSeatsCta {
    return Intl.message(
      'Assign your new licenses to users below.',
      name: 'billingAssignSeatsCta',
      desc: '',
      args: [],
    );
  }

  /// `Attributed to`
  String get billingAttributedTo {
    return Intl.message(
      'Attributed to',
      name: 'billingAttributedTo',
      desc: '',
      args: [],
    );
  }

  /// `License(s)`
  String get billingLicenses {
    return Intl.message(
      'License(s)',
      name: 'billingLicenses',
      desc: '',
      args: [],
    );
  }

  /// `Lifetime`
  String get billingLifetime {
    return Intl.message(
      'Lifetime',
      name: 'billingLifetime',
      desc: '',
      args: [],
    );
  }

  /// `My licenses`
  String get billingMyLicenses {
    return Intl.message(
      'My licenses',
      name: 'billingMyLicenses',
      desc: '',
      args: [],
    );
  }

  /// `Not yet attributed`
  String get billingNotYetAttributed {
    return Intl.message(
      'Not yet attributed',
      name: 'billingNotYetAttributed',
      desc: '',
      args: [],
    );
  }

  /// `No users to assign. Add users in Users first.`
  String get billingNoUsersAvailable {
    return Intl.message(
      'No users to assign. Add users in Users first.',
      name: 'billingNoUsersAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Payment received. We're confirming with Stripe — your license(s) will appear shortly; you can then assign seats to users. If they don't appear, check your webhook configuration.`
  String get billingPaymentProcessing {
    return Intl.message(
      'Payment received. We\'re confirming with Stripe — your license(s) will appear shortly; you can then assign seats to users. If they don\'t appear, check your webhook configuration.',
      name: 'billingPaymentProcessing',
      desc: '',
      args: [],
    );
  }

  /// `Payment accepted. One or more licenses were purchased successfully: you can assign seats to the relevant users.`
  String get billingPaymentSuccess {
    return Intl.message(
      'Payment accepted. One or more licenses were purchased successfully: you can assign seats to the relevant users.',
      name: 'billingPaymentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Purchase`
  String get billingPurchase {
    return Intl.message(
      'Purchase',
      name: 'billingPurchase',
      desc: '',
      args: [],
    );
  }

  /// `Purchase a license`
  String get billingPurchaseLicense {
    return Intl.message(
      'Purchase a license',
      name: 'billingPurchaseLicense',
      desc: '',
      args: [],
    );
  }

  /// `Choose a license to unlock Weebi's advanced features. Each seat is a one-time purchase: it does not expire, and this is not a subscription—no renewals, no ticking clock.`
  String get billingPurchaseLicenseDescription {
    return Intl.message(
      'Choose a license to unlock Weebi\'s advanced features. Each seat is a one-time purchase: it does not expire, and this is not a subscription—no renewals, no ticking clock.',
      name: 'billingPurchaseLicenseDescription',
      desc: '',
      args: [],
    );
  }

  /// `No other user can receive this seat. Add a user or free a license seat elsewhere first.`
  String get billingReassignNoOtherUser {
    return Intl.message(
      'No other user can receive this seat. Add a user or free a license seat elsewhere first.',
      name: 'billingReassignNoOtherUser',
      desc: '',
      args: [],
    );
  }

  /// `Reassign`
  String get billingReassignSeat {
    return Intl.message(
      'Reassign',
      name: 'billingReassignSeat',
      desc: '',
      args: [],
    );
  }

  /// `Reassign this license seat to another user`
  String get billingReassignSeatDialogTitle {
    return Intl.message(
      'Reassign this license seat to another user',
      name: 'billingReassignSeatDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get billingRetry {
    return Intl.message('Retry', name: 'billingRetry', desc: '', args: []);
  }

  /// `license(s) attributed`
  String get billingSeatsAttributed {
    return Intl.message(
      'license(s) attributed',
      name: 'billingSeatsAttributed',
      desc: '',
      args: [],
    );
  }

  /// `users`
  String get billingUsers {
    return Intl.message('users', name: 'billingUsers', desc: '', args: []);
  }

  /// `Valid until`
  String get billingValidUntil {
    return Intl.message(
      'Valid until',
      name: 'billingValidUntil',
      desc: '',
      args: [],
    );
  }

  /// `Terms and Conditions of Sale`
  String get billingViewFullTerms {
    return Intl.message(
      'Terms and Conditions of Sale',
      name: 'billingViewFullTerms',
      desc: '',
      args: [],
    );
  }

  /// `Weebi Entreprise`
  String get billingPlanEntreprise {
    return Intl.message(
      'Weebi Entreprise',
      name: 'billingPlanEntreprise',
      desc: '',
      args: [],
    );
  }

  /// `Weebi Premium`
  String get billingPlanPremium {
    return Intl.message(
      'Weebi Premium',
      name: 'billingPlanPremium',
      desc: '',
      args: [],
    );
  }

  /// `per user`
  String get billingPerUser {
    return Intl.message('per user', name: 'billingPerUser', desc: '', args: []);
  }

  /// `You don't have permission to manage licenses. Ask your enterprise administrator to grant you billing access.`
  String get billingNoAccess {
    return Intl.message(
      'You don\'t have permission to manage licenses. Ask your enterprise administrator to grant you billing access.',
      name: 'billingNoAccess',
      desc: '',
      args: [],
    );
  }

  /// `You don't have permission to view statistics. Ask your enterprise administrator to grant you access.`
  String get statsNoAccess {
    return Intl.message(
      'You don\'t have permission to view statistics. Ask your enterprise administrator to grant you access.',
      name: 'statsNoAccess',
      desc: '',
      args: [],
    );
  }

  /// `You don't have permission for this action.`
  String get billingActionNotPermitted {
    return Intl.message(
      'You don\'t have permission for this action.',
      name: 'billingActionNotPermitted',
      desc: '',
      args: [],
    );
  }

  /// `Button Emphasis`
  String get buttonEmphasis {
    return Intl.message(
      'Button Emphasis',
      name: 'buttonEmphasis',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{Button} other{Buttons}}`
  String buttons(num count) {
    return Intl.plural(
      count,
      one: 'Button',
      other: 'Buttons',
      name: 'buttons',
      desc: '',
      args: [count],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Change photo`
  String get changeProfilePhoto {
    return Intl.message(
      'Change photo',
      name: 'changeProfilePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Close Navigation Menu`
  String get closeNavigationMenu {
    return Intl.message(
      'Close Navigation Menu',
      name: 'closeNavigationMenu',
      desc: '',
      args: [],
    );
  }

  /// `Color Palette`
  String get colorPalette {
    return Intl.message(
      'Color Palette',
      name: 'colorPalette',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{Color} other{Colors}}`
  String colors(num count) {
    return Intl.plural(
      count,
      one: 'Color',
      other: 'Colors',
      name: 'colors',
      desc: '',
      args: [count],
    );
  }

  /// `Color Scheme`
  String get colorScheme {
    return Intl.message(
      'Color Scheme',
      name: 'colorScheme',
      desc: '',
      args: [],
    );
  }

  /// `Confirm delete this record?`
  String get confirmDeleteRecord {
    return Intl.message(
      'Confirm delete this record?',
      name: 'confirmDeleteRecord',
      desc: '',
      args: [],
    );
  }

  /// `Confirm submit this record?`
  String get confirmSubmitRecord {
    return Intl.message(
      'Confirm submit this record?',
      name: 'confirmSubmitRecord',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message('Copy', name: 'copy', desc: '', args: []);
  }

  /// `Error while creating the enterprise: `
  String get createEnterpriseErrorPrefix {
    return Intl.message(
      'Error while creating the enterprise: ',
      name: 'createEnterpriseErrorPrefix',
      desc: '',
      args: [],
    );
  }

  /// `Create an enterprise`
  String get createEnterprisePageTitle {
    return Intl.message(
      'Create an enterprise',
      name: 'createEnterprisePageTitle',
      desc: '',
      args: [],
    );
  }

  /// `The enterprise "{name}" was created successfully.`
  String createEnterpriseSuccessTitle(String name) {
    return Intl.message(
      'The enterprise "$name" was created successfully.',
      name: 'createEnterpriseSuccessTitle',
      desc: '',
      args: [name],
    );
  }

  /// `This field requires a valid credit card number.`
  String get creditCardErrorText {
    return Intl.message(
      'This field requires a valid credit card number.',
      name: 'creditCardErrorText',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get crudBack {
    return Intl.message('Back', name: 'crudBack', desc: '', args: []);
  }

  /// `Delete`
  String get crudDelete {
    return Intl.message('Delete', name: 'crudDelete', desc: '', args: []);
  }

  /// `Detail`
  String get crudDetail {
    return Intl.message('Detail', name: 'crudDetail', desc: '', args: []);
  }

  /// `New`
  String get crudNew {
    return Intl.message('New', name: 'crudNew', desc: '', args: []);
  }

  /// `Dark Theme`
  String get darkTheme {
    return Intl.message('Dark Theme', name: 'darkTheme', desc: '', args: []);
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message('Dashboard', name: 'dashboard', desc: '', args: []);
  }

  /// `My stores`
  String get dashboardCardBoutiquesValue {
    return Intl.message(
      'My stores',
      name: 'dashboardCardBoutiquesValue',
      desc: '',
      args: [],
    );
  }

  /// `Devices`
  String get dashboardCardDevicesValue {
    return Intl.message(
      'Devices',
      name: 'dashboardCardDevicesValue',
      desc: '',
      args: [],
    );
  }

  /// `My enterprise`
  String get dashboardCardMyFirmValue {
    return Intl.message(
      'My enterprise',
      name: 'dashboardCardMyFirmValue',
      desc: '',
      args: [],
    );
  }

  /// `Tickets`
  String get dashboardCardTicketsShort {
    return Intl.message(
      'Tickets',
      name: 'dashboardCardTicketsShort',
      desc: '',
      args: [],
    );
  }

  /// `Today's tickets`
  String get dashboardCardTicketsToday {
    return Intl.message(
      'Today\'s tickets',
      name: 'dashboardCardTicketsToday',
      desc: '',
      args: [],
    );
  }

  /// `User access`
  String get dashboardCardUserAccess {
    return Intl.message(
      'User access',
      name: 'dashboardCardUserAccess',
      desc: '',
      args: [],
    );
  }

  /// `Users`
  String get dashboardCardUsersValue {
    return Intl.message(
      'Users',
      name: 'dashboardCardUsersValue',
      desc: '',
      args: [],
    );
  }

  /// `This field requires a valid date string.`
  String get dateStringErrorText {
    return Intl.message(
      'This field requires a valid date string.',
      name: 'dateStringErrorText',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{Dialog} other{Dialogs}}`
  String dialogs(num count) {
    return Intl.plural(
      count,
      one: 'Dialog',
      other: 'Dialogs',
      name: 'dialogs',
      desc: '',
      args: [count],
    );
  }

  /// `Don't have an account?`
  String get dontHaveAnAccount {
    return Intl.message(
      'Don\'t have an account?',
      name: 'dontHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `This field requires a valid email address.`
  String get emailErrorText {
    return Intl.message(
      'This field requires a valid email address.',
      name: 'emailErrorText',
      desc: '',
      args: [],
    );
  }

  /// `Enterprise name`
  String get enterpriseNameFieldHint {
    return Intl.message(
      'Enterprise name',
      name: 'enterpriseNameFieldHint',
      desc: '',
      args: [],
    );
  }

  /// `Enterprise`
  String get enterpriseNameFieldLabel {
    return Intl.message(
      'Enterprise',
      name: 'enterpriseNameFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `This field value must be equal to {value}.`
  String equalErrorText(Object value) {
    return Intl.message(
      'This field value must be equal to $value.',
      name: 'equalErrorText',
      desc: '',
      args: [value],
    );
  }

  /// `Error 404`
  String get error404 {
    return Intl.message('Error 404', name: 'error404', desc: '', args: []);
  }

  /// `Sorry, the page you are looking for has been removed or not exists.`
  String get error404Message {
    return Intl.message(
      'Sorry, the page you are looking for has been removed or not exists.',
      name: 'error404Message',
      desc: '',
      args: [],
    );
  }

  /// `Page not found`
  String get error404Title {
    return Intl.message(
      'Page not found',
      name: 'error404Title',
      desc: '',
      args: [],
    );
  }

  /// `Example`
  String get example {
    return Intl.message('Example', name: 'example', desc: '', args: []);
  }

  /// `{count, plural, one{Extension} other{Extensions}}`
  String extensions(num count) {
    return Intl.plural(
      count,
      one: 'Extension',
      other: 'Extensions',
      name: 'extensions',
      desc: '',
      args: [count],
    );
  }

  /// `Your enterprise groups your users and your store chains.`
  String get firmCardDescription {
    return Intl.message(
      'Your enterprise groups your users and your store chains.',
      name: 'firmCardDescription',
      desc: '',
      args: [],
    );
  }

  /// `Please create a new enterprise by clicking the "Add an enterprise" button.`
  String get firmErrorCreateHint {
    return Intl.message(
      'Please create a new enterprise by clicking the "Add an enterprise" button.',
      name: 'firmErrorCreateHint',
      desc: '',
      args: [],
    );
  }

  /// `An unexpected error occurred.`
  String get firmErrorUnexpected {
    return Intl.message(
      'An unexpected error occurred.',
      name: 'firmErrorUnexpected',
      desc: '',
      args: [],
    );
  }

  /// `My enterprise`
  String get firmPageTitle {
    return Intl.message(
      'My enterprise',
      name: 'firmPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get firstName {
    return Intl.message('First Name', name: 'firstName', desc: '', args: []);
  }

  /// `Forgot password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email address to reset your password.`
  String get forgotPasswordMessage {
    return Intl.message(
      'Enter your email address to reset your password.',
      name: 'forgotPasswordMessage',
      desc: '',
      args: [],
    );
  }

  /// `Forgot password`
  String get forgotPasswordTitle {
    return Intl.message(
      'Forgot password',
      name: 'forgotPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Password reset email sent.`
  String get passwordResetEmailSent {
    return Intl.message(
      'Password reset email sent.',
      name: 'passwordResetEmailSent',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{Form} other{Forms}}`
  String forms(num count) {
    return Intl.plural(
      count,
      one: 'Form',
      other: 'Forms',
      name: 'forms',
      desc: '',
      args: [count],
    );
  }

  /// `General UI`
  String get generalUi {
    return Intl.message('General UI', name: 'generalUi', desc: '', args: []);
  }

  /// `Help`
  String get help {
    return Intl.message('Help', name: 'help', desc: '', args: []);
  }

  /// `Read the FAQ`
  String get helpReadFaq {
    return Intl.message(
      'Read the FAQ',
      name: 'helpReadFaq',
      desc: '',
      args: [],
    );
  }

  /// `Resources`
  String get helpResourcesTitle {
    return Intl.message(
      'Resources',
      name: 'helpResourcesTitle',
      desc: '',
      args: [],
    );
  }

  /// `The web console lets you manage tickets (view, filter, search). Articles, contacts and operations (sales, purchases, stock movements, etc.) are available in the mobile app for now.`
  String get helpScopeBody {
    return Intl.message(
      'The web console lets you manage tickets (view, filter, search). Articles, contacts and operations (sales, purchases, stock movements, etc.) are available in the mobile app for now.',
      name: 'helpScopeBody',
      desc: '',
      args: [],
    );
  }

  /// `The web console lets you manage tickets (view, filter, search) and discover prepared catalog products to set up your POS. Contacts and operations (sales, purchases, stock movements, etc.) remain available in the mobile app for now.`
  String get helpScopeBodyDev {
    return Intl.message(
      'The web console lets you manage tickets (view, filter, search) and discover prepared catalog products to set up your POS. Contacts and operations (sales, purchases, stock movements, etc.) remain available in the mobile app for now.',
      name: 'helpScopeBodyDev',
      desc: '',
      args: [],
    );
  }

  /// `What can I do from the web console?`
  String get helpScopeTitle {
    return Intl.message(
      'What can I do from the web console?',
      name: 'helpScopeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Watch video demos`
  String get helpWatchDemos {
    return Intl.message(
      'Watch video demos',
      name: 'helpWatchDemos',
      desc: '',
      args: [],
    );
  }

  /// `Hi`
  String get hi {
    return Intl.message('Hi', name: 'hi', desc: '', args: []);
  }

  /// `Home`
  String get homePage {
    return Intl.message('Home', name: 'homePage', desc: '', args: []);
  }

  /// `IFrame Demo`
  String get iframeDemo {
    return Intl.message('IFrame Demo', name: 'iframeDemo', desc: '', args: []);
  }

  /// `This field requires a valid integer.`
  String get integerErrorText {
    return Intl.message(
      'This field requires a valid integer.',
      name: 'integerErrorText',
      desc: '',
      args: [],
    );
  }

  /// `This field requires a valid IP.`
  String get ipErrorText {
    return Intl.message(
      'This field requires a valid IP.',
      name: 'ipErrorText',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Last Name`
  String get lastName {
    return Intl.message('Last Name', name: 'lastName', desc: '', args: []);
  }

  /// `Conditions Générales de Vente`
  String get legalDocTitleCgvFr {
    return Intl.message(
      'Conditions Générales de Vente',
      name: 'legalDocTitleCgvFr',
      desc: '',
      args: [],
    );
  }

  /// `Terms and Conditions of Sale`
  String get legalDocTitleTermsEn {
    return Intl.message(
      'Terms and Conditions of Sale',
      name: 'legalDocTitleTermsEn',
      desc: '',
      args: [],
    );
  }

  /// `Document version ID`
  String get legalDocumentVersionId {
    return Intl.message(
      'Document version ID',
      name: 'legalDocumentVersionId',
      desc: '',
      args: [],
    );
  }

  /// `Light Theme`
  String get lightTheme {
    return Intl.message('Light Theme', name: 'lightTheme', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Login now!`
  String get loginNow {
    return Intl.message('Login now!', name: 'loginNow', desc: '', args: []);
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Lorem ipsum dolor sit amet, consectetur adipiscing elit`
  String get loremIpsum {
    return Intl.message(
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
      name: 'loremIpsum',
      desc: '',
      args: [],
    );
  }

  /// `E-mail`
  String get mail {
    return Intl.message('E-mail', name: 'mail', desc: '', args: []);
  }

  /// `Value does not match pattern.`
  String get matchErrorText {
    return Intl.message(
      'Value does not match pattern.',
      name: 'matchErrorText',
      desc: '',
      args: [],
    );
  }

  /// `Value must be less than or equal to {max}`
  String maxErrorText(Object max) {
    return Intl.message(
      'Value must be less than or equal to $max',
      name: 'maxErrorText',
      desc: '',
      args: [max],
    );
  }

  /// `Value must have a length less than or equal to {maxLength}`
  String maxLengthErrorText(Object maxLength) {
    return Intl.message(
      'Value must have a length less than or equal to $maxLength',
      name: 'maxLengthErrorText',
      desc: '',
      args: [maxLength],
    );
  }

  /// `Accesses`
  String get menuAccesses {
    return Intl.message('Accesses', name: 'menuAccesses', desc: '', args: []);
  }

  /// `Weebi licenses`
  String get menuBilling {
    return Intl.message(
      'Weebi licenses',
      name: 'menuBilling',
      desc: '',
      args: [],
    );
  }

  /// `My Boutiques`
  String get menuBoutiques {
    return Intl.message(
      'My Boutiques',
      name: 'menuBoutiques',
      desc: '',
      args: [],
    );
  }

  /// `Devices`
  String get menuDevices {
    return Intl.message('Devices', name: 'menuDevices', desc: '', args: []);
  }

  /// `My enterprise`
  String get menuFirm {
    return Intl.message('My enterprise', name: 'menuFirm', desc: '', args: []);
  }

  /// `Articles, contacts and operations (sales, purchases, stock movements, etc.) are available in the mobile app for now.`
  String get menuScopeDisclaimer {
    return Intl.message(
      'Articles, contacts and operations (sales, purchases, stock movements, etc.) are available in the mobile app for now.',
      name: 'menuScopeDisclaimer',
      desc: '',
      args: [],
    );
  }

  /// `Contacts and operations (sales, purchases, stock movements, etc.) are available in the mobile app for now. Catalog discovery and tickets are available here.`
  String get menuScopeDisclaimerDev {
    return Intl.message(
      'Contacts and operations (sales, purchases, stock movements, etc.) are available in the mobile app for now. Catalog discovery and tickets are available here.',
      name: 'menuScopeDisclaimerDev',
      desc: '',
      args: [],
    );
  }

  /// `Statistics`
  String get menuStats {
    return Intl.message('Statistics', name: 'menuStats', desc: '', args: []);
  }

  /// `Tickets`
  String get menuTickets {
    return Intl.message('Tickets', name: 'menuTickets', desc: '', args: []);
  }

  /// `Users`
  String get menuUsers {
    return Intl.message('Users', name: 'menuUsers', desc: '', args: []);
  }

  /// `Catalog`
  String get menuCatalog {
    return Intl.message('Catalog', name: 'menuCatalog', desc: '', args: []);
  }

  /// `Pick the FMCG products you sell, adjust price and cost, then add them to your chain catalog.`
  String get catalogDiscoverySubtitle {
    return Intl.message(
      'Pick the FMCG products you sell, adjust price and cost, then add them to your chain catalog.',
      name: 'catalogDiscoverySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Chain`
  String get catalogSelectChain {
    return Intl.message(
      'Chain',
      name: 'catalogSelectChain',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get catalogAllCategories {
    return Intl.message(
      'All',
      name: 'catalogAllCategories',
      desc: '',
      args: [],
    );
  }

  /// `No products match your search.`
  String get catalogNoProductsMatch {
    return Intl.message(
      'No products match your search.',
      name: 'catalogNoProductsMatch',
      desc: '',
      args: [],
    );
  }

  /// `Pick`
  String get catalogPick {
    return Intl.message('Pick', name: 'catalogPick', desc: '', args: []);
  }

  /// `Picked`
  String get catalogPicked {
    return Intl.message('Picked', name: 'catalogPicked', desc: '', args: []);
  }

  /// `Already in catalog`
  String get catalogAlreadyInCatalog {
    return Intl.message(
      'Already in catalog',
      name: 'catalogAlreadyInCatalog',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =0{Selection} one{Selection (1)} other{Selection ({count})}}`
  String catalogSelectionTitle(int count) {
    return Intl.plural(
      count,
      zero: 'Selection',
      one: 'Selection (1)',
      other: 'Selection ($count)',
      name: 'catalogSelectionTitle',
      desc: '',
      args: [count],
    );
  }

  /// `Pick products from the grid to build your catalog.`
  String get catalogSelectionEmpty {
    return Intl.message(
      'Pick products from the grid to build your catalog.',
      name: 'catalogSelectionEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get catalogClearSelection {
    return Intl.message(
      'Clear',
      name: 'catalogClearSelection',
      desc: '',
      args: [],
    );
  }

  /// `Add to catalog`
  String get catalogAddToCatalog {
    return Intl.message(
      'Add to catalog',
      name: 'catalogAddToCatalog',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get catalogRemove {
    return Intl.message('Remove', name: 'catalogRemove', desc: '', args: []);
  }

  /// `Price`
  String get catalogPrice {
    return Intl.message('Price', name: 'catalogPrice', desc: '', args: []);
  }

  /// `Cost`
  String get catalogCost {
    return Intl.message('Cost', name: 'catalogCost', desc: '', args: []);
  }

  /// `Value must be greater than or equal to {min}.`
  String minErrorText(Object min) {
    return Intl.message(
      'Value must be greater than or equal to $min.',
      name: 'minErrorText',
      desc: '',
      args: [min],
    );
  }

  /// `Value must have a length greater than or equal to {minLength}`
  String minLengthErrorText(Object minLength) {
    return Intl.message(
      'Value must have a length greater than or equal to $minLength',
      name: 'minLengthErrorText',
      desc: '',
      args: [minLength],
    );
  }

  /// `My Profile`
  String get myProfile {
    return Intl.message('My Profile', name: 'myProfile', desc: '', args: []);
  }

  /// `{count, plural, one{New Order} other{New Orders}}`
  String newOrders(num count) {
    return Intl.plural(
      count,
      one: 'New Order',
      other: 'New Orders',
      name: 'newOrders',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{New User} other{New Users}}`
  String newUsers(num count) {
    return Intl.plural(
      count,
      one: 'New User',
      other: 'New Users',
      name: 'newUsers',
      desc: '',
      args: [count],
    );
  }

  /// `This field value must not be equal to {value}.`
  String notEqualErrorText(Object value) {
    return Intl.message(
      'This field value must not be equal to $value.',
      name: 'notEqualErrorText',
      desc: '',
      args: [value],
    );
  }

  /// `Value must be numeric.`
  String get numericErrorText {
    return Intl.message(
      'Value must be numeric.',
      name: 'numericErrorText',
      desc: '',
      args: [],
    );
  }

  /// `Open in new tab`
  String get openInNewTab {
    return Intl.message(
      'Open in new tab',
      name: 'openInNewTab',
      desc: '',
      args: [],
    );
  }

  /// `Your enterprise administrator must assign you an active license seat, or you need to sign in as the user who created the enterprise, before you can use tickets, articles, or contacts. Open Billing if you manage licenses.`
  String get operationalLicenseBlockedBody {
    return Intl.message(
      'Your enterprise administrator must assign you an active license seat, or you need to sign in as the user who created the enterprise, before you can use tickets, articles, or contacts. Open Billing if you manage licenses.',
      name: 'operationalLicenseBlockedBody',
      desc: '',
      args: [],
    );
  }

  /// `Active license required`
  String get operationalLicenseBlockedTitle {
    return Intl.message(
      'Active license required',
      name: 'operationalLicenseBlockedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Billing`
  String get operationalLicenseOpenBilling {
    return Intl.message(
      'Billing',
      name: 'operationalLicenseOpenBilling',
      desc: '',
      args: [],
    );
  }

  /// `Try again`
  String get operationalLicenseRetry {
    return Intl.message(
      'Try again',
      name: 'operationalLicenseRetry',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{Page} other{Pages}}`
  String pages(num count) {
    return Intl.plural(
      count,
      one: 'Page',
      other: 'Pages',
      name: 'pages',
      desc: '',
      args: [count],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Password not match.`
  String get passwordNotMatch {
    return Intl.message(
      'Password not match.',
      name: 'passwordNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{Pending Issue} other{Pending Issues}}`
  String pendingIssues(num count) {
    return Intl.plural(
      count,
      one: 'Pending Issue',
      other: 'Pending Issues',
      name: 'pendingIssues',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{Recent Order} other{Recent Orders}}`
  String recentOrders(num count) {
    return Intl.plural(
      count,
      one: 'Recent Order',
      other: 'Recent Orders',
      name: 'recentOrders',
      desc: '',
      args: [count],
    );
  }

  /// `Record deleted successfully.`
  String get recordDeletedSuccessfully {
    return Intl.message(
      'Record deleted successfully.',
      name: 'recordDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Record saved successfully.`
  String get recordSavedSuccessfully {
    return Intl.message(
      'Record saved successfully.',
      name: 'recordSavedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Record submitted successfully.`
  String get recordSubmittedSuccessfully {
    return Intl.message(
      'Record submitted successfully.',
      name: 'recordSubmittedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refreshAction {
    return Intl.message('Refresh', name: 'refreshAction', desc: '', args: []);
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `Register a new account`
  String get registerANewAccount {
    return Intl.message(
      'Register a new account',
      name: 'registerANewAccount',
      desc: '',
      args: [],
    );
  }

  /// `Register now!`
  String get registerNow {
    return Intl.message(
      'Register now!',
      name: 'registerNow',
      desc: '',
      args: [],
    );
  }

  /// `This field cannot be empty.`
  String get requiredErrorText {
    return Intl.message(
      'This field cannot be empty.',
      name: 'requiredErrorText',
      desc: '',
      args: [],
    );
  }

  /// `Retype Password`
  String get retypePassword {
    return Intl.message(
      'Retype Password',
      name: 'retypePassword',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `Support`
  String get support {
    return Intl.message('Support', name: 'support', desc: '', args: []);
  }

  /// `Chat with Weebi support`
  String get supportChatWhatsApp {
    return Intl.message(
      'Chat with Weebi support',
      name: 'supportChatWhatsApp',
      desc: '',
      args: [],
    );
  }

  /// `Send us an email`
  String get supportEmailUs {
    return Intl.message(
      'Send us an email',
      name: 'supportEmailUs',
      desc: '',
      args: [],
    );
  }

  /// `Stacked by Boutique`
  String get statsStackedByBoutique {
    return Intl.message(
      'Stacked by Boutique',
      name: 'statsStackedByBoutique',
      desc: '',
      args: [],
    );
  }

  /// `Select Boutiques:`
  String get statsSelectBoutiques {
    return Intl.message(
      'Select Boutiques:',
      name: 'statsSelectBoutiques',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get statsAll {
    return Intl.message('All', name: 'statsAll', desc: '', args: []);
  }

  /// `No data available`
  String get statsNoDataAvailable {
    return Intl.message(
      'No data available',
      name: 'statsNoDataAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Cashflow Income`
  String get statsMetricCashflowIncome {
    return Intl.message(
      'Cashflow Income',
      name: 'statsMetricCashflowIncome',
      desc: '',
      args: [],
    );
  }

  /// `Cashflow Spending`
  String get statsMetricCashflowSpending {
    return Intl.message(
      'Cashflow Spending',
      name: 'statsMetricCashflowSpending',
      desc: '',
      args: [],
    );
  }

  /// `All Income`
  String get statsMetricAllIncome {
    return Intl.message(
      'All Income',
      name: 'statsMetricAllIncome',
      desc: '',
      args: [],
    );
  }

  /// `All Spending`
  String get statsMetricAllSpending {
    return Intl.message(
      'All Spending',
      name: 'statsMetricAllSpending',
      desc: '',
      args: [],
    );
  }

  /// `Day`
  String get statsPeriodDay {
    return Intl.message('Day', name: 'statsPeriodDay', desc: '', args: []);
  }

  /// `Week`
  String get statsPeriodWeek {
    return Intl.message('Week', name: 'statsPeriodWeek', desc: '', args: []);
  }

  /// `Month`
  String get statsPeriodMonth {
    return Intl.message('Month', name: 'statsPeriodMonth', desc: '', args: []);
  }

  /// `Text`
  String get text {
    return Intl.message('Text', name: 'text', desc: '', args: []);
  }

  /// `Text Emphasis`
  String get textEmphasis {
    return Intl.message(
      'Text Emphasis',
      name: 'textEmphasis',
      desc: '',
      args: [],
    );
  }

  /// `Text Theme`
  String get textTheme {
    return Intl.message('Text Theme', name: 'textTheme', desc: '', args: []);
  }

  /// `Ticket detail #{ticketId}`
  String ticketDetailTitle(String ticketId) {
    return Intl.message(
      'Ticket detail #$ticketId',
      name: 'ticketDetailTitle',
      desc: '',
      args: [ticketId],
    );
  }

  /// `{count} items`
  String ticketItemsShort(num count) {
    return Intl.message(
      '$count items',
      name: 'ticketItemsShort',
      desc: '',
      args: [count],
    );
  }

  /// `No ticket provided`
  String get ticketNotProvided {
    return Intl.message(
      'No ticket provided',
      name: 'ticketNotProvided',
      desc: '',
      args: [],
    );
  }

  /// `All stores`
  String get ticketsBoutiqueAll {
    return Intl.message(
      'All stores',
      name: 'ticketsBoutiqueAll',
      desc: '',
      args: [],
    );
  }

  /// `Store`
  String get ticketsBoutiqueFallback {
    return Intl.message(
      'Store',
      name: 'ticketsBoutiqueFallback',
      desc: '',
      args: [],
    );
  }

  /// `Chain unavailable`
  String get ticketsChainUnavailable {
    return Intl.message(
      'Chain unavailable',
      name: 'ticketsChainUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get ticketsColumnAmount {
    return Intl.message(
      'Amount',
      name: 'ticketsColumnAmount',
      desc: '',
      args: [],
    );
  }

  /// `Store`
  String get ticketsColumnBoutique {
    return Intl.message(
      'Store',
      name: 'ticketsColumnBoutique',
      desc: '',
      args: [],
    );
  }

  /// `Contact`
  String get ticketsColumnContact {
    return Intl.message(
      'Contact',
      name: 'ticketsColumnContact',
      desc: '',
      args: [],
    );
  }

  /// `Date · no.`
  String get ticketsColumnDateAndNumber {
    return Intl.message(
      'Date · no.',
      name: 'ticketsColumnDateAndNumber',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get ticketsColumnType {
    return Intl.message('Type', name: 'ticketsColumnType', desc: '', args: []);
  }

  /// `{count, plural, one{# ticket} other{# tickets}}`
  String ticketsCount(num count) {
    return Intl.plural(
      count,
      one: '# ticket',
      other: '# tickets',
      name: 'ticketsCount',
      desc: '',
      args: [count],
    );
  }

  /// `All dates`
  String get ticketsDateAll {
    return Intl.message(
      'All dates',
      name: 'ticketsDateAll',
      desc: '',
      args: [],
    );
  }

  /// `Deleted`
  String get ticketsDeletedChip {
    return Intl.message(
      'Deleted',
      name: 'ticketsDeletedChip',
      desc: '',
      args: [],
    );
  }

  /// `Not deleted`
  String get ticketsDeletedExclude {
    return Intl.message(
      'Not deleted',
      name: 'ticketsDeletedExclude',
      desc: '',
      args: [],
    );
  }

  /// `Deleted only`
  String get ticketsDeletedOnly {
    return Intl.message(
      'Deleted only',
      name: 'ticketsDeletedOnly',
      desc: '',
      args: [],
    );
  }

  /// `No tickets`
  String get ticketsEmpty {
    return Intl.message('No tickets', name: 'ticketsEmpty', desc: '', args: []);
  }

  /// `Filters`
  String get ticketsFiltersTitle {
    return Intl.message(
      'Filters',
      name: 'ticketsFiltersTitle',
      desc: '',
      args: [],
    );
  }

  /// `Group by store`
  String get ticketsGroupByBoutique {
    return Intl.message(
      'Group by store',
      name: 'ticketsGroupByBoutique',
      desc: '',
      args: [],
    );
  }

  /// `Store filter and grouping require an active license seat. The firm creator can use core sync without a seat; these views are for seated team members. Open Billing or ask your administrator to assign you a seat.`
  String get ticketsSeatGatedBoutiqueViewsDetail {
    return Intl.message(
      'Store filter and grouping require an active license seat. The firm creator can use core sync without a seat; these views are for seated team members. Open Billing or ask your administrator to assign you a seat.',
      name: 'ticketsSeatGatedBoutiqueViewsDetail',
      desc: '',
      args: [],
    );
  }

  /// `Store filter & grouping`
  String get ticketsSeatGatedBoutiqueViewsTitle {
    return Intl.message(
      'Store filter & grouping',
      name: 'ticketsSeatGatedBoutiqueViewsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Active license seat required`
  String get ticketsSeatEntitlementSubtitle {
    return Intl.message(
      'Active license seat required',
      name: 'ticketsSeatEntitlementSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Card`
  String get ticketsPaymentCard {
    return Intl.message('Card', name: 'ticketsPaymentCard', desc: '', args: []);
  }

  /// `Cash`
  String get ticketsPaymentCash {
    return Intl.message('Cash', name: 'ticketsPaymentCash', desc: '', args: []);
  }

  /// `Check`
  String get ticketsPaymentCheque {
    return Intl.message(
      'Check',
      name: 'ticketsPaymentCheque',
      desc: '',
      args: [],
    );
  }

  /// `Credit`
  String get ticketsPaymentCredit {
    return Intl.message(
      'Credit',
      name: 'ticketsPaymentCredit',
      desc: '',
      args: [],
    );
  }

  /// `Goods`
  String get ticketsPaymentGoods {
    return Intl.message(
      'Goods',
      name: 'ticketsPaymentGoods',
      desc: '',
      args: [],
    );
  }

  /// `Mobile money`
  String get ticketsPaymentMobileMoney {
    return Intl.message(
      'Mobile money',
      name: 'ticketsPaymentMobileMoney',
      desc: '',
      args: [],
    );
  }

  /// `—`
  String get ticketsPaymentUnknown {
    return Intl.message('—', name: 'ticketsPaymentUnknown', desc: '', args: []);
  }

  /// `Chronological order`
  String get ticketsSortChronological {
    return Intl.message(
      'Chronological order',
      name: 'ticketsSortChronological',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get ticketsStatusActive {
    return Intl.message(
      'Active',
      name: 'ticketsStatusActive',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get ticketsStatusAll {
    return Intl.message('All', name: 'ticketsStatusAll', desc: '', args: []);
  }

  /// `Inactive`
  String get ticketsStatusInactive {
    return Intl.message(
      'Inactive',
      name: 'ticketsStatusInactive',
      desc: '',
      args: [],
    );
  }

  /// `All dates`
  String get ticketsTooltipClearDates {
    return Intl.message(
      'All dates',
      name: 'ticketsTooltipClearDates',
      desc: '',
      args: [],
    );
  }

  /// `Filter by store`
  String get ticketsTooltipFilterBoutique {
    return Intl.message(
      'Filter by store',
      name: 'ticketsTooltipFilterBoutique',
      desc: '',
      args: [],
    );
  }

  /// `Filter by status`
  String get ticketsTooltipFilterByStatus {
    return Intl.message(
      'Filter by status',
      name: 'ticketsTooltipFilterByStatus',
      desc: '',
      args: [],
    );
  }

  /// `Filter by deleted tickets`
  String get ticketsTooltipFilterDeleted {
    return Intl.message(
      'Filter by deleted tickets',
      name: 'ticketsTooltipFilterDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get ticketsTooltipRefresh {
    return Intl.message(
      'Refresh',
      name: 'ticketsTooltipRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Ticket`
  String get ticketTypeDefault {
    return Intl.message(
      'Ticket',
      name: 'ticketTypeDefault',
      desc: '',
      args: [],
    );
  }

  /// `Today Sales`
  String get todaySales {
    return Intl.message('Today Sales', name: 'todaySales', desc: '', args: []);
  }

  /// `Typography`
  String get typography {
    return Intl.message('Typography', name: 'typography', desc: '', args: []);
  }

  /// `{count, plural, one{UI Element} other{UI Elements}}`
  String uiElements(num count) {
    return Intl.plural(
      count,
      one: 'UI Element',
      other: 'UI Elements',
      name: 'uiElements',
      desc: '',
      args: [count],
    );
  }

  /// `This field requires a valid URL address.`
  String get urlErrorText {
    return Intl.message(
      'This field requires a valid URL address.',
      name: 'urlErrorText',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<Lang> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<Lang> load(Locale locale) => Lang.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
