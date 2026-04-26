import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:users_weebi/weebi_users.dart';

/// Example showing how to integrate the beautiful UserCreateView
/// with proper navigation and user management workflows
///
/// 🔗 LINKING USER CREATION WITH ACCESS MANAGEMENT:
/// This example demonstrates how to use the `onUserCreated` callback
/// to seamlessly connect user creation with access management (boutiques/chains).
///
/// In your client app with both `users_weebi` and `accesses` packages:
/// ```dart
/// UserCreateView(
///   onUserCreated: (createdUser) {
///     // Navigate to access management for the newly created user
///     Navigator.push(
///       context,
///       MaterialPageRoute(
///         builder: (context) => UserAccessWidget(user: createdUser),
///       ),
///     );
///   },
/// )
/// ```
class UserCreateExample extends StatefulWidget {
  const UserCreateExample({super.key});

  @override
  State<UserCreateExample> createState() => _UserCreateExampleState();
}

class _UserCreateExampleState extends State<UserCreateExample> {
  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _setupUserProvider();
  }

  void _setupUserProvider() {
    _userProvider = UserProvider(
      _MockFenceServiceClient(), // Replace with your actual FenceServiceClient
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: _userProvider),
      ],
      child: MaterialApp(
        title: 'User Creation Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const UserManagementDashboard(),
        onGenerateRoute: (settings) {
          if (settings.name == '/create-user') {
            return MaterialPageRoute(
              builder: (context) => UserCreateView(
                // 🔗 This callback links user creation with access management
                onUserCreated: (context, createdUser) {
                  // In a real app with the 'accesses' package, navigate to:
                  // Navigator.push(context, MaterialPageRoute(
                  //   builder: (_) => UserAccessWidget(user: createdUser),
                  // ));
                  
                  // For this example, we'll show a demo dialog
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Access Management'),
                      content: Text(
                        'In your client app, you would now navigate to:\n\n'
                        'UserAccessWidget(user: ${createdUser.firstname} ${createdUser.lastname})\n\n'
                        'to set up which boutiques and chains they can access.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Got it!'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
          if (settings.name == '/users') {
            return MaterialPageRoute(
              builder: (context) => const UserListView(),
            );
          }
          return null;
        },
      ),
    );
  }
}

/// Dashboard showing user management options
class UserManagementDashboard extends StatelessWidget {
  const UserManagementDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'User Management Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your team members and their permissions',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 32),

            // Action Cards
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    title: 'Create New User',
                    subtitle: 'Add a new team member with custom permissions',
                    icon: Icons.person_add,
                    color: Colors.green,
                    onTap: () => Navigator.pushNamed(context, '/create-user'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionCard(
                    title: 'Manage Users',
                    subtitle: 'View and edit existing users',
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () => Navigator.pushNamed(context, '/users'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Stats',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        return Column(
                          children: [
                            _StatRow(
                              icon: Icons.people,
                              label: 'Total Users',
                              value: '${userProvider.users.length}',
                            ),
                            const SizedBox(height: 8),
                            _StatRow(
                              icon: Icons.admin_panel_settings,
                              label: 'Users with Admin Rights',
                              value: '${_countAdminUsers(userProvider.users)}',
                            ),
                            const SizedBox(height: 8),
                            _StatRow(
                              icon: Icons.verified_user,
                              label: 'Active Users',
                              value: '${userProvider.users.length}',
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Example Features Section
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.blue[600]),
                        const SizedBox(width: 8),
                        const Text(
                          'Features Included',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _FeatureItem(text: '✅ Beautiful form validation'),
                    const _FeatureItem(
                        text: '✅ Comprehensive permission setup'),
                    const _FeatureItem(text: '✅ Country code picker for phone'),
                    const _FeatureItem(text: '✅ Real-time permission preview'),
                    const _FeatureItem(
                        text: '✅ Auto-generated unique user IDs'),
                    const _FeatureItem(text: '✅ Seamless navigation flow'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _countAdminUsers(List<UserPublic> users) {
    // Count users with admin permissions (this is a simplified example)
    return users.where((user) {
      // In a real app, you'd check the actual permissions
      return user.permissions.boutiqueRights.rights.contains(Right.create);
    }).length;
  }
}

/// User list view showing all users
class UserListView extends StatelessWidget {
  const UserListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/create-user'),
            icon: const Icon(Icons.person_add),
            tooltip: 'Create New User',
          ),
        ],
      ),
      body: const UserListWidget(
        currentUserId: 'demo_current_user', // In real app: use cloudHub.userId
      ),
    );
  }
}

/// Reusable action card widget
class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stat row widget for dashboard
class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.grey)),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Feature item widget
class _FeatureItem extends StatelessWidget {
  final String text;

  const _FeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}

/// Mock FenceServiceClient for demonstration
/// In a real app, you would use your actual FenceServiceClient implementation
class _MockFenceServiceClient extends FenceServiceClient {
  _MockFenceServiceClient() : super(ClientChannel('localhost'));

  // Simple mock that doesn't override complex methods
  // The UserProvider will handle service calls gracefully
}

/// Main function for running the example
void main() {
  runApp(const UserCreateExample());
}
