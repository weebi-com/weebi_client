import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:provider/provider.dart';
import 'package:users_weebi/users_weebi.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/core/billing/load_firm_licenses.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

/// Users view using users_weebi package, embedded in the app's
/// [PortalMasterLayout] so global navigation (back to home, sidebar) remains available.
///
/// A nested [Navigator] matches [AccessesPackageScreen]: [UserRoutes.navigateToUserDetailView]
/// pushes onto this stack instead of the root navigator, so the drawer / sidebar stay visible.
class UsersPackageScreen extends StatefulWidget {
  const UsersPackageScreen({super.key});

  @override
  State<UsersPackageScreen> createState() => _UsersPackageScreenState();
}

class _UsersPackageScreenState extends State<UsersPackageScreen> {
  Iterable<License>? _firmLicenses;
  /// Bumps once when license payload arrives so the nested [Navigator] rebuilds
  /// its initial route with [firmLicenses] (otherwise the first frame stays stale).
  int _licenseNavEpoch = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final licenses = await loadFirmLicensesIfPermitted(context);
      if (!mounted) return;
      setState(() {
        _firmLicenses = licenses;
        _licenseNavEpoch++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final permissionProvider = context.read<PermissionProvider>();
    final currentUserId = permissionProvider.userId;
    final firmLicenses = _firmLicenses;
    return PortalMasterLayout(
      selectedMenuUri: RouteUri.listUser,
      body: Navigator(
        key: ValueKey<int>(_licenseNavEpoch),
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (nestedContext) =>
                UserRoutes.buildUserListWithCustomScaffold(
              currentUserId: currentUserId,
              appBar: null, // PortalMasterLayout provides the AppBar
              drawer: null,
              endDrawer: null,
              firmLicenses: firmLicenses,
              onCreateUser: () => nestedContext.push(RouteUri.createUser),
            ),
          );
        },
      ),
    );
  }
}
