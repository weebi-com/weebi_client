import 'package:auth_weebi/auth_weebi.dart' show PermissionProvider;
import 'package:flutter/foundation.dart' show Listenable;
import 'package:go_router/go_router.dart';
import 'package:web_admin/contacts/view/contacts_page.dart';
import 'package:web_admin/providers/user_data_provider.dart';
import 'package:web_admin/views/screens/buttons_screen.dart';
import 'package:web_admin/views/screens/boutiques/boutiques_package_screen.dart';
import 'package:web_admin/views/screens/colors_screen.dart';
import 'package:web_admin/views/screens/crud_detail_screen.dart';
import 'package:web_admin/views/screens/crud_screen.dart';
import 'package:web_admin/views/screens/dashboard_screen.dart';
import 'package:web_admin/views/screens/dialogs_screen.dart';
import 'package:web_admin/views/screens/error_screen.dart';
import 'package:web_admin/views/screens/firm/create_firm_screen.dart';
import 'package:web_admin/views/screens/firm/firm_view_screen.dart';
import 'package:web_admin/views/screens/general_ui_screen.dart';
import 'package:web_admin/views/screens/iframe_demo_screen.dart';
import 'package:web_admin/views/screens/authentication/login_screen.dart';
import 'package:web_admin/views/screens/authentication/logout_screen.dart';
import 'package:web_admin/views/screens/my_profile_screen.dart';
import 'package:web_admin/views/screens/authentication/register_screen.dart';
import 'package:web_admin/views/screens/text_screen.dart';
import 'package:web_admin/views/screens/accesses/accesses_package_screen.dart';
import 'package:protos_weebi/protos_weebi_io.dart' show TicketPb;
import 'package:web_admin/views/screens/devices/devices_package_screen.dart';
import 'package:web_admin/views/screens/tickets/ticket_detail_screen.dart';
import 'package:web_admin/views/screens/tickets/tickets_overview_screen.dart';
import 'package:web_admin/views/screens/users/create_user_screen.dart';
import 'package:web_admin/views/screens/users/users_package_screen.dart';
import 'package:web_admin/views/screens/help/help_screen.dart';
import 'package:web_admin/views/screens/support/support_screen.dart';
import 'package:web_admin/views/screens/about/about_screen.dart';
import 'package:web_admin/views/screens/billing/billing_screen.dart';
import 'package:web_admin/views/screens/legal/legal_document_screen.dart';

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

  static const String ticketsOverview = '/tickets';
  static const String ticketDetail = '/tickets/detail';

  static const String help = '/help';
  static const String support = '/support';
  static const String about = '/about';

  static const String billing = '/billing';

  /// Stable URL for English Enterprise license terms (shareable, citeable).
  static const String legalTermsEn = '/legal/terms';

  /// Stable URL for French CGV (shareable, citeable).
  static const String legalCgvFr = '/legal/cgv';
}

const List<String> unrestrictedRoutes = [
  RouteUri.error404,
  RouteUri.logout,
  RouteUri.login, // Remove this line for actual authentication flow.
  RouteUri.register, // Remove this line for actual authentication flow.
  RouteUri.legalTermsEn,
  RouteUri.legalCgvFr,
];

const List<String> publicRoutes = [
  // RouteUri.login, // Enable this line for actual authentication flow.
  // RouteUri.register, // Enable this line for actual authentication flow.
];

