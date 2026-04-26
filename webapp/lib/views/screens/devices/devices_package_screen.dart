import 'package:devices_weebi/devices_weebi.dart';
import 'package:flutter/material.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

/// Devices view using devices_weebi package, embedded in the app's
/// PortalMasterLayout so global navigation remains available.
class DevicesPackageScreen extends StatelessWidget {
  const DevicesPackageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PortalMasterLayout(
      selectedMenuUri: RouteUri.listDevice,
      body: const DeviceManagementWidget(),
    );
  }
}
