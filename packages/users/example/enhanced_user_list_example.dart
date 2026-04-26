import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:users_weebi/weebi_users.dart';

/// Example demonstrating the enhanced UserListWidget with permission editing
class EnhancedUserListExample extends StatefulWidget {
  const EnhancedUserListExample({super.key});

  @override
  State<EnhancedUserListExample> createState() =>
      _EnhancedUserListExampleState();
}

class _EnhancedUserListExampleState extends State<EnhancedUserListExample> {
  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = UserProvider(
      _MockFenceServiceClient(),
    );
    _initializeSampleData();
  }

  Future<void> _initializeSampleData() async {
    // Add some sample users for demonstration
    final sampleUsers = [
      UserPublic.create()
        ..userId = 'user_001'
        ..firstname = 'Alice'
        ..lastname = 'Johnson'
        ..mail = 'alice.johnson@example.com'
        ..phone = (Phone.create()..number = '+1234567890'),
      UserPublic.create()
        ..userId = 'user_002'
        ..firstname = 'Bob'
        ..lastname = 'Smith'
        ..mail = 'bob.smith@example.com'
        ..phone = (Phone.create()..number = '+1234567891'),
      UserPublic.create()
        ..userId = 'user_003'
        ..firstname = 'Carol'
        ..lastname = 'Williams'
        ..mail = 'carol.williams@example.com'
        ..phone = (Phone.create()..number = '+1234567892'),
    ];

    for (final user in sampleUsers) {
      await _userProvider.createUser(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _userProvider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enhanced User List'),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          actions: const [
            Icon(Icons.admin_panel_settings),
            SizedBox(width: 16),
          ],
        ),
        body: Column(
          children: [
            // Info banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(8),
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
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Enhanced User List Features',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• User detail screen with profile summary\n'
                    '• Editable permissions in detail (own profile is read-only)\n'
                    '• Color-coded user avatars\n'
                    '• Card-based list layout',
                    style: TextStyle(color: Colors.blue[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap a user to open detail and adjust permissions there.',
                    style: TextStyle(
                      color: Colors.blue[500],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            // User list
            Expanded(
              child: UserListWidget(
                currentUserId:
                    'demo_current_user', // In real app: use cloudHub.userId
                onPermissionsChanged: _handlePermissionChange,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showUserCreationDialog,
          icon: const Icon(Icons.person_add),
          label: const Text('Add User'),
          backgroundColor: Colors.green[600],
        ),
      ),
    );
  }

  void _handlePermissionChange(UserPublic user, UserPermissions permissions) {
    // Here you would typically save the permissions to your backend
    print('Permissions updated for ${user.firstname} ${user.lastname}:');
    print(
        '- Articles: ${permissions.articleRights.rights.map((r) => r.name).join(", ")}');
    print(
        '- Contacts: ${permissions.contactRights.rights.map((r) => r.name).join(", ")}');
    print(
        '- Tickets: ${permissions.ticketRights.rights.map((r) => r.name).join(", ")}');
    print('- Can see stats: ${permissions.boolRights.canSeeStats}');
    print('- Can give discount: ${permissions.boolRights.canGiveDiscount}');

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Permissions saved for ${user.firstname}'),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            _showPermissionsSummary(user, permissions);
          },
        ),
      ),
    );
  }

  void _showPermissionsSummary(UserPublic user, UserPermissions permissions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.firstname}\'s Permissions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPermissionSummarySection(
                'Article Rights',
                permissions.articleRights.rights.map((r) => r.name).toList(),
                Icons.inventory,
                Colors.orange,
              ),
              _buildPermissionSummarySection(
                'Contact Rights',
                permissions.contactRights.rights.map((r) => r.name).toList(),
                Icons.contacts,
                Colors.blue,
              ),
              _buildPermissionSummarySection(
                'Ticket Rights',
                permissions.ticketRights.rights.map((r) => r.name).toList(),
                Icons.receipt,
                Colors.grey,
              ),
              _buildBoolPermissionSummary(permissions.boolRights),
            ],
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

  Widget _buildPermissionSummarySection(
    String title,
    List<String> rights,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (rights.isEmpty)
            Text(
              'No permissions',
              style: TextStyle(
                  color: Colors.grey[600], fontStyle: FontStyle.italic),
            )
          else
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: rights
                  .map((right) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: color.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          right,
                          style: TextStyle(
                            fontSize: 12,
                            color: color.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildBoolPermissionSummary(BoolRights boolRights) {
    final activeBoolRights = <String>[];
    if (boolRights.canSeeStats) activeBoolRights.add('See Stats');
    if (boolRights.canExportData) activeBoolRights.add('Export Data');
    if (boolRights.canGiveDiscount) activeBoolRights.add('Give Discount');
    if (boolRights.canSetPromo) activeBoolRights.add('Set Promo');
    if (boolRights.canStockMovement) activeBoolRights.add('Stock Movement');
    if (boolRights.canStockInventory) activeBoolRights.add('Stock Inventory');
    if (boolRights.canPurchase) activeBoolRights.add('Purchase');

    return _buildPermissionSummarySection(
      'Special Rights',
      activeBoolRights,
      Icons.star,
      Colors.purple,
    );
  }

  Future<void> _showUserCreationDialog() async {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (firstNameController.text.isNotEmpty &&
                  lastNameController.text.isNotEmpty &&
                  emailController.text.isNotEmpty) {
                final newUser = UserPublic.create()
                  ..userId = 'user_${DateTime.now().millisecondsSinceEpoch}'
                  ..firstname = firstNameController.text
                  ..lastname = lastNameController.text
                  ..mail = emailController.text
                  ..phone = (Phone.create()..number = '+1234567890');

                await _userProvider.createUser(newUser);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

// Mock implementation for demo purposes
class _MockFenceServiceClient extends FenceServiceClient {
  _MockFenceServiceClient() : super(ClientChannel('localhost'));

  // This is just for demo - in real implementation, you'd connect to actual gRPC service
}

void main() {
  runApp(MaterialApp(
    title: 'Enhanced User List Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
    ),
    home: const EnhancedUserListExample(),
    debugShowCheckedModeBanner: false,
  ));
}
