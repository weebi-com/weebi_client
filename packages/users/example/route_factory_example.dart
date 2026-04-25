import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_weebi/weebi_users.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:protos_weebi/grpc.dart';

/// Example showing Route Factory Pattern integration
/// This is the CLEANEST way to integrate user management routes
class RouteFactoryExample extends StatefulWidget {
  const RouteFactoryExample({super.key});

  @override
  State<RouteFactoryExample> createState() => _RouteFactoryExampleState();
}

class _RouteFactoryExampleState extends State<RouteFactoryExample> {
  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = UserProvider(_MockFenceServiceClient());
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: _userProvider),
      ],
      child: MaterialApp(
        title: 'Route Factory Example',

        // Option 1: Use the provided routes directly
        routes: {
          '/': (context) => const MainMenuScreen(),
          ...UserRoutes.getMaterialRoutes(
              currentUserId: ''), // Package provides routes!
        },

        // Option 2: Or use onGenerateRoute for more control
        // onGenerateRoute: (settings) {
        //   // Try user routes first
        //   final userRoute = UserRoutes.onGenerateRoute(settings);
        //   if (userRoute != null) return userRoute;
        //
        //   // Handle other routes
        //   switch (settings.name) {
        //     case '/':
        //       return MaterialPageRoute(builder: (_) => const MainMenuScreen());
        //     default:
        //       return MaterialPageRoute(builder: (_) => const NotFoundScreen());
        //   }
        // },
      ),
    );
  }
}

/// Main menu that demonstrates clean navigation
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Factory Example')),
      drawer: const AppDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Route Factory Pattern',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Clean, organized route management for packages',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 32),
            Text('Open the drawer to navigate to user management'),
          ],
        ),
      ),
    );
  }
}

/// App drawer with clean navigation
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'App Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushReplacementNamed(context, '/');
            },
          ),

          // SUPER CLEAN: Just navigate to the route!
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Users'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushNamed(
                  context, '/users'); // Package handles everything!
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

/// Option 3: Custom integration with your existing Scaffold structure
class CustomUserManagementScreen extends StatelessWidget {
  const CustomUserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the route factory to build with YOUR scaffold structure
    return UserRoutes.buildUserListWithCustomScaffold(
      appBar: AppBar(
        title: const Text('My Custom User Management'),
        backgroundColor: Colors.purple,
      ),
      drawer: const AppDrawer(), // Your custom drawer
      endDrawer: null,
      currentUserId: '',
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/users/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Mock FenceServiceClient
class _MockFenceServiceClient extends FenceServiceClient {
  _MockFenceServiceClient() : super(ClientChannel('localhost'));
}

void main() {
  runApp(const RouteFactoryExample());
}
