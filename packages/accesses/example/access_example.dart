import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accesses_weebi/accesses_weebi.dart';
import 'package:users_weebi/weebi_users.dart';
import 'package:boutiques_weebi/boutiques_weebi.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

void main() {
  runApp(const AccessExampleApp());
}

class AccessExampleApp extends StatelessWidget {
  const AccessExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // For demo purposes, use a mock currentUserId
    const currentUserId = 'admin-user-id';

    return AccessRoutes.createStandaloneAccessApp(
      currentUserId: currentUserId,
      title: 'Access Management Demo',
    );
  }
}

/// Alternative example showing how to integrate accesses into existing app
class IntegratedAccessExample extends StatelessWidget {
  const IntegratedAccessExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Integrated Access Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AccessDemoHome(),
    );
  }
}

class AccessDemoHome extends StatelessWidget {
  const AccessDemoHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Management Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Access Management Package Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToAccessManagement(context),
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Manage User Access'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showUserAccessModal(context),
              icon: const Icon(Icons.person),
              label: const Text('Show User Access Modal'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAccessManagement(BuildContext context) {
    // Setup providers and navigate
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UserProvider(_MockFenceServiceClient())),
            ChangeNotifierProvider(create: (_) => BoutiqueProvider(_MockFenceServiceClient())),
            ChangeNotifierProxyProvider2<UserProvider, BoutiqueProvider, AccessProvider>(
              create: (context) => AccessProvider(
                userProvider: context.read<UserProvider>(),
                boutiqueProvider: context.read<BoutiqueProvider>(),
              ),
              update: (context, userProvider, boutiqueProvider, previous) =>
                  previous ?? AccessProvider(
                    userProvider: userProvider,
                    boutiqueProvider: boutiqueProvider,
                  ),
            ),
          ],
          child: Scaffold(
            appBar: AppBar(
              title: const Text('User Access Management'),
            ),
            body: const AccessListWidget(currentUserId: 'admin-user-id'),
          ),
        ),
      ),
    );
  }

  void _showUserAccessModal(BuildContext context) {
    // Create a mock user for demo
    final mockUser = UserPublic.create();
    mockUser.userId = 'demo-user-id';
    mockUser.firstname = 'John';
    mockUser.lastname = 'Doe';
    mockUser.mail = 'john.doe@example.com';

    // Setup providers and show modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => MultiProvider(
        providers: [
            ChangeNotifierProvider(create: (_) => UserProvider(_MockFenceServiceClient())),
            ChangeNotifierProvider(create: (_) => BoutiqueProvider(_MockFenceServiceClient())),
          ChangeNotifierProxyProvider2<UserProvider, BoutiqueProvider, AccessProvider>(
            create: (context) => AccessProvider(
              userProvider: context.read<UserProvider>(),
              boutiqueProvider: context.read<BoutiqueProvider>(),
            ),
            update: (context, userProvider, boutiqueProvider, previous) =>
                previous ?? AccessProvider(
                  userProvider: userProvider,
                  boutiqueProvider: boutiqueProvider,
                ),
          ),
        ],
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'John Doe - Access Management',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: UserAccessWidget(user: mockUser),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Mock FenceServiceClient for demo purposes
class _MockFenceServiceClient implements FenceServiceClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
