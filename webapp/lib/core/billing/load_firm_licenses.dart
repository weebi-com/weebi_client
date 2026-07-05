import 'package:auth_weebi/auth_weebi.dart' show PermissionProvider;
import 'package:flutter/widgets.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:provider/provider.dart';
import 'package:web_admin/providers/server.dart';
import 'package:web_admin/providers/user_data_provider.dart';

/// Loads firm licences for attribution indicators (user list, detail, accesses, create-user).
///
/// Licences are lifetime purchases, not subscriptions — see `docs/commercial-model.md`.
/// Credits / consumption billing are separate (billing screen, cloud portal).
///
/// Does **not** require [PermissionProvider.canReadBilling]. Admins who manage users
/// often have no billing tab, but still need licence status; the billing RPC enforces
/// authorization server-side. On failure, returns `null` and widgets omit licence UI.
Future<Iterable<License>?> loadFirmLicensesIfPermitted(BuildContext context) async {
  final userData = context.read<UserDataProvider>();
  if (!userData.isUserLoggedIn()) return null;
  try {
    final response = await context
        .read<BillingServiceClientProvider>()
        .billingServiceClient
        .readLicenses(Empty());
    return response.licenses;
  } catch (_) {
    return null;
  }
}
