import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:users_weebi/users_weebi.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/core/billing/load_firm_licenses.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

/// Create-user flow embedded in the admin shell (GoRouter — not [Navigator.pushNamed]).
class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  Iterable<License>? _firmLicenses;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final licenses = await loadFirmLicensesIfPermitted(context);
      if (!mounted) return;
      setState(() => _firmLicenses = licenses);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PortalMasterLayout(
      selectedMenuUri: RouteUri.listUser,
      body: UserCreateView(
        showFloatingActionButton: false,
        firmLicenses: _firmLicenses,
        onUserCreated: (ctx, _) {
          GoRouter.of(ctx).go(RouteUri.listAccess);
        },
      ),
    );
  }
}