GoRouter appRouter(
  UserDataProvider userDataProvider,
  PermissionProvider permissionProvider,
) {
  return GoRouter(
    refreshListenable:
        Listenable.merge([permissionProvider, userDataProvider]),
    initialLocation: RouteUri.home,
    errorPageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const ErrorScreen(),
    ),
    routes: [
      GoRoute(
        path: RouteUri.home,
        redirect: (context, state) => RouteUri.dashboard,
      ),
      GoRoute(
        path: RouteUri.dashboard,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const DashboardScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.myProfile,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const MyProfileScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.logout,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const LogoutScreen(),
        ),
      ),
/*       GoRoute(
        path: RouteUri.form,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const FormScreen(),
        ),
      ), */
      GoRoute(
        path: RouteUri.generalUi,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const GeneralUiScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.colors,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ColorsScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.text,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const TextScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.buttons,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ButtonsScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.dialogs,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const DialogsScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.login,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.register,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const RegisterScreen(),
          );
        },
      ),
      GoRoute(
        path: RouteUri.crud,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const CrudScreen(),
          );
        },
      ),
      GoRoute(
        path: RouteUri.crudDetail,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: CrudDetailScreen(id: state.uri.queryParameters['id'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.iframe,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const IFrameDemoScreen(),
        ),
      ),

      // =========================== FIRMS ===========================

      GoRoute(
        path: RouteUri.firmDetail,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const FirmListScreen(),
          );
        },
      ),
      GoRoute(
        path: RouteUri.createFirm,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const CreateFirmScreen(),
          );
        },
      ),

      // =========================== USERS (package) ===========================

      GoRoute(
        path: RouteUri.listUser,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const UsersPackageScreen(),
          );
        },
      ),
      GoRoute(
        path: RouteUri.createUser,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const CreateUserScreen(),
          );
        },
      ),

      // =========================== BOUTIQUES (package) ===========================

      GoRoute(
        path: RouteUri.listBoutique,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const BoutiquesPackageScreen(),
          );
        },
      ),

      // =========================== ACCESSES (package) ===========================

      GoRoute(
        path: RouteUri.listAccess,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const AccessesPackageScreen(),
          );
        },
      ),

      // =========================== DEVICES (package) ===========================

      GoRoute(
        path: RouteUri.listDevice,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const DevicesPackageScreen(),
          );
        },
      ),

      // =========================== TICKETS ===========================

      GoRoute(
        path: RouteUri.ticketsOverview,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const TicketsOverviewScreen(),
          );
        },
      ),
      GoRoute(
        path: RouteUri.ticketDetail,
        pageBuilder: (context, state) {
          final ticket = state.extra as TicketPb?;
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: TicketDetailScreen(ticket: ticket),
          );
        },
      ),

      // =========================== HELP / SUPPORT / ABOUT ===========================

      GoRoute(
        path: RouteUri.help,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const HelpScreen(),
          );
        },
      ),
      GoRoute(
        path: RouteUri.support,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const SupportScreen(),
          );
        },
      ),
      GoRoute(
        path: RouteUri.about,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const AboutScreen(),
          );
        },
      ),

      // =========================== LEGAL (public, stable URLs) ===========================

      GoRoute(
        path: RouteUri.legalTermsEn,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const LegalDocumentScreen(
            document: EnterpriseLegalDocument.termsEn,
          ),
        ),
      ),
      GoRoute(
        path: RouteUri.legalCgvFr,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const LegalDocumentScreen(
            document: EnterpriseLegalDocument.cgvFr,
          ),
        ),
      ),

      // =========================== BILLING ===========================

      GoRoute(
        path: RouteUri.billing,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const BillingScreen(),
          );
        },
      ),

      // =========================== CONTACTS ===========================

      GoRoute(
        path: RouteUri.contacts,
        pageBuilder: (context, state) {
          // TODO: this needs to be flexible depending on the chain selected
          final chainId = state.extra as String;
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ContactsPage(chainId),
          );
        },
      ),
    ],
    redirect: (context, state) {
      if (unrestrictedRoutes.contains(state.matchedLocation)) {
        return null;
      } else if (publicRoutes.contains(state.matchedLocation)) {
        // Is public route.
        if (userDataProvider.isUserLoggedIn()) {
          // User is logged in, redirect to home page.
          return RouteUri.home;
        }
      } else {
        // Not public route.
        if (!userDataProvider.isUserLoggedIn()) {
          // User is not logged in, redirect to login page.
          return RouteUri.login;
        }
      }

      if (state.matchedLocation == RouteUri.billing &&
          userDataProvider.isUserLoggedIn()) {
        // Allow navigation to billing route; the screen itself will show "no access" if needed
        // In BFF mode, permissions may not be loaded yet from the session
      }

      return null;
    },
  );
}
