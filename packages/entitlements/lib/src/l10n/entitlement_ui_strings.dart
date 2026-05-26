/// French UI copy for licence attribution and portal entitlements.
///
/// Commercial model: `docs/commercial-model.md` — lifetime licences, **no subscriptions**;
/// credits are pay-as-you-go for consumption. Wording uses « licence » only (not « siège »).
abstract final class EntitlementUiStrings {
  /// Encadré bleu — création d’utilisateur.
  static const String createUserLicenseBannerBody =
      'Pour utiliser le service, chaque utilisateur doit disposer d’une licence.';

  static String createUserSeatsSummary(int assigned, int total) =>
      '$assigned licence${assigned == 1 ? '' : 's'} attribuée${assigned == 1 ? '' : 's'} '
      'sur $total.';

  static const String createUserNoValidLicenseSummary =
      'Aucune licence en vigueur. '
      'Achetez des licences, puis attribuez-les aux utilisateurs.';

  static const String createUserPostCreateLicenseWarning =
      'Attribuez une licence à cet utilisateur, puis définissez ses accès aux boutiques.';

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
      'Cet utilisateur peut utiliser le service, dans la limite de ses droits.';

  static const String seatCardSubtitleNone =
      'La connexion reste possible, mais l’usage du service exige une licence attribuée. '
      'Contactez l’administrateur de votre entreprise.';

  /// Créateur d’entreprise sans licence (aperçu limité côté serveur).
  static const String seatCardSubtitleNoneFirmCreator =
      'Aucune licence active : le créateur d’entreprise dispose d’un accès limité (aperçu). '
      'Attribuez une licence pour un usage complet.';

  /// Encadré — accès boutiques / chaînes, données de licence non chargées.
  static const String accessOperationalLicenseNotice =
      'L’utilisation du service nécessite une licence active attribuée à l’utilisateur, '
      'en complément des accès définis ci-dessous.';

  static const String accessOperationalLicenseNoticeHasSeat =
      'Licence active : cet utilisateur peut utiliser le service.';

  static const String accessOperationalLicenseNoticeNoSeat =
      'Aucune licence active pour cet utilisateur. '
      'Attribuez une licence en complément des accès ci-dessous.';

  /// Créateur d’entreprise sans licence (aperçu limité).
  static const String accessOperationalLicenseNoticeFirmCreatorJoker =
      'Créateur d’entreprise : accès limité (aperçu) sans licence. '
      'Attribuez une licence pour un usage complet et les fonctionnalités avancées.';

  /// Portail licences et crédits (Weebi Cloud).
  static const String cloudLicensesPortalUrl = 'https://cloud.weebi.com/#/licenses';

  static const String accessOperationalLicenseOpenBilling =
      'Licences et crédits Weebi';

  /// Pastille liste — utilisateur avec licence active.
  static const String userListSeatBadgeActive = 'Licence active';

  /// Pastille liste — utilisateur sans licence.
  static const String userListSeatBadgeNone = 'Sans licence';

  /// Créateur d’entreprise sans licence (aperçu).
  static const String userListSeatBadgeCreator = 'Créateur';
}

/// @nodoc
@Deprecated('Use EntitlementUiStrings from entitlements_weebi')
typedef LicenseUiStrings = EntitlementUiStrings;
