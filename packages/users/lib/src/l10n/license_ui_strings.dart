/// French UI copy for licence and seat messaging.
///
/// Defaults are in French (primary audience). General copy avoids assuming a
/// licenses or credits UI; admin surfaces may still link to [cloudLicensesPortalUrl] when relevant.
///
/// For full [intl] / ARB later, host apps can fork strings or inject overrides
/// at the widget level when you add parameters.
abstract final class LicenseUiStrings {
  /// Encadré bleu — création d’utilisateur.
  static const String createUserLicenseBannerBody =
      'Pour utiliser le service chaque utilisateur doit disposer d’une licence.';

  static String createUserSeatsSummary(int assigned, int total) =>
      'Licences en vigueur : $assigned licence${assigned == 1 ? '' : 's'} '
      'attribuée${assigned == 1 ? '' : 's'} sur $total.';

  static const String createUserNoValidLicenseSummary =
      'Aucune licence n’a été détectée. '
      'Achetez une ou plusieurs licences, puis attribuez les aux utilisateurs '
      'pour permettre un usage opérationnel du service.';

  static const String createUserPostCreateLicenseWarning =
      'Important : attribuez une licence active pour un usage opérationnel '
      'Indiquez aussi les boutiques auxquelles cet utilisateur peut accéder.';

  static const String userCreatedSuccessTitle = 'Utilisateur créé';

  static const String userCreatedSetUpAccessPrompt =
      'Souhaitez-vous configurer les accès ?';

  static const String userCreatedLater = 'Plus tard';

  static const String userCreatedSetUpNow = 'Configurer les accès';

  static const String userCreatedLaterSnackbar =
      'Utilisateur créé. Pensez à finaliser les accès et la licence.';

  static const String seatCardTitleActive = 'Licence active';

  static const String seatCardTitleNone = 'Aucune licence active';

  static const String seatCardSubtitleActive =
      'Cet utilisateur peut utiliser le service au quotidien, dans la limite de ses droits.';

  static const String seatCardSubtitleNone =
      'La connexion reste possible, mais l’usage quotidien du service exige une licence attribuée. '
      'Contactez l’administrateur de votre entreprise pour l’affectation depuis un outil d’administration autorisé.';

  /// Même situation « pas de siège », si l’utilisateur est créateur d’entreprise (joker opérationnel).
  static const String seatCardSubtitleNoneFirmCreator =
      'Aucune licence active : le créateur d’entreprise conserve toutefois un accès '
      'opérationnel limité (aperçu) sur certains flux serveur, sans équivalence d’abonnement. '
      'Attribuez une licence pour un usage complet et les fonctionnalités liées à la licence.';

  /// Encadré — écran d’accès boutiques / chaînes, lorsque les données de licence
  /// ne sont pas chargées par l’application.
  static const String accessOperationalLicenseNotice =
      'L’utilisation du service nécessite une licence active. '
      'Cette licence doit être attribuée à l\'utilisateur, en complément des accès '
      'définis ci-dessous.';

  /// Données licence présentes : siège actif pour cet utilisateur.
  static const String accessOperationalLicenseNoticeHasSeat =
      'Licence attribuée : cet utilisateur dispose d’un siège actif pour '
      'l’usage opérationnel. Les accès boutiques et chaînes ci-dessous précisent '
      'où il peut travailler.';

  /// Données licence présentes : aucun siège actif pour cet utilisateur.
  static const String accessOperationalLicenseNoticeNoSeat =
      'Aucune licence active n’est attribuée à cet utilisateur (ou le siège / '
      'la licence n’est plus valide). Pour un usage opérationnel quotidien, '
      'attribuez une licence en complément des accès définis ci-dessous.';

  /// Données licence présentes : pas de siège, mais créateur d’entreprise (joker
  /// opérationnel limité côté serveur — voir entitlements.md).
  static const String accessOperationalLicenseNoticeFirmCreatorJoker =
      'Créateur d’entreprise : cet utilisateur dispose d’un accès opérationnel '
      'restreint pour certains flux (tickets, articles, contacts) sans siège de '
      'licence — ce n’est pas un abonnement complet et cela ne remplace pas une '
      'licence attribuée. Pour les usages étendus, les autres utilisateurs et les '
      'fonctions liées à l’abonnement, attribuez un siège actif.';

  /// Portail licences et crédits (Weebi Cloud).
  static const String cloudLicensesPortalUrl = 'https://cloud.weebi.com/#/licenses';

  static const String accessOperationalLicenseOpenBilling =
      'Licences et crédits Weebi';

  /// Compact list-row label when the user has an active seat.
  static const String userListSeatBadgeActive = 'Siège actif';

  /// Compact list-row label when there is no active seat (non–firm-creator).
  static const String userListSeatBadgeNone = 'Sans siège';

  /// Firm creator without a seat (operational preview — see entitlements).
  static const String userListSeatBadgeCreator = 'Créateur';
}
