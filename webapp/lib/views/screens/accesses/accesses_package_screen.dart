import 'package:accesses_weebi/accesses_weebi.dart';
import 'package:auth_weebi/auth_weebi.dart' show PermissionProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart' show License, UserPublic;
import 'package:web_admin/core/billing/load_firm_licenses.dart';
import 'package:web_admin/core/routing/routes.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

/// GoRouter extra when opening accesses from user creation.
class AccessesOpenArgs {
  final UserPublic? user;
  final bool returnToUsersOnSave;

  const AccessesOpenArgs({
    this.user,
    this.returnToUsersOnSave = false,
  });
}

/// Accesses view using accesses_weebi package, embedded in the app's
/// PortalMasterLayout so global navigation remains available.
/// Uses a nested Navigator for AccessListWidget -> UserAccessWidget navigation.
class AccessesPackageScreen extends StatefulWidget {
  const AccessesPackageScreen({
    super.key,
    this.initialUser,
    this.returnToUsersOnSave = false,
  });

  /// When set, open this user's access screen immediately.
  final UserPublic? initialUser;

  /// After save (or back), go to the users list instead of the access list.
  final bool returnToUsersOnSave;

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

  void _leaveToUsers() {
    GoRouter.of(context).go(RouteUri.listUser);
  }

  @override
  Widget build(BuildContext context) {
    final permissionProvider = context.read<PermissionProvider>();
    final currentUserId = permissionProvider.userId;
    final firmLicenses = _firmLicenses;
    final initialUser = widget.initialUser;

    return PortalMasterLayout(
      selectedMenuUri: RouteUri.listAccess,
      body: Navigator(
        key: ValueKey<int>(_licenseNavEpoch),
        onGenerateInitialRoutes: (navigator, initialRoute) {
          if (initialUser != null) {
            return [
              MaterialPageRoute<void>(
                settings: RouteSettings(
                  name: AccessRoutes.userAccess,
                  arguments: initialUser,
                ),
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    leading: widget.returnToUsersOnSave
                        ? IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: _leaveToUsers,
                          )
                        : null,
                    title: Text(
                      '${initialUser.firstname} ${initialUser.lastname} - Access',
                    ),
                  ),
                  body: UserAccessWidget(
                    user: initialUser,
                    currentUserId: currentUserId,
                    firmLicenses: firmLicenses,
                    onSaved:
                        widget.returnToUsersOnSave ? _leaveToUsers : null,
                  ),
                ),
              ),
            ];
          }
          return [
            MaterialPageRoute<void>(
              builder: (context) => AccessListWidget(
                currentUserId: currentUserId,
                firmLicenses: firmLicenses,
              ),
            ),
          ];
        },
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
            user ??= initialUser;
            if (user != null) {
              return MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    leading: widget.returnToUsersOnSave
                        ? IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: _leaveToUsers,
                          )
                        : null,
                    title: Text(
                      '${user!.firstname} ${user.lastname} - Access',
                    ),
                  ),
                  body: UserAccessWidget(
                    user: user,
                    currentUserId: userId,
                    firmLicenses: routeLicenses ?? firmLicenses,
                    onSaved:
                        widget.returnToUsersOnSave ? _leaveToUsers : null,
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
