import 'package:auth_weebi/auth_weebi.dart' show PermissionProvider;
import 'package:flutter/foundation.dart' show Listenable;
import 'package:go_router/go_router.dart';
import 'package:web_admin/contacts/view/contacts_page.dart';
import 'package:protos_weebi/protos_weebi_io.dart' show TicketPb, UserPublic;
import 'package:web_admin/core/routing/routes.dart';
import 'package:web_admin/core/routing/bridge_auth_redirect.dart';
import 'package:web_admin/environment.dart';
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
import 'package:web_admin/views/screens/authentication/bridge_screen.dart';
import 'package:web_admin/views/screens/authentication/login_screen.dart';
import 'package:web_admin/views/screens/authentication/logout_screen.dart';
import 'package:web_admin/views/screens/my_profile_screen.dart';
import 'package:web_admin/views/screens/authentication/register_screen.dart';
import 'package:web_admin/views/screens/text_screen.dart';
import 'package:web_admin/views/screens/accesses/accesses_package_screen.dart';
import 'package:web_admin/views/screens/devices/devices_package_screen.dart';
import 'package:web_admin/views/screens/tickets/ticket_detail_screen.dart';
import 'package:web_admin/views/screens/tickets/tickets_overview_screen.dart';
import 'package:web_admin/views/screens/users/create_user_screen.dart';
import 'package:web_admin/views/screens/users/users_package_screen.dart';
import 'package:web_admin/views/screens/help/help_screen.dart';
import 'package:web_admin/views/screens/support/support_screen.dart';
import 'package:web_admin/views/screens/about/about_screen.dart';
import 'package:web_admin/views/screens/billing/billing_screen.dart';
import 'package:web_admin/views/screens/catalog/catalog_discovery_screen.dart';
import 'package:web_admin/views/screens/stats_screen.dart';
import 'package:web_admin/views/screens/legal/legal_document_screen.dart';

GoRouter appRouter(
  UserDataProvider userDataProvider,
  PermissionProvider permissionProvider, {
  Uri? browserUri,
}) {
  final uri = browserUri ?? Uri.base;
  return GoRouter(
    refreshListenable:
        Listenable.merge([permissionProvider, userDataProvider]),
    // Prefer hash deep links (#/bridge) so cold start after async prefs boot
    // does not fall back to `/` → dashboard → login and drop the magic link.
    initialLocation: resolveGoRouterInitialLocation(uri),
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
        path: RouteUri.bridge,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const BridgeScreen(),
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
          final extra = state.extra;
          final args = extra is AccessesOpenArgs
              ? extra
              : extra is UserPublic
                  ? AccessesOpenArgs(user: extra)
                  : const AccessesOpenArgs();
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: AccessesPackageScreen(
              initialUser: args.user,
              returnToUsersOnSave: args.returnToUsersOnSave,
            ),
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

      // =========================== CATALOG DISCOVERY ===========================

      GoRoute(
        path: RouteUri.catalog,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const CatalogDiscoveryScreen(),
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
      GoRoute(
        path: RouteUri.legalCgvAccountingReportFr,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const LegalDocumentScreen(
            document: EnterpriseLegalDocument.cgvAccountingReportFr,
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
      GoRoute(
        path: RouteUri.stats,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const StatsScreen(),
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
      if (state.matchedLocation == RouteUri.catalog && !Config.isDev) {
        return RouteUri.dashboard;
      }

      return resolveAuthRedirect(
        matchedLocation: state.matchedLocation,
        isLoggedIn: userDataProvider.isUserLoggedIn(),
        hasFirm: permissionProvider.firmId.isNotEmpty,
        isServiceAccount: permissionProvider.isServiceAccount,
        isAuthCheckPending: userDataProvider.isBffSessionCheckPending,
        documentQuery: Uri.base.queryParameters,
        unrestrictedRoutes: unrestrictedRoutes,
        publicRoutes: publicRoutes,
      );
    },
  );
}
