import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:users_weebi/weebi_users.dart';

/// Simple example showing how to use UserProvider with UserListWidget
/// This demonstrates the clean, focused approach for user permission management
class SimpleUserExample extends StatefulWidget {
  const SimpleUserExample({super.key});

  @override
  State<SimpleUserExample> createState() => _SimpleUserExampleState();
}

class _SimpleUserExampleState extends State<SimpleUserExample> {
  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _setupUserManagement();
  }

  void _setupUserManagement() {
    // Create UserProvider with your FenceServiceClient
    _userProvider = UserProvider(
      _MockFenceServiceClient(), // Replace with your actual client
    );
    
    // Load test users (in production, these come from your backend)
    _loadTestUsers();
  }

  Future<void> _loadTestUsers() async {
    final testUsers = [
      UserPublic.create()
        ..userId = 'admin_user'
        ..firstname = 'Admin'
        ..lastname = 'User'
        ..mail = 'admin@company.com'
        ..phone = (Phone.create()..number = '+1234567890'),
      UserPublic.create()
        ..userId = 'manager_user'
        ..firstname = 'Manager'
        ..lastname = 'User'
        ..mail = 'manager@company.com'
        ..phone = (Phone.create()..number = '+1234567891'),
      UserPublic.create()
        ..userId = 'cashier_user'
        ..firstname = 'Cashier'
        ..lastname = 'User'
        ..mail = 'cashier@company.com'
        ..phone = (Phone.create()..number = '+1234567892'),
    ];

    for (final user in testUsers) {
      await _userProvider.createUser(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _userProvider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Management'),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Information Card
            Container(
              width: double.infinity,
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
                  Text(
                    'User Permission Management',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This example demonstrates simple user permission management. '
                    'Click on any user to edit their permissions.',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Text(
                      '💡 To connect to your backend, implement the service methods in UserProvider._loadUserPermissionsFromService() and _updateUserPermissionsViaService()',
                      style: TextStyle(
                        color: Colors.amber[700],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // User List
            Expanded(
              child: UserListWidget(
                currentUserId: 'demo_current_user', // In real app: use cloudHub.userId
                onPermissionsChanged: (user, permissions) async {
                  print('✅ Updated permissions for ${user.firstname} ${user.lastname}');
                  print('   Article rights: ${permissions.articleRights.rights.map((r) => r.name).join(", ")}');
                  
                  // Show success message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Updated permissions for ${user.firstname} ${user.lastname}'),
                        backgroundColor: Colors.green[600],
                        behavior: SnackBarBehavior.fixed,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addNewUser,
          icon: const Icon(Icons.person_add),
          label: const Text('Add User'),
          backgroundColor: Colors.blue[600],
        ),
      ),
    );
  }

  void _addNewUser() {
    // Example of adding a new user
    final newUser = UserPublic.create()
      ..userId = 'new_user_${DateTime.now().millisecondsSinceEpoch}'
      ..firstname = 'New'
      ..lastname = 'User'
      ..mail = 'new.user@company.com'
      ..phone = (Phone.create()..number = '+1234567899');

    _userProvider.createUser(newUser);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${newUser.firstname} ${newUser.lastname}'),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }
}

class _MockFenceServiceClient extends FenceServiceClient {
  _MockFenceServiceClient() : super(ClientChannel('localhost'));
}

void main() {
  runApp(MaterialApp(
    title: 'Simple User Management',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
    ),
    home: const SimpleUserExample(),
    debugShowCheckedModeBanner: false,
  ));
} 