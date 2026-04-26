import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:users_weebi/weebi_users.dart';

/// Simple test to verify permissions dialog functionality
class TestPermissionsDialog extends StatefulWidget {
  const TestPermissionsDialog({super.key});

  @override
  State<TestPermissionsDialog> createState() => _TestPermissionsDialogState();
}

class _TestPermissionsDialogState extends State<TestPermissionsDialog> {
  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = UserProvider(_MockFenceServiceClient());
    _initializeTestUser();
  }

  Future<void> _initializeTestUser() async {
    final testUser = UserPublic.create()
      ..userId = 'test_user_001'
      ..firstname = 'Test'
      ..lastname = 'User'
      ..mail = 'test.user@example.com'
      ..phone = (Phone.create()..number = '+1234567890');

    await _userProvider.createUser(testUser);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _userProvider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Test Permissions Dialog'),
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Test Permission Dialog Functionality',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _testDirectPermissionsDialog,
                child: const Text('Test Direct Dialog'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _testUserListWidget,
                child: const Text('Test User List Widget'),
              ),
              const SizedBox(height: 20),
              const Text('Check console for debug output'),
            ],
          ),
        ),
      ),
    );
  }

  void _testDirectPermissionsDialog() {
    print('Testing direct permissions dialog...');

    final testPermissions = UserPermissions.create()
      ..userId = 'test_user_001'
      ..firmId = 'test_firm'
      ..articleRights = ArticleRights(rights: [Right.read, Right.create])
      ..contactRights = ContactRights(rights: [Right.read])
      ..boolRights = (BoolRights.create()..canSeeStats = true);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Direct Test Dialog',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            // Permissions widget
            Expanded(
              child: ElegantPermissionsWidget(
                permissions: testPermissions,
                isEditable: true,
                showHeader: false,
                onPermissionsChanged: (updatedPermissions) {
                  print(
                      'Permissions changed: ${updatedPermissions.toString()}');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _testUserListWidget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: _userProvider,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('User List Test'),
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            body: UserListWidget(
              currentUserId: 'demo_current_user', // In real app: use cloudHub.userId
              onPermissionsChanged: (user, permissions) {
                print(
                    'Permissions updated for ${user.firstname}: $permissions');
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MockFenceServiceClient extends FenceServiceClient {
  _MockFenceServiceClient() : super(ClientChannel('localhost'));
}

void main() {
  runApp(MaterialApp(
    title: 'Permission Dialog Test',
    theme: ThemeData(primarySwatch: Colors.green),
    home: const TestPermissionsDialog(),
    debugShowCheckedModeBanner: false,
  ));
}
