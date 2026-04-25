import 'package:boutiques_weebi/boutiques_weebi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

/// Boutiques view using boutiques_weebi package, embedded in the app's
/// [PortalMasterLayout] so global navigation (back to home, sidebar) remains available.
///
/// A nested [Navigator] keeps list → detail / create [Navigator.push] calls on this
/// stack instead of the root navigator, so the drawer / sidebar stay visible
/// (same pattern as the Users and Accesses package screens).
class BoutiquesPackageScreen extends StatelessWidget {
  const BoutiquesPackageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final permissionProvider = context.read<PermissionProvider>();
    return PortalMasterLayout(
      selectedMenuUri: RouteUri.listBoutique,
      body: Navigator(
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (nestedContext) =>
                BoutiqueRoutes.buildBoutiqueListWithCustomScaffold(
              appBar: null, // PortalMasterLayout provides the AppBar
              drawer: null,
              endDrawer: null,
              userPermissions: permissionProvider.userPermissions,
            ),
          );
        },
      ),
    );
  }
}
