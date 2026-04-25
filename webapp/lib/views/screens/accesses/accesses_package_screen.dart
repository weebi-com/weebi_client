import 'package:accesses_weebi/accesses_weebi.dart';
import 'package:auth_weebi/auth_weebi.dart' show PermissionProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart' show License, UserPublic;
import 'package:web_admin/app_router.dart';
import 'package:web_admin/core/billing/load_firm_licenses.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

/// Accesses view using accesses_weebi package, embedded in the app's
/// PortalMasterLayout so global navigation remains available.
/// Uses a nested Navigator for AccessListWidget -> UserAccessWidget navigation.
class AccessesPackageScreen extends StatefulWidget {
  const AccessesPackageScreen({super.key});

  @override
  State<AccessesPackageScreen> createState() => _AccessesPackageScreenState();
}

class _AccessesPackageScreenState extends State<AccessesPackageScreen> {
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

  @override
  Widget build(BuildContext context) {
    final permissionProvider = context.read<PermissionProvider>();
    final currentUserId = permissionProvider.userId;
    final firmLicenses = _firmLicenses;

    return PortalMasterLayout(
      selectedMenuUri: RouteUri.listAccess,
      body: Navigator(
        key: ValueKey<int>(_licenseNavEpoch),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          if (settings.name == AccessRoutes.userAccess) {
            final args = settings.arguments;
            UserPublic? user;
            String? userId;
            Iterable<License>? routeLicenses;
            if (args is UserPublic) {
              user = args;
            } else if (args is Map) {
              user = args['user'] as UserPublic?;
              userId = args['currentUserId'] as String?;
              routeLicenses = args['firmLicenses'] as Iterable<License>?;
            }
            if (user != null) {
              return MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: Text(
                      '${user!.firstname} ${user.lastname} - Access',
                    ),
                  ),
                  body: UserAccessWidget(
                    user: user,
                    currentUserId: userId,
                    firmLicenses: routeLicenses,
                  ),
                ),
              );
            }
          }
          return MaterialPageRoute<void>(
            builder: (context) => AccessListWidget(
              currentUserId: currentUserId,
              firmLicenses: firmLicenses,
            ),
          );
        },
      ),
    );
  }
}
