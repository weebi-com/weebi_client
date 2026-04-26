import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:users_weebi/weebi_users.dart';
// import 'package:accesses/accesses.dart'; // Uncomment in your app

/// COPY-PASTE READY EXAMPLE for your client app
/// This shows how to connect user creation with access management
/// Route configuration for user management with access flow
class UserManagementRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/users/create':
        return MaterialPageRoute(
          builder: (context) => _buildUserCreateScreen(context),
        );
      
      case '/users/list':
        return MaterialPageRoute(
          builder: (context) => const UserListWidget(
            currentUserId: 'YOUR_CURRENT_USER_ID',
          ),
        );
      
      default:
        return null;
    }
  }

  /// Build user creation screen with access management flow
  static Widget _buildUserCreateScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New User'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: UserCreateView(
        // UserCreateView includes its own FAB by default
        
        // 🔗 THIS IS THE KEY: Connect to access management
        onUserCreated: (context, createdUser) {
          // After user is created, navigate to access setup
          _navigateToAccessSetup(context, createdUser);
        },
      ),
    );
  }

  /// Navigate to access setup for the newly created user
  static void _navigateToAccessSetup(BuildContext context, UserPublic user) {
    // REPLACE THIS with your actual UserAccessWidget from accesses package
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AccessSetupPlaceholder(user: user),
      ),
    );
    
    /* IN YOUR REAL APP, USE THIS:
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Set Access for ${user.firstname}'),
          ),
          body: UserAccessWidget(user: user),
        ),
      ),
    );
    */
  }
}

/// Placeholder for access setup screen
/// REPLACE this with your actual UserAccessWidget from accesses package
class _AccessSetupPlaceholder extends StatelessWidget {
  final UserPublic user;

  const _AccessSetupPlaceholder({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Access for ${user.firstname}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_open, size: 64, color: Colors.blue[600]),
              const SizedBox(height: 24),
              Text(
                'Access Setup for',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '${user.firstname} ${user.lastname}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 32),
              Container(
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
                      '📝 In your client app, replace this placeholder with:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'UserAccessWidget(user: user)',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This widget lets admins select which boutiques and chains the user can access.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// HOW TO USE IN YOUR APP:
///
/// 1. Add this to your MaterialApp:
///    ```dart
///    MaterialApp(
///      onGenerateRoute: UserManagementRoutes.onGenerateRoute,
///      // ... rest of your app
///    )
///    ```
///
/// 2. Navigate to user creation:
///    ```dart
///    Navigator.pushNamed(context, '/users/create');
///    ```
///
/// 3. Replace _AccessSetupPlaceholder with your actual UserAccessWidget
///
/// 4. That's it! The flow is now:
///    Create User → Dialog Prompt → Set Access → Done ✓

