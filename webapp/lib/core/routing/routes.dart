class RouteUri {
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String myProfile = '/my-profile';
  static const String logout = '/logout';
  static const String form = '/form';
  static const String generalUi = '/general-ui';
  static const String colors = '/colors';
  static const String text = '/text';
  static const String buttons = '/buttons';
  static const String dialogs = '/dialogs';
  static const String error404 = '/404';
  static const String login = '/login';
  /// App->Web magic-link landing (exchanges one-time token for BFF session).
  static const String bridge = '/bridge';
  static const String register = '/register';
  static const String crud = '/crud';
  static const String crudDetail = '/crud-detail';
  static const String iframe = '/iframe';

  static const String firmDetail = '/firm';
  static const String createFirm = '/create-firm';

  static const String contacts = '/contacts';

  static const String listUser = '/users';
  static const String createUser = '/create-user';

  static const String listBoutique = '/boutiques';

  static const String listAccess = '/accesses';
  static const String listDevice = '/devices';

  static const String catalog = '/catalog';

  static const String ticketsOverview = '/tickets';
  static const String ticketDetail = '/tickets/detail';

  static const String help = '/help';
  static const String support = '/support';
  static const String about = '/about';

  static const String billing = '/billing';
  static const String stats = '/stats';

  /// Stable URL for English Enterprise license terms (shareable, citeable).
  static const String legalTermsEn = '/legal/terms';

  /// Stable URL for French CGV (shareable, citeable).
  static const String legalCgvFr = '/legal/cgv';

  /// Stable URL for French Syscohada CGV (shareable, citeable).
  static const String legalCgvAccountingReportFr = '/legal/cgv-accounting-report';
}

const List<String> unrestrictedRoutes = [
  RouteUri.error404,
  RouteUri.logout,
  RouteUri.login, // Remove this line for actual authentication flow.
  RouteUri.register, // Remove this line for actual authentication flow.
  RouteUri.bridge,
  RouteUri.legalTermsEn,
  RouteUri.legalCgvFr,
  RouteUri.legalCgvAccountingReportFr,
];

const List<String> publicRoutes = [
  // RouteUri.login, // Enable this line for actual authentication flow.
  // RouteUri.register, // Enable this line for actual authentication flow.
];
