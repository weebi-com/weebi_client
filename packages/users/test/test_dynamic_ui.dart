import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import '../lib/src/widgets/elegant_permissions_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Permissions Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dynamic Boolean Permissions'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElegantPermissionsWidget(
              permissions: UserPermissions()
                ..userId = 'test-user'
                ..firmId = 'test-firm'
                ..boolRights = (BoolRights()
                  ..canSeeStats = true
                  ..canExportData = false
                  ..canGiveDiscount = true
                  ..canSetPromo = false
                  ..canStockMovement = true
                  ..canStockInventory = false
                  ..canSpendOutOfCatalog = true
                  ..canPurchase = false
                  ..canImportTickets = true
                  ..canSellOutOfCatalog = false
                  ..canUpdateContactBalanceOffline = true),
              isEditable: true,
              onPermissionsChanged: (permissions) {
                print('Permissions changed: ${permissions.boolRights}');
              },
            ),
          ),
        ),
      ),
    );
  }
}

