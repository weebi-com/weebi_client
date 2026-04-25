import 'package:flutter/material.dart';
import 'package:boutiques_weebi/boutiques_weebi.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

/// Example showing how to integrate BoutiqueListWithBus into your custom scaffold
class CustomScaffoldIntegrationExample extends StatelessWidget {
  const CustomScaffoldIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return BoutiqueRoutes.buildBoutiqueListWithCustomScaffold(
      appBar: AppBar(
        title: const Text('My Boutiques'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: const MyCustomDrawer(),
      endDrawer: null,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewBoutique(context),
        child: const Icon(Icons.add),
      ),
      userPermissions: _getUserPermissions(), // Your user permissions
    );
  }

  /// Example of how to handle boutique changes in your custom scaffold
  /// This is automatically called by BoutiqueListWithBus
  // ignore: unused_element
  void _handleBoutiqueChanges(BoutiqueEvent event) {
    switch (event.type) {
      case BoutiqueEventType.updated:
        // Refresh your local boutique data
        _refreshLocalBoutiqueData(event.boutiqueId!);
        break;
      case BoutiqueEventType.deleted:
        // Remove boutique from local storage
        _removeBoutiqueFromLocalStorage(event.boutiqueId!);
        break;
      case BoutiqueEventType.refreshed:
        // Refresh all local boutique data
        _refreshAllLocalBoutiqueData();
        break;
      case BoutiqueEventType.created:
        // Add new boutique to local storage
        _addBoutiqueToLocalStorage(event.chainId!);
        break;
    }
  }

  void _refreshLocalBoutiqueData(String boutiqueId) {
    // Your existing logic to refresh local boutique data
    ////print('Refreshing boutique data for: $boutiqueId');
  }

  void _removeBoutiqueFromLocalStorage(String boutiqueId) {
    // Your existing logic to remove boutique from local storage
    //print('Removing boutique from local storage: $boutiqueId');
  }

  void _refreshAllLocalBoutiqueData() {
    // Your existing logic to refresh all local boutique data
    //print('Refreshing all local boutique data');
  }

  void _addBoutiqueToLocalStorage(String chainId) {
    // Your existing logic to add boutique to local storage
    // print('Adding boutique to local storage for chain: $chainId');
  }

  UserPermissions? _getUserPermissions() {
    // Return your user permissions here
    // This enables CRUD operations in the boutique list
    return null; // Replace with your actual permissions
  }

  void _createNewBoutique(BuildContext context) {
    // Your existing logic to create a new boutique
    //print('Creating new boutique');
  }
}

/// Example custom drawer
class MyCustomDrawer extends StatelessWidget {
  const MyCustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'My App',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Boutiques'),
            onTap: () => Navigator.pop(context),
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

/// Alternative: If you want to customize the bus handling further
class AdvancedCustomScaffoldExample extends StatelessWidget {
  const AdvancedCustomScaffoldExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Boutiques')),
      body: BoutiqueListWithBus(
        showChainHeaders: true,
        allowSelection: true,
        userPermissions: _getUserPermissions(),
        
        // Handle boutique changes with your custom logic
        onBoutiqueChanged: (event) {
          // Your custom boutique change handling
          _handleBoutiqueChanges(event);
        },
        
        // All the same callbacks as BoutiqueListWidget
        onBoutiqueSelected: (boutique) {
          // Navigate to boutique detail
          //print('Selected boutique: ${boutique.displayName}');
        },
        onChainSelected: (chain) {
          // Navigate to chain detail
          //print('Selected chain: ${chain.name}');
        },
        // ... other callbacks
      ),
    );
  }

  void _handleBoutiqueChanges(BoutiqueEvent event) {
    // Your custom logic here
    //print('Boutique event: ${event.type}');
  }

  UserPermissions? _getUserPermissions() {
    // Your user permissions logic
    return null;
  }
}
