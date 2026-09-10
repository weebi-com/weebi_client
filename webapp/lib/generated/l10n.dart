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

  /// `À propos`
  String get about {
    return Intl.message('À propos', name: 'about', desc: '', args: []);
  }

  /// `Blog`
  String get aboutBlog {
    return Intl.message('Blog', name: 'aboutBlog', desc: '', args: []);
  }

  /// `Partenaires historiques`
  String get aboutPartners {
    return Intl.message(
      'Partenaires historiques',
      name: 'aboutPartners',
      desc: '',
      args: [],
    );
  }

  /// `Mon Compte`
  String get account {
    return Intl.message('Mon Compte', name: 'account', desc: '', args: []);
  }

  /// `Connexion au Portail Administrateur`
  String get adminPortalLogin {
    return Intl.message(
      'Connexion au Portail Administrateur',
      name: 'adminPortalLogin',
      desc: '',
      args: [],
    );
  }

  /// `Retour à la Connexion`
  String get backToLogin {
    return Intl.message(
      'Retour à la Connexion',
      name: 'backToLogin',
      desc: '',
      args: [],
    );
  }

  /// `J'ai lu et j'accepte les Conditions Générales de Vente applicables à l'achat d'un rapport de trésorerie.`
  String get billingAcceptAccountingReportTerms {
    return Intl.message(
      'J\'ai lu et j\'accepte les Conditions Générales de Vente applicables à l\'achat d\'un rapport de trésorerie.',
      name: 'billingAcceptAccountingReportTerms',
      desc: '',
      args: [],
    );
  }

  /// `J'ai lu et j'accepte les Conditions Générales de Vente applicables à l'achat d'une licence Entreprise.`
  String get billingAcceptEnterpriseTerms {
    return Intl.message(
      'J\'ai lu et j\'accepte les Conditions Générales de Vente applicables à l\'achat d\'une licence Entreprise.',
      name: 'billingAcceptEnterpriseTerms',
      desc: '',
      args: [],
    );
  }

  /// `Veuillez accepter les conditions générales pour continuer.`
  String get billingAcceptTermsToContinue {
    return Intl.message(
      'Veuillez accepter les conditions générales pour continuer.',
      name: 'billingAcceptTermsToContinue',
      desc: '',
      args: [],
    );
  }

  /// `Vous n'avez pas l'autorisation d'effectuer cette action.`
  String get billingActionNotPermitted {
    return Intl.message(
      'Vous n\'avez pas l\'autorisation d\'effectuer cette action.',
      name: 'billingActionNotPermitted',
      desc: '',
      args: [],
    );
  }

  /// `Parrainage`
  String get billingReferralTitle {
    return Intl.message(
      'Parrainage',
      name: 'billingReferralTitle',
      desc: '',
      args: [],
    );
  }

  /// `Partagez votre code : 10 % pour eux, 20 % de Crédit weebi pour vous.`
  String get billingReferralTease {
    return Intl.message(
      'Partagez votre code : 10 % pour eux, 20 % de Crédit weebi pour vous.',
      name: 'billingReferralTease',
      desc: '',
      args: [],
    );
  }

  /// `Parrainez un commerçant. Il paie 10 % de moins, vous gagnez 20 % en Crédit weebi — à déduire de vos prochains achats Weebi.`
  String get billingReferralIntro {
    return Intl.message(
      'Parrainez un commerçant. Il paie 10 % de moins, vous gagnez 20 % en Crédit weebi — à déduire de vos prochains achats Weebi.',
      name: 'billingReferralIntro',
      desc: '',
      args: [],
    );
  }

  /// `Comment ça marche`
  String get billingReferralHowTitle {
    return Intl.message(
      'Comment ça marche',
      name: 'billingReferralHowTitle',
      desc: '',
      args: [],
    );
  }

  /// `Fermer`
  String get billingReferralDialogClose {
    return Intl.message(
      'Fermer',
      name: 'billingReferralDialogClose',
      desc: '',
      args: [],
    );
  }

  /// `Partagez votre code avec un autre commerçant.`
  String get billingReferralStepShare {
    return Intl.message(
      'Partagez votre code avec un autre commerçant.',
      name: 'billingReferralStepShare',
      desc: '',
      args: [],
    );
  }

  /// `À l'achat, il bénéficie de 10 % de réduction.`
  String get billingReferralStepDiscount {
    return Intl.message(
      'À l\'achat, il bénéficie de 10 % de réduction.',
      name: 'billingReferralStepDiscount',
      desc: '',
      args: [],
    );
  }

  /// `Vous recevez 20 % en Crédit weebi, utilisable sur vos licences et rapports.`
  String get billingReferralStepCredit {
    return Intl.message(
      'Vous recevez 20 % en Crédit weebi, utilisable sur vos licences et rapports.',
      name: 'billingReferralStepCredit',
      desc: '',
      args: [],
    );
  }

  /// `Votre code de parrainage`
  String get billingReferralYourCode {
    return Intl.message(
      'Votre code de parrainage',
      name: 'billingReferralYourCode',
      desc: '',
      args: [],
    );
  }

  /// `Crédit weebi`
  String get billingReferralCreditBalance {
    return Intl.message(
      'Crédit weebi',
      name: 'billingReferralCreditBalance',
      desc: '',
      args: [],
    );
  }

  /// `Utilisable sur vos prochains achats Weebi.`
  String get billingReferralCreditHint {
    return Intl.message(
      'Utilisable sur vos prochains achats Weebi.',
      name: 'billingReferralCreditHint',
      desc: '',
      args: [],
    );
  }

  /// `On vous a parrainé ?`
  String get billingReferralHaveCodeTitle {
    return Intl.message(
      'On vous a parrainé ?',
      name: 'billingReferralHaveCodeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Code du parrain`
  String get billingReferralCodeHint {
    return Intl.message(
      'Code du parrain',
      name: 'billingReferralCodeHint',
      desc: '',
      args: [],
    );
  }

  /// `10 % de réduction sur votre achat`
  String get billingReferralDiscountHint {
    return Intl.message(
      '10 % de réduction sur votre achat',
      name: 'billingReferralDiscountHint',
      desc: '',
      args: [],
    );
  }

  /// `Vous ne pouvez pas utiliser votre propre code`
  String get billingReferralSelfError {
    return Intl.message(
      'Vous ne pouvez pas utiliser votre propre code',
      name: 'billingReferralSelfError',
      desc: '',
      args: [],
    );
  }

  /// `Avec parrainage : {price}`
  String billingReferralDiscountedPrice(String price) {
    return Intl.message(
      'Avec parrainage : $price',
      name: 'billingReferralDiscountedPrice',
      desc: '',
      args: [price],
    );
  }

  /// `Copier le code`
  String get billingReferralCopyCode {
    return Intl.message(
      'Copier le code',
      name: 'billingReferralCopyCode',
      desc: '',
      args: [],
    );
  }

  /// `Code copié`
  String get billingReferralCopied {
    return Intl.message(
      'Code copié',
      name: 'billingReferralCopied',
      desc: '',
      args: [],
    );
  }

  /// `Tous les utilisateurs ont déjà une licence attribuée.`
  String get billingAllUsersAlreadyAssigned {
    return Intl.message(
      'Tous les utilisateurs ont déjà une licence attribuée.',
      name: 'billingAllUsersAlreadyAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Attribuer la licence à un utilisateur`
  String get billingAssignSeatDialogTitle {
    return Intl.message(
      'Attribuer la licence à un utilisateur',
      name: 'billingAssignSeatDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Attribuer la licence à un utilisateur`
  String get billingAssignSeats {
    return Intl.message(
      'Attribuer la licence à un utilisateur',
      name: 'billingAssignSeats',
      desc: '',
      args: [],
    );
  }

  /// `Attribuez vos nouvelles licences aux utilisateurs ci‑dessous.`
  String get billingAssignSeatsCta {
    return Intl.message(
      'Attribuez vos nouvelles licences aux utilisateurs ci‑dessous.',
      name: 'billingAssignSeatsCta',
      desc: '',
      args: [],
    );
  }

  /// `Attribué à`
  String get billingAttributedTo {
    return Intl.message(
      'Attribué à',
      name: 'billingAttributedTo',
      desc: '',
      args: [],
    );
  }

  /// `Comment souhaitez-vous payer ?`
  String get billingChoosePaymentMethod {
    return Intl.message(
      'Comment souhaitez-vous payer ?',
      name: 'billingChoosePaymentMethod',
      desc: '',
      args: [],
    );
  }

  /// `Licence(s)`
  String get billingLicenses {
    return Intl.message(
      'Licence(s)',
      name: 'billingLicenses',
      desc: '',
      args: [],
    );
  }

  /// `À vie`
  String get billingLifetime {
    return Intl.message('À vie', name: 'billingLifetime', desc: '', args: []);
  }

  /// `Mes licences Premium`
  String get billingMyLicenses {
    return Intl.message(
      'Mes licences Premium',
      name: 'billingMyLicenses',
      desc: '',
      args: [],
    );
  }

  /// `Vous n'avez pas l'autorisation de gérer les licences. Demandez à l'administrateur de votre entreprise de vous accorder l'accès.`
  String get billingNoAccess {
    return Intl.message(
      'Vous n\'avez pas l\'autorisation de gérer les licences. Demandez à l\'administrateur de votre entreprise de vous accorder l\'accès.',
      name: 'billingNoAccess',
      desc: '',
      args: [],
    );
  }

  /// `Pas encore attribuée(s)`
  String get billingNotYetAttributed {
    return Intl.message(
      'Pas encore attribuée(s)',
      name: 'billingNotYetAttributed',
      desc: '',
      args: [],
    );
  }

  /// `Aucun utilisateur à attribuer. Ajoutez des utilisateurs dans Utilisateurs d'abord.`
  String get billingNoUsersAvailable {
    return Intl.message(
      'Aucun utilisateur à attribuer. Ajoutez des utilisateurs dans Utilisateurs d\'abord.',
      name: 'billingNoUsersAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Paiement reçu. Confirmation en cours — votre ou vos licences apparaîtront sous peu ; vous pourrez ensuite les attribuer aux utilisateurs.`
  String get billingPaymentProcessing {
    return Intl.message(
      'Paiement reçu. Confirmation en cours — votre ou vos licences apparaîtront sous peu ; vous pourrez ensuite les attribuer aux utilisateurs.',
      name: 'billingPaymentProcessing',
      desc: '',
      args: [],
    );
  }

  /// `Paiement accepté. Une ou plusieurs licences ont bien été achetées : vous pouvez les attribuer aux utilisateurs concernés.`
  String get billingPaymentSuccess {
    return Intl.message(
      'Paiement accepté. Une ou plusieurs licences ont bien été achetées : vous pouvez les attribuer aux utilisateurs concernés.',
      name: 'billingPaymentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Carte/Banque`
  String get billingPayWithCard {
    return Intl.message(
      'Carte/Banque',
      name: 'billingPayWithCard',
      desc: '',
      args: [],
    );
  }

  /// `Mobile Money`
  String get billingPayWithMobileMoney {
    return Intl.message(
      'Mobile Money',
      name: 'billingPayWithMobileMoney',
      desc: '',
      args: [],
    );
  }

  /// `par utilisateur`
  String get billingPerUser {
    return Intl.message(
      'par utilisateur',
      name: 'billingPerUser',
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

  /// `Acheter`
  String get billingPurchase {
    return Intl.message('Acheter', name: 'billingPurchase', desc: '', args: []);
  }

  /// `Acheter Premium`
  String get billingPurchaseLicense {
    return Intl.message(
      'Acheter Premium',
      name: 'billingPurchaseLicense',
      desc: '',
      args: [],
    );
  }

  /// `La licence Premium débloque le suivi à distance, le multi-boutiques et le tableau de bord avancé. Achat unique par utilisateur : pas d'abonnement, pas de date limite.`
  String get billingPurchaseLicenseDescription {
    return Intl.message(
      'La licence Premium débloque le suivi à distance, le multi-boutiques et le tableau de bord avancé. Achat unique par utilisateur : pas d\'abonnement, pas de date limite.',
      name: 'billingPurchaseLicenseDescription',
      desc: '',
      args: [],
    );
  }

  /// `Aucun autre utilisateur ne peut recevoir cette license. Ajoutez un utilisateur ou libérez une license ailleurs d’abord.`
  String get billingReassignNoOtherUser {
    return Intl.message(
      'Aucun autre utilisateur ne peut recevoir cette license. Ajoutez un utilisateur ou libérez une license ailleurs d’abord.',
      name: 'billingReassignNoOtherUser',
      desc: '',
      args: [],
    );
  }

  /// `Réattribuer`
  String get billingReassignSeat {
    return Intl.message(
      'Réattribuer',
      name: 'billingReassignSeat',
      desc: '',
      args: [],
    );
  }

  /// `Réattribuer cette license à un autre utilisateur`
  String get billingReassignSeatDialogTitle {
    return Intl.message(
      'Réattribuer cette license à un autre utilisateur',
      name: 'billingReassignSeatDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Réessayer`
  String get billingRetry {
    return Intl.message('Réessayer', name: 'billingRetry', desc: '', args: []);
  }

  /// `licence(s) attribuée(s)`
  String get billingSeatsAttributed {
    return Intl.message(
      'licence(s) attribuée(s)',
      name: 'billingSeatsAttributed',
      desc: '',
      args: [],
    );
  }

  /// `Aucune licence Premium achetée pour le moment.`
  String get billingHistoryNoLicenses {
    return Intl.message(
      'Aucune licence Premium achetée pour le moment.',
      name: 'billingHistoryNoLicenses',
      desc: '',
      args: [],
    );
  }

  /// `Aucune année fiscale payée pour le moment.`
  String get billingHistoryNoSyscohadaYears {
    return Intl.message(
      'Aucune année fiscale payée pour le moment.',
      name: 'billingHistoryNoSyscohadaYears',
      desc: '',
      args: [],
    );
  }

  /// `Achats / Attribution licence`
  String get billingTabHistory {
    return Intl.message(
      'Achats / Attribution licence',
      name: 'billingTabHistory',
      desc: '',
      args: [],
    );
  }

  /// `Offres`
  String get billingTabOffers {
    return Intl.message('Offres', name: 'billingTabOffers', desc: '', args: []);
  }

  /// `Ce rapport ne peut être généré avant la fin de l'exercice fiscal.`
  String get billingSyscohadaCurrentYearDisclaimer {
    return Intl.message(
      'Ce rapport ne peut être généré avant la fin de l\'exercice fiscal.',
      name: 'billingSyscohadaCurrentYearDisclaimer',
      desc: '',
      args: [],
    );
  }

  /// `par année fiscale`
  String get billingSyscohadaPerReport {
    return Intl.message(
      'par année fiscale',
      name: 'billingSyscohadaPerReport',
      desc: '',
      args: [],
    );
  }

  /// `1 900 CFA / 2.90 EUR`
  String get billingSyscohadaPrice {
    return Intl.message(
      '1 900 CFA / 2.90 EUR',
      name: 'billingSyscohadaPrice',
      desc: '',
      args: [],
    );
  }

  /// `Payer cette année`
  String get billingSyscohadaPurchase {
    return Intl.message(
      'Payer cette année',
      name: 'billingSyscohadaPurchase',
      desc: '',
      args: [],
    );
  }

  /// `Années déjà payées`
  String get billingSyscohadaPurchasedYears {
    return Intl.message(
      'Années déjà payées',
      name: 'billingSyscohadaPurchasedYears',
      desc: '',
      args: [],
    );
  }

  /// `Année fiscale`
  String get billingSyscohadaSelectYear {
    return Intl.message(
      'Année fiscale',
      name: 'billingSyscohadaSelectYear',
      desc: '',
      args: [],
    );
  }

  /// `Système Minimal de Trésorerie`
  String get billingSyscohadaSubtitle {
    return Intl.message(
      'Système Minimal de Trésorerie',
      name: 'billingSyscohadaSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `États financiers SYSCOHADA`
  String get billingSyscohadaTitle {
    return Intl.message(
      'États financiers SYSCOHADA',
      name: 'billingSyscohadaTitle',
      desc: '',
      args: [],
    );
  }

  /// `utilisateur(s)`
  String get billingUsers {
    return Intl.message(
      'utilisateur(s)',
      name: 'billingUsers',
      desc: '',
      args: [],
    );
  }

  /// `Valide jusqu'au`
  String get billingValidUntil {
    return Intl.message(
      'Valide jusqu\'au',
      name: 'billingValidUntil',
      desc: '',
      args: [],
    );
  }

  /// `Conditions Générales de Vente`
  String get billingViewFullTerms {
    return Intl.message(
      'Conditions Générales de Vente',
      name: 'billingViewFullTerms',
      desc: '',
      args: [],
    );
  }

  /// `Accentuation du Bouton`
  String get buttonEmphasis {
    return Intl.message(
      'Accentuation du Bouton',
      name: 'buttonEmphasis',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{Bouton} other{Boutons}}`
  String buttons(num count) {
    return Intl.plural(
      count,
      one: 'Bouton',
      other: 'Boutons',
      name: 'buttons',
      desc: '',
      args: [count],
    );
  }

  /// `Annuler`
  String get cancel {
    return Intl.message('Annuler', name: 'cancel', desc: '', args: []);
  }

  /// `Ajouter au catalogue`
  String get catalogAddToCatalog {
    return Intl.message(
      'Ajouter au catalogue',
      name: 'catalogAddToCatalog',
      desc: '',
      args: [],
    );
  }

  /// `Tous`
  String get catalogAllCategories {
    return Intl.message(
      'Tous',
      name: 'catalogAllCategories',
      desc: '',
      args: [],
    );
  }

  /// `Déjà au catalogue`
  String get catalogAlreadyInCatalog {
    return Intl.message(
      'Déjà au catalogue',
      name: 'catalogAlreadyInCatalog',
      desc: '',
      args: [],
    );
  }

  /// `Vider`
  String get catalogClearSelection {
    return Intl.message(
      'Vider',
      name: 'catalogClearSelection',
      desc: '',
      args: [],
    );
  }

  /// `Coût d'achat`
  String get catalogCost {
    return Intl.message(
      'Coût d\'achat',
      name: 'catalogCost',
      desc: '',
      args: [],
    );
  }

  /// `Sélectionnez les produits FMCG que vous vendez, ajustez le prix et le coût, puis ajoutez-les au catalogue de votre chaîne.`
  String get catalogDiscoverySubtitle {
    return Intl.message(
      'Sélectionnez les produits FMCG que vous vendez, ajustez le prix et le coût, puis ajoutez-les au catalogue de votre chaîne.',
      name: 'catalogDiscoverySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Aucun produit ne correspond à votre recherche.`
  String get catalogNoProductsMatch {
    return Intl.message(
      'Aucun produit ne correspond à votre recherche.',
      name: 'catalogNoProductsMatch',
      desc: '',
      args: [],
    );
  }

  /// `Choisir`
  String get catalogPick {
    return Intl.message('Choisir', name: 'catalogPick', desc: '', args: []);
  }

  /// `Choisi`
  String get catalogPicked {
    return Intl.message('Choisi', name: 'catalogPicked', desc: '', args: []);
  }

  /// `Prix`
  String get catalogPrice {
    return Intl.message('Prix', name: 'catalogPrice', desc: '', args: []);
  }

  /// `Retirer`
  String get catalogRemove {
    return Intl.message('Retirer', name: 'catalogRemove', desc: '', args: []);
  }

  /// `Chaîne`
  String get catalogSelectChain {
    return Intl.message(
      'Chaîne',
      name: 'catalogSelectChain',
      desc: '',
      args: [],
    );
  }

  /// `Choisissez des produits dans la grille pour constituer votre catalogue.`
  String get catalogSelectionEmpty {
    return Intl.message(
      'Choisissez des produits dans la grille pour constituer votre catalogue.',
      name: 'catalogSelectionEmpty',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =0{Sélection} one{Sélection (1)} other{Sélection ({count})}}`
  String catalogSelectionTitle(int count) {
    return Intl.plural(
      count,
      zero: 'Sélection',
      one: 'Sélection (1)',
      other: 'Sélection ($count)',
      name: 'catalogSelectionTitle',
      desc: '',
      args: [count],
    );
  }

  /// `Changer la photo`
  String get changeProfilePhoto {
    return Intl.message(
      'Changer la photo',
      name: 'changeProfilePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Fermer le Menu de Navigation`
  String get closeNavigationMenu {
    return Intl.message(
      'Fermer le Menu de Navigation',
      name: 'closeNavigationMenu',
      desc: '',
      args: [],
    );
  }

  /// `Palette de Couleurs`
  String get colorPalette {
    return Intl.message(
      'Palette de Couleurs',
      name: 'colorPalette',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{Couleur} other{Couleurs}}`
  String colors(num count) {
    return Intl.plural(
      count,
      one: 'Couleur',
      other: 'Couleurs',
      name: 'colors',
      desc: '',
      args: [count],
    );
  }

  /// `Schéma de Couleurs`
  String get colorScheme {
    return Intl.message(
      'Schéma de Couleurs',
      name: 'colorScheme',
      desc: '',
      args: [],
    );
  }

  /// `Confirmer la suppression de cet enregistrement?`
  String get confirmDeleteRecord {
    return Intl.message(
      'Confirmer la suppression de cet enregistrement?',
      name: 'confirmDeleteRecord',
      desc: '',
      args: [],
    );
  }

  /// `Confirmer la soumission de cet enregistrement?`
  String get confirmSubmitRecord {
    return Intl.message(
      'Confirmer la soumission de cet enregistrement?',
      name: 'confirmSubmitRecord',
      desc: '',
      args: [],
    );
  }

  /// `Copier`
  String get copy {
    return Intl.message('Copier', name: 'copy', desc: '', args: []);
  }

  /// `Erreur lors de la création de l'entreprise : `
  String get createEnterpriseErrorPrefix {
    return Intl.message(
      'Erreur lors de la création de l\'entreprise : ',
      name: 'createEnterpriseErrorPrefix',
      desc: '',
      args: [],
    );
  }

  /// `Créer une entreprise`
  String get createEnterprisePageTitle {
    return Intl.message(
      'Créer une entreprise',
      name: 'createEnterprisePageTitle',
      desc: '',
      args: [],
    );
  }

  /// `L'entreprise « {name} » a bien été créée.`
  String createEnterpriseSuccessTitle(String name) {
    return Intl.message(
      'L\'entreprise « $name » a bien été créée.',
      name: 'createEnterpriseSuccessTitle',
      desc: '',
      args: [name],
    );
  }

  /// `Ce champ nécessite un numéro de carte de crédit valide.`
  String get creditCardErrorText {
    return Intl.message(
      'Ce champ nécessite un numéro de carte de crédit valide.',
      name: 'creditCardErrorText',
      desc: '',
      args: [],
    );
  }

  /// `Retour`
  String get crudBack {
    return Intl.message('Retour', name: 'crudBack', desc: '', args: []);
  }

  /// `Supprimer`
  String get crudDelete {
    return Intl.message('Supprimer', name: 'crudDelete', desc: '', args: []);
  }

  /// `Détail`
  String get crudDetail {
    return Intl.message('Détail', name: 'crudDetail', desc: '', args: []);
  }

  /// `Nouveau`
  String get crudNew {
    return Intl.message('Nouveau', name: 'crudNew', desc: '', args: []);
  }

  /// `Thème Sombre`
  String get darkTheme {
    return Intl.message('Thème Sombre', name: 'darkTheme', desc: '', args: []);
  }

  /// `Tableau de Bord`
  String get dashboard {
    return Intl.message(
      'Tableau de Bord',
      name: 'dashboard',
      desc: '',
      args: [],
    );
  }

  /// `Mes boutiques`
  String get dashboardCardBoutiquesValue {
    return Intl.message(
      'Mes boutiques',
      name: 'dashboardCardBoutiquesValue',
      desc: '',
      args: [],
    );
  }

  /// `Appareils`
  String get dashboardCardDevicesValue {
    return Intl.message(
      'Appareils',
      name: 'dashboardCardDevicesValue',
      desc: '',
      args: [],
    );
  }

  /// `Mon entreprise`
  String get dashboardCardMyFirmValue {
    return Intl.message(
      'Mon entreprise',
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

  /// `Tickets du jour`
  String get dashboardCardTicketsToday {
    return Intl.message(
      'Tickets du jour',
      name: 'dashboardCardTicketsToday',
      desc: '',
      args: [],
    );
  }

  /// `Accès utilisateurs`
  String get dashboardCardUserAccess {
    return Intl.message(
      'Accès utilisateurs',
      name: 'dashboardCardUserAccess',
      desc: '',
      args: [],
    );
  }

  /// `Utilisateurs`
  String get dashboardCardUsersValue {
    return Intl.message(
      'Utilisateurs',
      name: 'dashboardCardUsersValue',
      desc: '',
      args: [],
    );
  }

  /// `Ce champ nécessite une chaîne de date valide.`
  String get dateStringErrorText {
    return Intl.message(
      'Ce champ nécessite une chaîne de date valide.',
      name: 'dateStringErrorText',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{Dialogue} other{Dialogues}}`
  String dialogs(num count) {
    return Intl.plural(
      count,
      one: 'Dialogue',
      other: 'Dialogues',
      name: 'dialogs',
      desc: '',
      args: [count],
    );
  }

  /// `Vous n'avez pas de compte ?`
  String get dontHaveAnAccount {
    return Intl.message(
      'Vous n\'avez pas de compte ?',
      name: 'dontHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `E-mail`
  String get email {
    return Intl.message('E-mail', name: 'email', desc: '', args: []);
  }

  /// `Ce champ nécessite une adresse e-mail valide.`
  String get emailErrorText {
    return Intl.message(
      'Ce champ nécessite une adresse e-mail valide.',
      name: 'emailErrorText',
      desc: '',
      args: [],
    );
  }

  /// `Nom de l'entreprise`
  String get enterpriseNameFieldHint {
    return Intl.message(
      'Nom de l\'entreprise',
      name: 'enterpriseNameFieldHint',
      desc: '',
      args: [],
    );
  }

  /// `Entreprise`
  String get enterpriseNameFieldLabel {
    return Intl.message(
      'Entreprise',
      name: 'enterpriseNameFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `La valeur de ce champ doit être égale à {value}.`
  String equalErrorText(Object value) {
    return Intl.message(
      'La valeur de ce champ doit être égale à $value.',
      name: 'equalErrorText',
      desc: '',
      args: [value],
    );
  }

  /// `Erreur 404`
  String get error404 {
    return Intl.message('Erreur 404', name: 'error404', desc: '', args: []);
  }

  /// `Désolé, la page que vous recherchez a été supprimée ou n'existe pas.`
  String get error404Message {
    return Intl.message(
      'Désolé, la page que vous recherchez a été supprimée ou n\'existe pas.',
      name: 'error404Message',
      desc: '',
      args: [],
    );
  }

  /// `Page non trouvée`
  String get error404Title {
    return Intl.message(
      'Page non trouvée',
      name: 'error404Title',
      desc: '',
      args: [],
    );
  }

  /// `Exemple`
  String get example {
    return Intl.message('Exemple', name: 'example', desc: '', args: []);
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

  /// `Votre entreprise regroupe vos utilisateurs et vos chaînes ou boutiques.`
  String get firmCardDescription {
    return Intl.message(
      'Votre entreprise regroupe vos utilisateurs et vos chaînes ou boutiques.',
      name: 'firmCardDescription',
      desc: '',
      args: [],
    );
  }

  /// `Créée le`
  String get firmCreatedAtLabel {
    return Intl.message(
      'Créée le',
      name: 'firmCreatedAtLabel',
      desc: '',
      args: [],
    );
  }

  /// `Devise par défaut`
  String get firmCurrencyLabel {
    return Intl.message(
      'Devise par défaut',
      name: 'firmCurrencyLabel',
      desc: '',
      args: [],
    );
  }

  /// `Double devise`
  String get firmDualCurrencyLabel {
    return Intl.message(
      'Double devise',
      name: 'firmDualCurrencyLabel',
      desc: '',
      args: [],
    );
  }

  /// `E-mail vérifié`
  String get firmEmailVerifiedLabel {
    return Intl.message(
      'E-mail vérifié',
      name: 'firmEmailVerifiedLabel',
      desc: '',
      args: [],
    );
  }

  /// `Veuillez créer une nouvelle entreprise en cliquant sur le bouton « Ajouter une entreprise ».`
  String get firmErrorCreateHint {
    return Intl.message(
      'Veuillez créer une nouvelle entreprise en cliquant sur le bouton « Ajouter une entreprise ».',
      name: 'firmErrorCreateHint',
      desc: '',
      args: [],
    );
  }

  /// `Une erreur inattendue est survenue.`
  String get firmErrorUnexpected {
    return Intl.message(
      'Une erreur inattendue est survenue.',
      name: 'firmErrorUnexpected',
      desc: '',
      args: [],
    );
  }

  /// `ID entreprise`
  String get firmIdLabel {
    return Intl.message(
      'ID entreprise',
      name: 'firmIdLabel',
      desc: '',
      args: [],
    );
  }

  /// `Nom`
  String get firmNameLabel {
    return Intl.message('Nom', name: 'firmNameLabel', desc: '', args: []);
  }

  /// `Mon entreprise`
  String get firmPageTitle {
    return Intl.message(
      'Mon entreprise',
      name: 'firmPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Devise secondaire`
  String get firmSecondaryCurrencyLabel {
    return Intl.message(
      'Devise secondaire',
      name: 'firmSecondaryCurrencyLabel',
      desc: '',
      args: [],
    );
  }

  /// `Actif`
  String get firmStatusActive {
    return Intl.message('Actif', name: 'firmStatusActive', desc: '', args: []);
  }

  /// `Inactif`
  String get firmStatusInactive {
    return Intl.message(
      'Inactif',
      name: 'firmStatusInactive',
      desc: '',
      args: [],
    );
  }

  /// `Statut`
  String get firmStatusLabel {
    return Intl.message('Statut', name: 'firmStatusLabel', desc: '', args: []);
  }

  /// `Prénom`
  String get firstName {
    return Intl.message('Prénom', name: 'firstName', desc: '', args: []);
  }

  /// `Mot de passe oublié ?`
  String get forgotPassword {
    return Intl.message(
      'Mot de passe oublié ?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Saisissez votre adresse e-mail pour réinitialiser votre mot de passe.`
  String get forgotPasswordMessage {
    return Intl.message(
      'Saisissez votre adresse e-mail pour réinitialiser votre mot de passe.',
      name: 'forgotPasswordMessage',
      desc: '',
      args: [],
    );
  }

  /// `Mot de passe oublié`
  String get forgotPasswordTitle {
    return Intl.message(
      'Mot de passe oublié',
      name: 'forgotPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{Formulaire} other{Formulaires}}`
  String forms(num count) {
    return Intl.plural(
      count,
      one: 'Formulaire',
      other: 'Formulaires',
      name: 'forms',
      desc: '',
      args: [count],
    );
  }

  /// `UI Générale`
  String get generalUi {
    return Intl.message('UI Générale', name: 'generalUi', desc: '', args: []);
  }

  /// `Aide`
  String get help {
    return Intl.message('Aide', name: 'help', desc: '', args: []);
  }

  /// `Lire la FAQ`
  String get helpReadFaq {
    return Intl.message('Lire la FAQ', name: 'helpReadFaq', desc: '', args: []);
  }

  /// `Ressources`
  String get helpResourcesTitle {
    return Intl.message(
      'Ressources',
      name: 'helpResourcesTitle',
      desc: '',
      args: [],
    );
  }

  /// `La console web permet de gérer les tickets (consultation, filtres, recherche). Les articles, contacts et opérations (ventes, achats, mouvements de stock, etc.) sont uniquement disponibles sur l'application de caisse pour l'instant.`
  String get helpScopeBody {
    return Intl.message(
      'La console web permet de gérer les tickets (consultation, filtres, recherche). Les articles, contacts et opérations (ventes, achats, mouvements de stock, etc.) sont uniquement disponibles sur l\'application de caisse pour l\'instant.',
      name: 'helpScopeBody',
      desc: '',
      args: [],
    );
  }

  /// `La console web permet de gérer les tickets (consultation, filtres, recherche) et de découvrir des produits préparés pour configurer votre caisse. Les contacts et opérations (ventes, achats, mouvements de stock, etc.) restent disponibles sur l'application de caisse pour l'instant.`
  String get helpScopeBodyDev {
    return Intl.message(
      'La console web permet de gérer les tickets (consultation, filtres, recherche) et de découvrir des produits préparés pour configurer votre caisse. Les contacts et opérations (ventes, achats, mouvements de stock, etc.) restent disponibles sur l\'application de caisse pour l\'instant.',
      name: 'helpScopeBodyDev',
      desc: '',
      args: [],
    );
  }

  /// `Que puis-je faire depuis la console web ?`
  String get helpScopeTitle {
    return Intl.message(
      'Que puis-je faire depuis la console web ?',
      name: 'helpScopeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Voir les démos vidéo`
  String get helpWatchDemos {
    return Intl.message(
      'Voir les démos vidéo',
      name: 'helpWatchDemos',
      desc: '',
      args: [],
    );
  }

  /// `Salut`
  String get hi {
    return Intl.message('Salut', name: 'hi', desc: '', args: []);
  }

  /// `Accueil`
  String get homePage {
    return Intl.message('Accueil', name: 'homePage', desc: '', args: []);
  }

  /// `Démo IFrame`
  String get iframeDemo {
    return Intl.message('Démo IFrame', name: 'iframeDemo', desc: '', args: []);
  }

  /// `Ce champ nécessite un entier valide.`
  String get integerErrorText {
    return Intl.message(
      'Ce champ nécessite un entier valide.',
      name: 'integerErrorText',
      desc: '',
      args: [],
    );
  }

  /// `Ce champ nécessite une IP valide.`
  String get ipErrorText {
    return Intl.message(
      'Ce champ nécessite une IP valide.',
      name: 'ipErrorText',
      desc: '',
      args: [],
    );
  }

  /// `Langue`
  String get language {
    return Intl.message('Langue', name: 'language', desc: '', args: []);
  }

  /// `Nom`
  String get lastName {
    return Intl.message('Nom', name: 'lastName', desc: '', args: []);
  }

  /// `Conditions Générales de Vente - Rapport de trésorerie`
  String get legalDocTitleCgvAccountingReportFr {
    return Intl.message(
      'Conditions Générales de Vente - Rapport de trésorerie',
      name: 'legalDocTitleCgvAccountingReportFr',
      desc: '',
      args: [],
    );
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

  /// `Référence du document`
  String get legalDocumentVersionId {
    return Intl.message(
      'Référence du document',
      name: 'legalDocumentVersionId',
      desc: '',
      args: [],
    );
  }

  /// `Thème Clair`
  String get lightTheme {
    return Intl.message('Thème Clair', name: 'lightTheme', desc: '', args: []);
  }

  /// `Connexion`
  String get login {
    return Intl.message('Connexion', name: 'login', desc: '', args: []);
  }

  /// `Connectez-vous`
  String get loginNow {
    return Intl.message('Connectez-vous', name: 'loginNow', desc: '', args: []);
  }

  /// `Déconnexion`
  String get logout {
    return Intl.message('Déconnexion', name: 'logout', desc: '', args: []);
  }

  /// `Rester connecté`
  String get stayConnected {
    return Intl.message(
      'Rester connecté',
      name: 'stayConnected',
      desc: '',
      args: [],
    );
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

  /// `La valeur ne correspond pas au motif.`
  String get matchErrorText {
    return Intl.message(
      'La valeur ne correspond pas au motif.',
      name: 'matchErrorText',
      desc: '',
      args: [],
    );
  }

  /// `La valeur doit être inférieure ou égale à {max}.`
  String maxErrorText(Object max) {
    return Intl.message(
      'La valeur doit être inférieure ou égale à $max.',
      name: 'maxErrorText',
      desc: '',
      args: [max],
    );
  }

  /// `La longueur doit être inférieure ou égale à {maxLength}.`
  String maxLengthErrorText(Object maxLength) {
    return Intl.message(
      'La longueur doit être inférieure ou égale à $maxLength.',
      name: 'maxLengthErrorText',
      desc: '',
      args: [maxLength],
    );
  }

  /// `Accès`
  String get menuAccesses {
    return Intl.message('Accès', name: 'menuAccesses', desc: '', args: []);
  }

  /// `Offres Weebi`
  String get menuBilling {
    return Intl.message(
      'Offres Weebi',
      name: 'menuBilling',
      desc: '',
      args: [],
    );
  }

  /// `Mes Boutiques`
  String get menuBoutiques {
    return Intl.message(
      'Mes Boutiques',
      name: 'menuBoutiques',
      desc: '',
      args: [],
    );
  }

  /// `Articles`
  String get menuCatalog {
    return Intl.message('Articles', name: 'menuCatalog', desc: '', args: []);
  }

  /// `Contacts`
  String get menuContacts {
    return Intl.message('Contacts', name: 'menuContacts', desc: '', args: []);
  }

  /// `Cliquez sur + pour créer un enregistrement.`
  String get entityEmptyHint {
    return Intl.message(
      'Cliquez sur + pour créer un enregistrement.',
      name: 'entityEmptyHint',
      desc: '',
      args: [],
    );
  }

  /// `Créer`
  String get entityCreate {
    return Intl.message('Créer', name: 'entityCreate', desc: '', args: []);
  }

  /// `Modifier`
  String get entityEdit {
    return Intl.message('Modifier', name: 'entityEdit', desc: '', args: []);
  }

  /// `Supprimer`
  String get entityDelete {
    return Intl.message('Supprimer', name: 'entityDelete', desc: '', args: []);
  }

  /// `Ajouter un sous-article`
  String get entityAddSku {
    return Intl.message(
      'Ajouter un sous-article',
      name: 'entityAddSku',
      desc: '',
      args: [],
    );
  }

  /// `Supprimer cet enregistrement ?`
  String get entityConfirmDelete {
    return Intl.message(
      'Supprimer cet enregistrement ?',
      name: 'entityConfirmDelete',
      desc: '',
      args: [],
    );
  }

  /// `Tous`
  String get statusAll {
    return Intl.message('Tous', name: 'statusAll', desc: '', args: []);
  }

  /// `Actif`
  String get statusActive {
    return Intl.message('Actif', name: 'statusActive', desc: '', args: []);
  }

  /// `Inactif`
  String get statusInactive {
    return Intl.message('Inactif', name: 'statusInactive', desc: '', args: []);
  }

  /// `Créer un article`
  String get catalogNewProduct {
    return Intl.message(
      'Créer un article',
      name: 'catalogNewProduct',
      desc: '',
      args: [],
    );
  }

  /// `Modifier l'article`
  String get catalogEditProduct {
    return Intl.message(
      'Modifier l\'article',
      name: 'catalogEditProduct',
      desc: '',
      args: [],
    );
  }

  /// `Saisir le libellé`
  String get catalogEnterTitle {
    return Intl.message(
      'Saisir le libellé',
      name: 'catalogEnterTitle',
      desc: '',
      args: [],
    );
  }

  /// `Un article avec ce libellé existe déjà`
  String get catalogTitleTaken {
    return Intl.message(
      'Un article avec ce libellé existe déjà',
      name: 'catalogTitleTaken',
      desc: '',
      args: [],
    );
  }

  /// `Saisir le prix de vente`
  String get catalogEnterPrice {
    return Intl.message(
      'Saisir le prix de vente',
      name: 'catalogEnterPrice',
      desc: '',
      args: [],
    );
  }

  /// `erreur`
  String get catalogInvalidNumber {
    return Intl.message(
      'erreur',
      name: 'catalogInvalidNumber',
      desc: '',
      args: [],
    );
  }

  /// `exemple : 1.5 et non pas 1,5`
  String get catalogInvalidUnits {
    return Intl.message(
      'exemple : 1.5 et non pas 1,5',
      name: 'catalogInvalidUnits',
      desc: '',
      args: [],
    );
  }

  /// `Libellé`
  String get catalogColumnTitle {
    return Intl.message(
      'Libellé',
      name: 'catalogColumnTitle',
      desc: '',
      args: [],
    );
  }

  /// `Catégorie`
  String get catalogColumnCategory {
    return Intl.message(
      'Catégorie',
      name: 'catalogColumnCategory',
      desc: '',
      args: [],
    );
  }

  /// `Désignation`
  String get catalogColumnDesignation {
    return Intl.message(
      'Désignation',
      name: 'catalogColumnDesignation',
      desc: '',
      args: [],
    );
  }

  /// `Prix de vente`
  String get catalogColumnPrice {
    return Intl.message(
      'Prix de vente',
      name: 'catalogColumnPrice',
      desc: '',
      args: [],
    );
  }

  /// `Code barre`
  String get catalogColumnBarcode {
    return Intl.message(
      'Code barre',
      name: 'catalogColumnBarcode',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get catalogColumnKind {
    return Intl.message('Type', name: 'catalogColumnKind', desc: '', args: []);
  }

  /// `Statut`
  String get catalogColumnStatus {
    return Intl.message(
      'Statut',
      name: 'catalogColumnStatus',
      desc: '',
      args: [],
    );
  }

  /// `Caractéristiques`
  String get catalogIdentity {
    return Intl.message(
      'Caractéristiques',
      name: 'catalogIdentity',
      desc: '',
      args: [],
    );
  }

  /// `Vente`
  String get catalogSelling {
    return Intl.message('Vente', name: 'catalogSelling', desc: '', args: []);
  }

  /// `Sous-articles`
  String get catalogVariants {
    return Intl.message(
      'Sous-articles',
      name: 'catalogVariants',
      desc: '',
      args: [],
    );
  }

  /// `Unité de compte`
  String get catalogStockUnit {
    return Intl.message(
      'Unité de compte',
      name: 'catalogStockUnit',
      desc: '',
      args: [],
    );
  }

  /// `Unités/article`
  String get catalogUnitsInOnePiece {
    return Intl.message(
      'Unités/article',
      name: 'catalogUnitsInOnePiece',
      desc: '',
      args: [],
    );
  }

  /// `Créer un contact`
  String get contactNew {
    return Intl.message(
      'Créer un contact',
      name: 'contactNew',
      desc: '',
      args: [],
    );
  }

  /// `Modifier le contact`
  String get contactEdit {
    return Intl.message(
      'Modifier le contact',
      name: 'contactEdit',
      desc: '',
      args: [],
    );
  }

  /// `Détails`
  String get contactDetails {
    return Intl.message('Détails', name: 'contactDetails', desc: '', args: []);
  }

  /// `Adresse`
  String get contactAddress {
    return Intl.message('Adresse', name: 'contactAddress', desc: '', args: []);
  }

  /// `Prénom`
  String get contactFirstName {
    return Intl.message('Prénom', name: 'contactFirstName', desc: '', args: []);
  }

  /// `Nom de famille`
  String get contactLastName {
    return Intl.message(
      'Nom de famille',
      name: 'contactLastName',
      desc: '',
      args: [],
    );
  }

  /// `Saisir le prénom`
  String get contactEnterFirstName {
    return Intl.message(
      'Saisir le prénom',
      name: 'contactEnterFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Saisir le nom de famille`
  String get contactEnterLastName {
    return Intl.message(
      'Saisir le nom de famille',
      name: 'contactEnterLastName',
      desc: '',
      args: [],
    );
  }

  /// `Le numéro doit comporter au moins 8 chiffres`
  String get contactPhoneTooShort {
    return Intl.message(
      'Le numéro doit comporter au moins 8 chiffres',
      name: 'contactPhoneTooShort',
      desc: '',
      args: [],
    );
  }

  /// `L'adresse mail n'est pas correcte`
  String get contactEmailInvalid {
    return Intl.message(
      'L\'adresse mail n\'est pas correcte',
      name: 'contactEmailInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Mail`
  String get contactMail {
    return Intl.message('Mail', name: 'contactMail', desc: '', args: []);
  }

  /// `Téléphone`
  String get contactPhone {
    return Intl.message('Téléphone', name: 'contactPhone', desc: '', args: []);
  }

  /// `Crédit maximum`
  String get contactOverdraft {
    return Intl.message(
      'Crédit maximum',
      name: 'contactOverdraft',
      desc: '',
      args: [],
    );
  }

  /// `Client`
  String get contactIsClient {
    return Intl.message('Client', name: 'contactIsClient', desc: '', args: []);
  }

  /// `Fournisseur`
  String get contactIsSupplier {
    return Intl.message(
      'Fournisseur',
      name: 'contactIsSupplier',
      desc: '',
      args: [],
    );
  }

  /// `Rue`
  String get contactStreet {
    return Intl.message('Rue', name: 'contactStreet', desc: '', args: []);
  }

  /// `Code postal`
  String get contactPostCode {
    return Intl.message(
      'Code postal',
      name: 'contactPostCode',
      desc: '',
      args: [],
    );
  }

  /// `Ville`
  String get contactCity {
    return Intl.message('Ville', name: 'contactCity', desc: '', args: []);
  }

  /// `Pays`
  String get contactCountry {
    return Intl.message('Pays', name: 'contactCountry', desc: '', args: []);
  }

  /// `Appareils`
  String get menuDevices {
    return Intl.message('Appareils', name: 'menuDevices', desc: '', args: []);
  }

  /// `Mon entreprise`
  String get menuFirm {
    return Intl.message('Mon entreprise', name: 'menuFirm', desc: '', args: []);
  }

  /// `Les articles, contacts et opérations (ventes, achats, mouvements de stock, etc.) sont uniquement disponibles sur l'application de caisse pour l'instant.`
  String get menuScopeDisclaimer {
    return Intl.message(
      'Les articles, contacts et opérations (ventes, achats, mouvements de stock, etc.) sont uniquement disponibles sur l\'application de caisse pour l\'instant.',
      name: 'menuScopeDisclaimer',
      desc: '',
      args: [],
    );
  }

  /// `Les contacts et opérations (ventes, achats, mouvements de stock, etc.) sont uniquement disponibles sur l'application de caisse pour l'instant. La découverte de catalogue et les tickets sont disponibles ici.`
  String get menuScopeDisclaimerDev {
    return Intl.message(
      'Les contacts et opérations (ventes, achats, mouvements de stock, etc.) sont uniquement disponibles sur l\'application de caisse pour l\'instant. La découverte de catalogue et les tickets sont disponibles ici.',
      name: 'menuScopeDisclaimerDev',
      desc: '',
      args: [],
    );
  }

  /// `Statistiques`
  String get menuStats {
    return Intl.message('Statistiques', name: 'menuStats', desc: '', args: []);
  }

  /// `Tickets`
  String get menuTickets {
    return Intl.message('Tickets', name: 'menuTickets', desc: '', args: []);
  }

  /// `Utilisateurs`
  String get menuUsers {
    return Intl.message('Utilisateurs', name: 'menuUsers', desc: '', args: []);
  }

  /// `La valeur doit être supérieure ou égale à {min}.`
  String minErrorText(Object min) {
    return Intl.message(
      'La valeur doit être supérieure ou égale à $min.',
      name: 'minErrorText',
      desc: '',
      args: [min],
    );
  }

  /// `La longueur doit être supérieure ou égale à {minLength}.`
  String minLengthErrorText(Object minLength) {
    return Intl.message(
      'La longueur doit être supérieure ou égale à $minLength.',
      name: 'minLengthErrorText',
      desc: '',
      args: [minLength],
    );
  }

  /// `Mon Profil`
  String get myProfile {
    return Intl.message('Mon Profil', name: 'myProfile', desc: '', args: []);
  }

  /// `{count, plural, one{Nouvelle Commande} other{Nouvelles Commandes}}`
  String newOrders(num count) {
    return Intl.plural(
      count,
      one: 'Nouvelle Commande',
      other: 'Nouvelles Commandes',
      name: 'newOrders',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{Nouvel Utilisateur} other{Nouveaux Utilisateurs}}`
  String newUsers(num count) {
    return Intl.plural(
      count,
      one: 'Nouvel Utilisateur',
      other: 'Nouveaux Utilisateurs',
      name: 'newUsers',
      desc: '',
      args: [count],
    );
  }

  /// `La valeur de ce champ ne doit pas être égale à {value}.`
  String notEqualErrorText(Object value) {
    return Intl.message(
      'La valeur de ce champ ne doit pas être égale à $value.',
      name: 'notEqualErrorText',
      desc: '',
      args: [value],
    );
  }

  /// `La valeur doit être numérique.`
  String get numericErrorText {
    return Intl.message(
      'La valeur doit être numérique.',
      name: 'numericErrorText',
      desc: '',
      args: [],
    );
  }

  /// `Ouvrir dans un nouvel onglet`
  String get openInNewTab {
    return Intl.message(
      'Ouvrir dans un nouvel onglet',
      name: 'openInNewTab',
      desc: '',
      args: [],
    );
  }

  /// `L'administrateur de votre entreprise doit vous attribuer une license active, ou vous devez vous connecter avec le compte créateur de l'entreprise, avant d'accéder aux tickets, articles et contacts. Ouvrez Facturation si vous gérez les licences.`
  String get operationalLicenseBlockedBody {
    return Intl.message(
      'L\'administrateur de votre entreprise doit vous attribuer une license active, ou vous devez vous connecter avec le compte créateur de l\'entreprise, avant d\'accéder aux tickets, articles et contacts. Ouvrez Facturation si vous gérez les licences.',
      name: 'operationalLicenseBlockedBody',
      desc: '',
      args: [],
    );
  }

  /// `Licence active requise`
  String get operationalLicenseBlockedTitle {
    return Intl.message(
      'Licence active requise',
      name: 'operationalLicenseBlockedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Facturation`
  String get operationalLicenseOpenBilling {
    return Intl.message(
      'Facturation',
      name: 'operationalLicenseOpenBilling',
      desc: '',
      args: [],
    );
  }

  /// `Réessayer`
  String get operationalLicenseRetry {
    return Intl.message(
      'Réessayer',
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

  /// `Mot de Passe`
  String get password {
    return Intl.message('Mot de Passe', name: 'password', desc: '', args: []);
  }

  /// `Les mots de passe ne correspondent pas.`
  String get passwordNotMatch {
    return Intl.message(
      'Les mots de passe ne correspondent pas.',
      name: 'passwordNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `L'e-mail de réinitialisation du mot de passe a été envoyé.`
  String get passwordResetEmailSent {
    return Intl.message(
      'L\'e-mail de réinitialisation du mot de passe a été envoyé.',
      name: 'passwordResetEmailSent',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{Problème en Attente} other{Problèmes en Attente}}`
  String pendingIssues(num count) {
    return Intl.plural(
      count,
      one: 'Problème en Attente',
      other: 'Problèmes en Attente',
      name: 'pendingIssues',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{Commande Récente} other{Commandes Récentes}}`
  String recentOrders(num count) {
    return Intl.plural(
      count,
      one: 'Commande Récente',
      other: 'Commandes Récentes',
      name: 'recentOrders',
      desc: '',
      args: [count],
    );
  }

  /// `Enregistrement supprimé avec succès.`
  String get recordDeletedSuccessfully {
    return Intl.message(
      'Enregistrement supprimé avec succès.',
      name: 'recordDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Enregistrement sauvegardé avec succès.`
  String get recordSavedSuccessfully {
    return Intl.message(
      'Enregistrement sauvegardé avec succès.',
      name: 'recordSavedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Enregistrement soumis avec succès.`
  String get recordSubmittedSuccessfully {
    return Intl.message(
      'Enregistrement soumis avec succès.',
      name: 'recordSubmittedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Actualiser`
  String get refreshAction {
    return Intl.message(
      'Actualiser',
      name: 'refreshAction',
      desc: '',
      args: [],
    );
  }

  /// `S'inscrire`
  String get register {
    return Intl.message('S\'inscrire', name: 'register', desc: '', args: []);
  }

  /// `Créer un nouveau compte`
  String get registerANewAccount {
    return Intl.message(
      'Créer un nouveau compte',
      name: 'registerANewAccount',
      desc: '',
      args: [],
    );
  }

  /// `Inscrivez-vous`
  String get registerNow {
    return Intl.message(
      'Inscrivez-vous',
      name: 'registerNow',
      desc: '',
      args: [],
    );
  }

  /// `Ce champ ne peut pas être vide.`
  String get requiredErrorText {
    return Intl.message(
      'Ce champ ne peut pas être vide.',
      name: 'requiredErrorText',
      desc: '',
      args: [],
    );
  }

  /// `Retaper le Mot de Passe`
  String get retypePassword {
    return Intl.message(
      'Retaper le Mot de Passe',
      name: 'retypePassword',
      desc: '',
      args: [],
    );
  }

  /// `Sauvegarder`
  String get save {
    return Intl.message('Sauvegarder', name: 'save', desc: '', args: []);
  }

  /// `Rechercher`
  String get search {
    return Intl.message('Rechercher', name: 'search', desc: '', args: []);
  }

  /// `Toutes`
  String get statsAll {
    return Intl.message('Toutes', name: 'statsAll', desc: '', args: []);
  }

  /// `Recettes (toutes)`
  String get statsMetricAllIncome {
    return Intl.message(
      'Recettes (toutes)',
      name: 'statsMetricAllIncome',
      desc: '',
      args: [],
    );
  }

  /// `Dépenses (toutes)`
  String get statsMetricAllSpending {
    return Intl.message(
      'Dépenses (toutes)',
      name: 'statsMetricAllSpending',
      desc: '',
      args: [],
    );
  }

  /// `Encaissements`
  String get statsMetricCashflowIncome {
    return Intl.message(
      'Encaissements',
      name: 'statsMetricCashflowIncome',
      desc: '',
      args: [],
    );
  }

  /// `Décaissements`
  String get statsMetricCashflowSpending {
    return Intl.message(
      'Décaissements',
      name: 'statsMetricCashflowSpending',
      desc: '',
      args: [],
    );
  }

  /// `Vous n'avez pas l'autorisation de consulter les statistiques. Demandez à l'administrateur de votre entreprise de vous accorder l'accès.`
  String get statsNoAccess {
    return Intl.message(
      'Vous n\'avez pas l\'autorisation de consulter les statistiques. Demandez à l\'administrateur de votre entreprise de vous accorder l\'accès.',
      name: 'statsNoAccess',
      desc: '',
      args: [],
    );
  }

  /// `Aucune donnée disponible`
  String get statsNoDataAvailable {
    return Intl.message(
      'Aucune donnée disponible',
      name: 'statsNoDataAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Jour`
  String get statsPeriodDay {
    return Intl.message('Jour', name: 'statsPeriodDay', desc: '', args: []);
  }

  /// `Mois`
  String get statsPeriodMonth {
    return Intl.message('Mois', name: 'statsPeriodMonth', desc: '', args: []);
  }

  /// `Semaine`
  String get statsPeriodWeek {
    return Intl.message('Semaine', name: 'statsPeriodWeek', desc: '', args: []);
  }

  /// `Sélectionner les Boutiques :`
  String get statsSelectBoutiques {
    return Intl.message(
      'Sélectionner les Boutiques :',
      name: 'statsSelectBoutiques',
      desc: '',
      args: [],
    );
  }

  /// `Empilé par Boutique`
  String get statsStackedByBoutique {
    return Intl.message(
      'Empilé par Boutique',
      name: 'statsStackedByBoutique',
      desc: '',
      args: [],
    );
  }

  /// `Soumettre`
  String get submit {
    return Intl.message('Soumettre', name: 'submit', desc: '', args: []);
  }

  /// `Support`
  String get support {
    return Intl.message('Support', name: 'support', desc: '', args: []);
  }

  /// `Discuter avec le support Weebi`
  String get supportChatWhatsApp {
    return Intl.message(
      'Discuter avec le support Weebi',
      name: 'supportChatWhatsApp',
      desc: '',
      args: [],
    );
  }

  /// `Nous envoyer un e-mail`
  String get supportEmailUs {
    return Intl.message(
      'Nous envoyer un e-mail',
      name: 'supportEmailUs',
      desc: '',
      args: [],
    );
  }

  /// `Texte`
  String get text {
    return Intl.message('Texte', name: 'text', desc: '', args: []);
  }

  /// `Accentuation du Texte`
  String get textEmphasis {
    return Intl.message(
      'Accentuation du Texte',
      name: 'textEmphasis',
      desc: '',
      args: [],
    );
  }

  /// `Thème du Texte`
  String get textTheme {
    return Intl.message(
      'Thème du Texte',
      name: 'textTheme',
      desc: '',
      args: [],
    );
  }

  /// `Détail du ticket n°{ticketId}`
  String ticketDetailTitle(String ticketId) {
    return Intl.message(
      'Détail du ticket n°$ticketId',
      name: 'ticketDetailTitle',
      desc: '',
      args: [ticketId],
    );
  }

  /// `{count} art.`
  String ticketItemsShort(num count) {
    return Intl.message(
      '$count art.',
      name: 'ticketItemsShort',
      desc: '',
      args: [count],
    );
  }

  /// `Ticket non fourni`
  String get ticketNotProvided {
    return Intl.message(
      'Ticket non fourni',
      name: 'ticketNotProvided',
      desc: '',
      args: [],
    );
  }

  /// `Toutes les boutiques`
  String get ticketsBoutiqueAll {
    return Intl.message(
      'Toutes les boutiques',
      name: 'ticketsBoutiqueAll',
      desc: '',
      args: [],
    );
  }

  /// `Boutique`
  String get ticketsBoutiqueFallback {
    return Intl.message(
      'Boutique',
      name: 'ticketsBoutiqueFallback',
      desc: '',
      args: [],
    );
  }

  /// `Chaîne non disponible`
  String get ticketsChainUnavailable {
    return Intl.message(
      'Chaîne non disponible',
      name: 'ticketsChainUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Montant`
  String get ticketsColumnAmount {
    return Intl.message(
      'Montant',
      name: 'ticketsColumnAmount',
      desc: '',
      args: [],
    );
  }

  /// `Boutique`
  String get ticketsColumnBoutique {
    return Intl.message(
      'Boutique',
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

  /// `Date · n°`
  String get ticketsColumnDateAndNumber {
    return Intl.message(
      'Date · n°',
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

  /// `Toutes les dates`
  String get ticketsDateAll {
    return Intl.message(
      'Toutes les dates',
      name: 'ticketsDateAll',
      desc: '',
      args: [],
    );
  }

  /// `Supprimés`
  String get ticketsDeletedChip {
    return Intl.message(
      'Supprimés',
      name: 'ticketsDeletedChip',
      desc: '',
      args: [],
    );
  }

  /// `Non supprimés`
  String get ticketsDeletedExclude {
    return Intl.message(
      'Non supprimés',
      name: 'ticketsDeletedExclude',
      desc: '',
      args: [],
    );
  }

  /// `Supprimés uniquement`
  String get ticketsDeletedOnly {
    return Intl.message(
      'Supprimés uniquement',
      name: 'ticketsDeletedOnly',
      desc: '',
      args: [],
    );
  }

  /// `Aucun ticket`
  String get ticketsEmpty {
    return Intl.message(
      'Aucun ticket',
      name: 'ticketsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Filtres`
  String get ticketsFiltersTitle {
    return Intl.message(
      'Filtres',
      name: 'ticketsFiltersTitle',
      desc: '',
      args: [],
    );
  }

  /// `Grouper par boutique`
  String get ticketsGroupByBoutique {
    return Intl.message(
      'Grouper par boutique',
      name: 'ticketsGroupByBoutique',
      desc: '',
      args: [],
    );
  }

  /// `Carte`
  String get ticketsPaymentCard {
    return Intl.message(
      'Carte',
      name: 'ticketsPaymentCard',
      desc: '',
      args: [],
    );
  }

  /// `Espèces`
  String get ticketsPaymentCash {
    return Intl.message(
      'Espèces',
      name: 'ticketsPaymentCash',
      desc: '',
      args: [],
    );
  }

  /// `Chèque`
  String get ticketsPaymentCheque {
    return Intl.message(
      'Chèque',
      name: 'ticketsPaymentCheque',
      desc: '',
      args: [],
    );
  }

  /// `Crédit`
  String get ticketsPaymentCredit {
    return Intl.message(
      'Crédit',
      name: 'ticketsPaymentCredit',
      desc: '',
      args: [],
    );
  }

  /// `Marchandises`
  String get ticketsPaymentGoods {
    return Intl.message(
      'Marchandises',
      name: 'ticketsPaymentGoods',
      desc: '',
      args: [],
    );
  }

  /// `Mobile Money`
  String get ticketsPaymentMobileMoney {
    return Intl.message(
      'Mobile Money',
      name: 'ticketsPaymentMobileMoney',
      desc: '',
      args: [],
    );
  }

  /// `—`
  String get ticketsPaymentUnknown {
    return Intl.message('—', name: 'ticketsPaymentUnknown', desc: '', args: []);
  }

  /// `Licence active requise`
  String get ticketsSeatEntitlementSubtitle {
    return Intl.message(
      'Licence active requise',
      name: 'ticketsSeatEntitlementSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Le filtre et le groupement par boutique exigent une licence.`
  String get ticketsSeatGatedBoutiqueViewsDetail {
    return Intl.message(
      'Le filtre et le groupement par boutique exigent une licence.',
      name: 'ticketsSeatGatedBoutiqueViewsDetail',
      desc: '',
      args: [],
    );
  }

  /// `Filtre et groupement par boutique`
  String get ticketsSeatGatedBoutiqueViewsTitle {
    return Intl.message(
      'Filtre et groupement par boutique',
      name: 'ticketsSeatGatedBoutiqueViewsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Ordre chronologique`
  String get ticketsSortChronological {
    return Intl.message(
      'Ordre chronologique',
      name: 'ticketsSortChronological',
      desc: '',
      args: [],
    );
  }

  /// `Actifs`
  String get ticketsStatusActive {
    return Intl.message(
      'Actifs',
      name: 'ticketsStatusActive',
      desc: '',
      args: [],
    );
  }

  /// `Tous`
  String get ticketsStatusAll {
    return Intl.message('Tous', name: 'ticketsStatusAll', desc: '', args: []);
  }

  /// `Inactifs`
  String get ticketsStatusInactive {
    return Intl.message(
      'Inactifs',
      name: 'ticketsStatusInactive',
      desc: '',
      args: [],
    );
  }

  /// `Toutes les dates`
  String get ticketsTooltipClearDates {
    return Intl.message(
      'Toutes les dates',
      name: 'ticketsTooltipClearDates',
      desc: '',
      args: [],
    );
  }

  /// `Filtrer par boutique`
  String get ticketsTooltipFilterBoutique {
    return Intl.message(
      'Filtrer par boutique',
      name: 'ticketsTooltipFilterBoutique',
      desc: '',
      args: [],
    );
  }

  /// `Filtrer par statut`
  String get ticketsTooltipFilterByStatus {
    return Intl.message(
      'Filtrer par statut',
      name: 'ticketsTooltipFilterByStatus',
      desc: '',
      args: [],
    );
  }

  /// `Filtrer par tickets supprimés`
  String get ticketsTooltipFilterDeleted {
    return Intl.message(
      'Filtrer par tickets supprimés',
      name: 'ticketsTooltipFilterDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Actualiser`
  String get ticketsTooltipRefresh {
    return Intl.message(
      'Actualiser',
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

  /// `Ventes d'Aujourd'hui`
  String get todaySales {
    return Intl.message(
      'Ventes d\'Aujourd\'hui',
      name: 'todaySales',
      desc: '',
      args: [],
    );
  }

  /// `Typographie`
  String get typography {
    return Intl.message('Typographie', name: 'typography', desc: '', args: []);
  }

  /// `{count, plural, one{Élément UI} other{Éléments UI}}`
  String uiElements(num count) {
    return Intl.plural(
      count,
      one: 'Élément UI',
      other: 'Éléments UI',
      name: 'uiElements',
      desc: '',
      args: [count],
    );
  }

  /// `Ce champ nécessite une adresse URL valide.`
  String get urlErrorText {
    return Intl.message(
      'Ce champ nécessite une adresse URL valide.',
      name: 'urlErrorText',
      desc: '',
      args: [],
    );
  }

  /// `Nom d'Utilisateur`
  String get username {
    return Intl.message(
      'Nom d\'Utilisateur',
      name: 'username',
      desc: '',
      args: [],
    );
  }

  /// `Oui`
  String get yes {
    return Intl.message('Oui', name: 'yes', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<Lang> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'en'),
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
