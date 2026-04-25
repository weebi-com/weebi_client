import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_weebi/weebi_users.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:protos_weebi/grpc.dart';

/// Simple example showing Route Factory Pattern integration
/// This demonstrates the cleanest way to integrate user management
class SimpleNavigationExample extends StatefulWidget {
  const SimpleNavigationExample({super.key});

  @override
  State<SimpleNavigationExample> createState() => _SimpleNavigationExampleState();
}

class _SimpleNavigationExampleState extends State<SimpleNavigationExample> {
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
        title: 'Simple Navigation Example',
        
        // Clean route integration using Route Factory Pattern
        routes: {
          '/': (context) => const MainMenuScreen(),
          ...UserRoutes.getMaterialRoutes(currentUserId: ''), // Package provides clean routes!
        },
      ),
    );
  }
}

/// Your main menu with drawer navigation (like your current app)
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Menu')),
      drawer: const DrawerWeebi(),
      body: const Center(
        child: Text(
          'Welcome to the app!\nOpen the drawer to navigate to users.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

/// Your drawer (like DrawerWeebi in your actual app)
class DrawerWeebi extends StatelessWidget {
  const DrawerWeebi({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Weebi Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () => Navigator.pop(context),
          ),
          
          // This is YOUR exact pattern
                     ListTile(
             leading: const Icon(Icons.group),
             title: const Text('Utilisateurs'), 
             onTap: () {
               Navigator.pop(context); // Close drawer
               Navigator.pushNamed(context, '/users'); // Clean route navigation!
             },
           ),
          
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // No need for custom navigation - routes handle everything!
}

/// Mock FenceServiceClient for the example
class _MockFenceServiceClient extends FenceServiceClient {
  _MockFenceServiceClient() : super(ClientChannel('localhost'));
}

void main() {
  runApp(const SimpleNavigationExample());
} 