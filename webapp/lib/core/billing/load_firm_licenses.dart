import 'package:auth_weebi/auth_weebi.dart' show PermissionProvider;
import 'package:flutter/widgets.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:provider/provider.dart';
import 'package:web_admin/providers/server.dart';

/// Loads firm licenses for seat indicators (user list, detail, accesses, create-user).
///
/// Does **not** require [PermissionProvider.canReadBilling]. Admins who manage users
/// often have no billing tab, but still need to see who has a seat; the billing RPC
/// enforces authorization server-side. On failure (network, permission denied), returns
/// `null` and widgets omit seat-specific UI.
Future<Iterable<License>?> loadFirmLicensesIfPermitted(BuildContext context) async {
  final perm = context.read<PermissionProvider>();
  if (!perm.hasToken) return null;
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
