import 'package:boutiques_weebi/boutiques_weebi.dart';
import 'package:entitlements_weebi/entitlements_weebi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart'
    show BoutiqueMongo, Chain, License;
import 'package:web_admin/app_router.dart';
import 'package:web_admin/boutiques/business_rules_boutique_extensions.dart';
import 'package:web_admin/core/billing/load_firm_licenses.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

/// Boutiques view using boutiques_weebi package, embedded in the app's
/// [PortalMasterLayout] so global navigation (back to home, sidebar) remains available.
///
/// A nested [Navigator] keeps list → detail / create [Navigator.push] calls on this
/// stack instead of the root navigator, so the drawer / sidebar stay visible
/// (same pattern as the Users and Accesses package screens).
class BoutiquesPackageScreen extends StatefulWidget {
  const BoutiquesPackageScreen({super.key});

  @override
  State<BoutiquesPackageScreen> createState() => _BoutiquesPackageScreenState();
}

class _BoutiquesPackageScreenState extends State<BoutiquesPackageScreen> {
  Iterable<License>? _firmLicenses;
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

  BusinessRulesBoutiqueIntegration? _integration(
    PermissionProvider permissionProvider,
  ) {
    final licenses = _firmLicenses;
    if (licenses == null) return null;

    final canEdit = SeatCapability.businessRulesEditable(
      permissionProvider.userId,
      licenses,
    );
    return BusinessRulesBoutiqueIntegration(canEditBusinessRules: canEdit);
  }

  BoutiqueFormExtensionsFactory? _formExtensionsFactory(
    BusinessRulesBoutiqueIntegration? integration,
  ) {
    if (integration == null) return null;
    return ({
      Chain? editingChain,
      BoutiqueMongo? editingBoutique,
      Chain? parentChain,
    }) =>
        integration.extensionsFor(
          editingChain: editingChain,
          editingBoutique: editingBoutique,
          parentChain: parentChain,
        );
  }

  BoutiqueDetailExtrasFactory? _detailExtrasFactory(
    BusinessRulesBoutiqueIntegration? integration,
  ) {
    if (integration == null) return null;
    return ({BoutiqueMongo? boutique, Chain? chain}) =>
        integration.detailExtras(boutique: boutique, chain: chain);
  }

  @override
  Widget build(BuildContext context) {
    final permissionProvider = context.read<PermissionProvider>();
    final integration = _integration(permissionProvider);

    return PortalMasterLayout(
      selectedMenuUri: RouteUri.listBoutique,
      body: Navigator(
        key: ValueKey<int>(_licenseNavEpoch),
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
              formExtensionsFactory: _formExtensionsFactory(integration),
              detailExtrasFactory: _detailExtrasFactory(integration),
            ),
          );
        },
      ),
    );
  }
}
