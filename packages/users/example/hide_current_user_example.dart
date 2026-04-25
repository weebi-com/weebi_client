import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:users_weebi/weebi_users.dart';

/// Example demonstrating how to hide the current user from the user list
/// This prevents users from editing their own permissions
class HideCurrentUserExample extends StatefulWidget {
  const HideCurrentUserExample({super.key});

  @override
  State<HideCurrentUserExample> createState() => _HideCurrentUserExampleState();
}

class _HideCurrentUserExampleState extends State<HideCurrentUserExample> {
  late UserProvider _userProvider;

  // Simulate current logged-in user ID (in real app, get this from CloudHub)
  final String _currentUserId = 'user_001'; // This user will be hidden

  bool _hideCurrentUser = true;

  @override
  void initState() {
    super.initState();
    _userProvider = UserProvider(_MockFenceServiceClient());
    _initializeSampleData();
  }

  Future<void> _initializeSampleData() async {
    // Add sample users including the "current user"
    final sampleUsers = [
      UserPublic.create()
        ..userId = 'user_001' // This is the "current user"
        ..firstname = 'Current'
        ..lastname = 'User'
        ..mail = 'current.user@example.com'
        ..phone = (Phone.create()..number = '+1234567890'),
      UserPublic.create()
        ..userId = 'user_002'
        ..firstname = 'Alice'
        ..lastname = 'Johnson'
        ..mail = 'alice.johnson@example.com'
        ..phone = (Phone.create()..number = '+1234567891'),
      UserPublic.create()
        ..userId = 'user_003'
        ..firstname = 'Bob'
        ..lastname = 'Smith'
        ..mail = 'bob.smith@example.com'
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
          title: const Text('Hide Current User Example'),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          actions: [
            // Toggle switch to show/hide current user
            Switch(
              value: _hideCurrentUser,
              onChanged: (value) {
                setState(() {
                  _hideCurrentUser = value;
                });
              },
              activeColor: Colors.white,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.visibility_off),
            const SizedBox(width: 16),
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
                color: _hideCurrentUser ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _hideCurrentUser
                        ? Colors.green[200]!
                        : Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _hideCurrentUser ? Icons.security : Icons.warning,
                        color: _hideCurrentUser
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _hideCurrentUser
                            ? 'Current User Hidden (Secure Mode)'
                            : 'Current User Visible (Demo Mode)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _hideCurrentUser
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current User ID: $_currentUserId',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: _hideCurrentUser
                          ? Colors.green[600]
                          : Colors.orange[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _hideCurrentUser
                        ? '✓ The current user is hidden from the list to prevent self-permission editing'
                        : '⚠ The current user is visible with disabled permission editing button',
                    style: TextStyle(
                      color: _hideCurrentUser
                          ? Colors.green[600]
                          : Colors.orange[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toggle the switch above to see the difference:\n'
                    '• ON: Current user is completely hidden (recommended)\n'
                    '• OFF: Current user visible but permission button is disabled\n'
                    'In a real app, use: currentUserId: cloudHub.userId',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            // User list
            Expanded(
              child: UserListWidget(
                currentUserId: _hideCurrentUser
                    ? _currentUserId
                    : 'no_user', // Always required now
                onPermissionsChanged: (user, permissions) {
                  // Show warning if somehow current user permissions are being changed
                  if (user.userId == _currentUserId) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                                '⚠ Current user should not edit their own permissions!'),
                          ],
                        ),
                        backgroundColor: Colors.orange[600],
                      ),
                    );
                    return;
                  }

                  // Normal permission update
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Permissions updated for ${user.firstname}'),
                        ],
                      ),
                      backgroundColor: Colors.green[600],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showUserCreationDialog,
          icon: const Icon(Icons.person_add),
          label: const Text('Add User'),
          backgroundColor: Colors.blue[600],
        ),
      ),
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
    title: 'Hide Current User Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
    ),
    home: const HideCurrentUserExample(),
    debugShowCheckedModeBanner: false,
  ));
}
