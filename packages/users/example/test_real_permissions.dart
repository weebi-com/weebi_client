import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:users_weebi/weebi_users.dart';

/// Example demonstrating real user permissions testing
class TestRealPermissionsExample extends StatefulWidget {
  const TestRealPermissionsExample({super.key});

  @override
  State<TestRealPermissionsExample> createState() =>
      _TestRealPermissionsExampleState();
}

class _TestRealPermissionsExampleState
    extends State<TestRealPermissionsExample> {
  late UserProvider _userProvider;
  late Map<String, UserPermissions> _testPermissions;

  @override
  void initState() {
    super.initState();
    _userProvider = UserProvider(_MockFenceServiceClient());
    _setupTestData();
  }

  Future<void> _setupTestData() async {
    // Create test users
    final testUsers = [
      UserPublic.create()
        ..userId = 'admin_user'
        ..firstname = 'Admin'
        ..lastname = 'User'
        ..mail = 'admin@example.com'
        ..phone = (Phone.create()..number = '+1234567890'),
      UserPublic.create()
        ..userId = 'readonly_user'
        ..firstname = 'ReadOnly'
        ..lastname = 'User'
        ..mail = 'readonly@example.com'
        ..phone = (Phone.create()..number = '+1234567891'),
      UserPublic.create()
        ..userId = 'cashier_user'
        ..firstname = 'Cashier'
        ..lastname = 'User'
        ..mail = 'cashier@example.com'
        ..phone = (Phone.create()..number = '+1234567892'),
    ];

    _testPermissions = {
      'admin_user': _createAdminPermissions(),
      'readonly_user': _createReadOnlyPermissions(),
      'cashier_user': _createCashierPermissions(),
    };

    for (final user in testUsers) {
      user.permissions = _testPermissions[user.userId]!;
      await _userProvider.createUser(user);
    }
  }

  UserPermissions _createAdminPermissions() {
    // Full admin permissions
    return UserPermissions.create()
      ..userId = 'admin_user'
      ..firmId = 'test_firm'
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
  }

  UserPermissions _createReadOnlyPermissions() {
    // ONLY READ permissions - this should show most switches as OFF
    return UserPermissions.create()
      ..userId = 'readonly_user'
      ..firmId = 'test_firm'
      ..articleRights = ArticleRights(
        rights: [Right.read]) // ONLY READ - create/update/delete should be OFF
      ..contactRights = ContactRights(rights: [Right.read]) // ONLY READ
      ..ticketRights = TicketRights(rights: [Right.read]) // ONLY READ
      ..boutiqueRights = BoutiqueRights.create() // NO PERMISSIONS
      ..boolRights =
          BoolRights.create(); // ALL FALSE - all special rights should be OFF
  }

  UserPermissions _createCashierPermissions() {
    // Limited cashier permissions
    return UserPermissions.create()
      ..userId = 'cashier_user'
      ..firmId = 'test_firm'
      ..articleRights = ArticleRights(rights: [Right.read]) // Can only read articles
      ..contactRights = ContactRights(
        rights: [Right.read, Right.update]) // Can read and update contacts
      ..ticketRights = TicketRights(
        rights: [Right.create, Right.read]) // Can create and read tickets
      ..boutiqueRights = BoutiqueRights.create() // No boutique permissions
      ..boolRights = (BoolRights.create()
        ..canGiveDiscount = true // Can give discounts
        ..canSeeStats = false // Cannot see stats
        ..canExportData = false // Cannot export
        ..canSetPromo = false // Cannot set promos
        ..canStockMovement = false
        ..canStockInventory = false
        ..canPurchase = false);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _userProvider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Real Permissions Test'),
          backgroundColor: Colors.indigo[700],
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Explanation card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.indigo[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Permission Testing Scenarios',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[700],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildScenarioDescription('Admin User',
                      'Full permissions - all switches ON', Colors.green),
                  const SizedBox(height: 8),
                  _buildScenarioDescription('ReadOnly User',
                      'Only READ rights - most switches OFF', Colors.orange),
                  const SizedBox(height: 8),
                  _buildScenarioDescription('Cashier User',
                      'Limited permissions - mixed switches', Colors.blue),
                  const SizedBox(height: 12),
                  Text(
                    'Open a user and verify switches match their stored permissions.',
                    style: TextStyle(
                      color: Colors.indigo[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            // User list with custom permissions
            Expanded(
              child: UserListWidget(
                currentUserId: 'demo_current_user', // In real app: use cloudHub.userId
                onPermissionsChanged: (user, permissions) {
                  print('Permissions changed for ${user.firstname}:');
                  print(
                      '- Article rights: ${permissions.articleRights.rights.map((r) => r.name).join(", ")}');
                  print(
                      '- Contact rights: ${permissions.contactRights.rights.map((r) => r.name).join(", ")}');
                  print(
                      '- Boolean rights: canSeeStats=${permissions.boolRights.canSeeStats}, canGiveDiscount=${permissions.boolRights.canGiveDiscount}');

                  // Update our test permissions map
                  setState(() {
                    _testPermissions[user.userId] = permissions;
                  });
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showPermissionsSummary,
          icon: const Icon(Icons.summarize),
          label: const Text('View Summary'),
          backgroundColor: Colors.indigo[600],
        ),
      ),
    );
  }

  Widget _buildScenarioDescription(
      String title, String description, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _showPermissionsSummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Summary'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: _testPermissions.entries.map((entry) {
              final userId = entry.key;
              final permissions = entry.value;
              final user =
                  _userProvider.users.firstWhere((u) => u.userId == userId);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.firstname} ${user.lastname}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          'Articles: ${permissions.articleRights.rights.map((r) => r.name).join(", ")}'),
                      Text(
                          'Contacts: ${permissions.contactRights.rights.map((r) => r.name).join(", ")}'),
                      Text(
                          'Tickets: ${permissions.ticketRights.rights.map((r) => r.name).join(", ")}'),
                      Text(
                          'Stats: ${permissions.boolRights.canSeeStats ? "Yes" : "No"}'),
                      Text(
                          'Discount: ${permissions.boolRights.canGiveDiscount ? "Yes" : "No"}'),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _MockFenceServiceClient extends FenceServiceClient {
  _MockFenceServiceClient() : super(ClientChannel('localhost'));
}

void main() {
  runApp(MaterialApp(
    title: 'Real Permissions Test',
    theme: ThemeData(primarySwatch: Colors.indigo),
    home: const TestRealPermissionsExample(),
    debugShowCheckedModeBanner: false,
  ));
}
