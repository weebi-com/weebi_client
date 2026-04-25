import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:users_weebi/weebi_users.dart';

/// Example demonstrating the ElegantPermissionsWidget
class ElegantPermissionsExample extends StatefulWidget {
  const ElegantPermissionsExample({super.key});

  @override
  State<ElegantPermissionsExample> createState() => _ElegantPermissionsExampleState();
}

class _ElegantPermissionsExampleState extends State<ElegantPermissionsExample> {
  late UserPermissions _userPermissions;
  bool _isEditable = true;

  @override
  void initState() {
    super.initState();
    _initializePermissions();
  }

  void _initializePermissions() {
    _userPermissions = UserPermissions.create()
      ..userId = 'user_123'
      ..firmId = 'firm_456'
      // Initialize with some example permissions
      ..articleRights = ArticleRights(rights: [Right.read, Right.create])
      ..contactRights = ContactRights(rights: [Right.read, Right.update])
      ..ticketRights = TicketRights(rights: [Right.read, Right.create, Right.update])
      ..boutiqueRights = BoutiqueRights(rights: [Right.update])
      ..boolRights = (BoolRights.create()
        ..canSeeStats = true
        ..canExportData = false
        ..canGiveDiscount = true
        ..canSetPromo = false
        ..canStockMovement = true
        ..canStockInventory = false
        ..canPurchase = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegant Permissions Example'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditable ? Icons.edit : Icons.visibility),
            onPressed: () {
              setState(() {
                _isEditable = !_isEditable;
              });
            },
            tooltip: _isEditable ? 'Switch to View Mode' : 'Switch to Edit Mode',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Info card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'User Permissions Management',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use the toggle in the top-right to switch between edit and view modes. '
                    'In edit mode, you can toggle permissions with the switches. '
                    'Changes are reflected immediately.',
                    style: TextStyle(color: Colors.blue[600]),
                  ),
                ],
              ),
            ),

            // Main permissions widget
            ElegantPermissionsWidget(
              permissions: _userPermissions,
              isEditable: _isEditable,
              title: 'User: ${_userPermissions.userId}',
              onPermissionsChanged: (updatedPermissions) {
                setState(() {
                  _userPermissions = updatedPermissions;
                });
                
                // Show a snackbar to indicate the change
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Permissions updated'),
                    backgroundColor: Colors.green,
                    duration: const Duration(milliseconds: 1500),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),

            // Action buttons
            Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _grantAllPermissions,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Grant All'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _revokeAllPermissions,
                          icon: const Icon(Icons.cancel),
                          label: const Text('Revoke All'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _setManagerPermissions,
                          icon: const Icon(Icons.supervisor_account),
                          label: const Text('Manager Profile'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _setCashierPermissions,
                          icon: const Icon(Icons.point_of_sale),
                          label: const Text('Cashier Profile'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Permissions summary
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.summarize, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Permissions Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CompactPermissionsWidget(permissions: _userPermissions),
                  const SizedBox(height: 8),
                  Text(
                    'Total active permissions: ${_countActivePermissions()}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _grantAllPermissions() {
    setState(() {
      _userPermissions = UserPermissions.create()
        ..userId = _userPermissions.userId
        ..firmId = _userPermissions.firmId
        ..articleRights = ArticleRights(
          rights: [Right.create, Right.read, Right.update, Right.delete])
        ..contactRights = ContactRights(
          rights: [Right.create, Right.read, Right.update, Right.delete])
        ..ticketRights = TicketRights(
          rights: [Right.create, Right.read, Right.update, Right.delete])
        ..boutiqueRights = BoutiqueRights(rights: [Right.update])
        ..boolRights = (BoolRights.create()
          ..canSeeStats = true
          ..canExportData = true
          ..canGiveDiscount = true
          ..canSetPromo = true
          ..canStockMovement = true
          ..canStockInventory = true
          ..canPurchase = true);
    });
  }

  void _revokeAllPermissions() {
    setState(() {
      _userPermissions = UserPermissions.create()
        ..userId = _userPermissions.userId
        ..firmId = _userPermissions.firmId
        ..articleRights = ArticleRights.create()
        ..contactRights = ContactRights.create()
        ..ticketRights = TicketRights.create()
        ..boutiqueRights = BoutiqueRights.create()
        ..boolRights = BoolRights.create();
    });
  }

  void _setManagerPermissions() {
    setState(() {
      _userPermissions = UserPermissions.create()
        ..userId = _userPermissions.userId
        ..firmId = _userPermissions.firmId
        ..articleRights = ArticleRights(
          rights: [Right.create, Right.read, Right.update, Right.delete])
        ..contactRights = ContactRights(
          rights: [Right.create, Right.read, Right.update, Right.delete])
        ..ticketRights = TicketRights(
          rights: [Right.create, Right.read, Right.update, Right.delete])
        ..boutiqueRights = BoutiqueRights(rights: [Right.update])
        ..boolRights = (BoolRights.create()
          ..canSeeStats = true
          ..canExportData = true
          ..canGiveDiscount = true
          ..canSetPromo = true
          ..canStockMovement = true
          ..canStockInventory = true
          ..canPurchase = true);
    });
  }

  void _setCashierPermissions() {
    setState(() {
      _userPermissions = UserPermissions.create()
        ..userId = _userPermissions.userId
        ..firmId = _userPermissions.firmId
        ..articleRights = ArticleRights(rights: [Right.read])
        ..contactRights = ContactRights(rights: [Right.read, Right.update])
        ..ticketRights = TicketRights(rights: [Right.create, Right.read])
        ..boutiqueRights = BoutiqueRights.create()
        ..boolRights = (BoolRights.create()
          ..canSeeStats = false
          ..canExportData = false
          ..canGiveDiscount = true
          ..canSetPromo = false
          ..canStockMovement = false
          ..canStockInventory = false
          ..canPurchase = false);
    });
  }

  int _countActivePermissions() {
    int count = 0;
    count += _userPermissions.articleRights.rights.length;
    count += _userPermissions.contactRights.rights.length;
    count += _userPermissions.ticketRights.rights.length;
    count += _userPermissions.boutiqueRights.rights.length;
    
    final boolRights = _userPermissions.boolRights;
    if (boolRights.canSeeStats) count++;
    if (boolRights.canExportData) count++;
    if (boolRights.canGiveDiscount) count++;
    if (boolRights.canSetPromo) count++;
    if (boolRights.canStockMovement) count++;
    if (boolRights.canStockInventory) count++;
    if (boolRights.canPurchase) count++;
    
    return count;
  }
}

/// Simple usage example showing minimal implementation
class SimplePermissionsExample extends StatefulWidget {
  final UserPermissions permissions;

  const SimplePermissionsExample({
    super.key,
    required this.permissions,
  });

  @override
  State<SimplePermissionsExample> createState() => _SimplePermissionsExampleState();
}

class _SimplePermissionsExampleState extends State<SimplePermissionsExample> {
  late UserPermissions _permissions;

  @override
  void initState() {
    super.initState();
    _permissions = widget.permissions;
  }

  @override
  Widget build(BuildContext context) {
    return ElegantPermissionsWidget(
      permissions: _permissions,
      isEditable: true,
      showHeader: false, // Hide header for embedded usage
      onPermissionsChanged: (updatedPermissions) {
        setState(() {
          _permissions = updatedPermissions;
        });
        // Handle permission changes (e.g., save to backend)
        _savePermissions(updatedPermissions);
      },
    );
  }

  Future<void> _savePermissions(UserPermissions permissions) async {
    // Example:
    // await userService.updateUserPermissions(permissions);
    print('Permissions updated: ${permissions.toString()}');
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Elegant Permissions Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
    ),
    home: const ElegantPermissionsExample(),
    debugShowCheckedModeBanner: false,
  ));
} 