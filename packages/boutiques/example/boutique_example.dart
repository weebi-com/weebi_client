import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boutiques_weebi/boutiques_weebi.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, you would create the FenceServiceClient here
    // final fenceServiceClient = FenceServiceClient(...);

    return ChangeNotifierProvider(
      // create: (context) => BoutiqueProvider(fenceServiceClient),
      create: (context) => BoutiqueProvider(_createMockFenceServiceClient()),
      child: MaterialApp(
        title: 'Boutiques Weebi Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // Add boutique routes
        routes: {
          ...BoutiqueRoutes.getMaterialRoutes(),
          '/': (context) => HomePage(),
          '/permissions-demo': (context) => PermissionsDemoPage(),
        },
        onGenerateRoute: BoutiqueRoutes.onGenerateRoute,
        home: HomePage(),
      ),
    );
  }

  // Mock client for demonstration purposes
  FenceServiceClient _createMockFenceServiceClient() {
    // In a real app, this would be a proper gRPC client
    throw UnimplementedError('Replace with actual FenceServiceClient');
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Boutiques Weebi Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Boutiques Management Demo',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This example demonstrates the boutiques_weebi package functionality:',
                    ),
                    SizedBox(height: 12),
                    Text('• View boutiques grouped by chains'),
                    Text('• Search and filter boutiques'),
                    Text('• Manage user permissions'),
                    Text('• Navigate between different views'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => BoutiqueRoutes.navigateToBoutiqueList(context),
              icon: Icon(Icons.store),
              label: Text('View Boutiques & Chains'),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/permissions-demo'),
              icon: Icon(Icons.admin_panel_settings),
              label: Text('Permissions Management Demo'),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showQuickStatsDialog(context),
              icon: Icon(Icons.analytics),
              label: Text('View Quick Stats'),
            ),
            SizedBox(height: 24),
            Expanded(
              child: Consumer<BoutiqueProvider>(
                builder: (context, provider, child) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current State',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: 12),
                          if (provider.isLoading)
                            Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('Loading...'),
                              ],
                            )
                          else if (provider.error != null)
                            Row(
                              children: [
                                Icon(Icons.error, color: Colors.red, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                    child: Text('Error: ${provider.error}')),
                              ],
                            )
                          else ...[
                            _buildStatRow(
                              'Chains',
                              provider.chains.length.toString(),
                              Icons.account_tree,
                            ),
                            _buildStatRow(
                              'Total Boutiques',
                              provider.allBoutiques.length.toString(),
                              Icons.store,
                            ),
                            _buildStatRow(
                              'Active Boutiques',
                              provider.activeBoutiques.length.toString(),
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            if (provider.selectedChain != null)
                              _buildStatRow(
                                'Selected Chain',
                                provider.selectedChain!.name,
                                Icons.radio_button_checked,
                                color: Colors.blue,
                              ),
                            if (provider.selectedBoutique != null)
                              _buildStatRow(
                                'Selected Boutique',
                                provider.selectedBoutique!.displayName,
                                Icons.location_on,
                                color: Colors.orange,
                              ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 8),
          Text('$label: '),
          Expanded(
              child:
                  Text(value, style: TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _showQuickStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quick Statistics'),
        content: Consumer<BoutiqueProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading statistics...'),
                ],
              );
            }

            if (provider.error != null) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(height: 8),
                  Text('Error loading data'),
                ],
              );
            }

            final stats = {
              'Total Chains': provider.chains.length,
              'Total Boutiques': provider.allBoutiques.length,
              'Active Boutiques': provider.activeBoutiques.length,
              'Inactive Boutiques': provider.allBoutiques.length -
                  provider.activeBoutiques.length,
            };

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: stats.entries
                  .map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key),
                            Text(
                              entry.value.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

class PermissionsDemoPage extends StatelessWidget {
  const PermissionsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permissions Management'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demo: User Permissions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This demonstrates how admins can define user rights over chains and boutiques.',
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _showPermissionsForUser(
                            context, 'user1', 'Manager'),
                        child: Text('Manager Permissions'),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _showPermissionsForUser(
                            context, 'user2', 'Cashier'),
                        child: Text('Cashier Permissions'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: BoutiqueListWidget(
              userPermissions: _createMockUserPermissions(), // Use permissions-based CRUD
              allowSelection: true,
              onCreateChain: () {
                // Should open the chain create view, just like the user_create_view does
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BoutiqueCreateView.createChain(),
                  ),
                );
              },
              onCreateBoutique: (chainId) {
                // Should open the boutique create view, just like the user_create_view does
                if (chainId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BoutiqueCreateView.createBoutique(chainId: chainId),
                    ),
                  );
                }
              },
              onChainEdit: (chain) {
                // Should open the chain update view/dialog, just like the UserFormWidget
                _editChain(context, chain);
              },
              onChainDelete: (chain) {
                // Should pop the _showDeleteConfirmation and trigger a deletion
                _deleteChain(context, chain);
              },
              onBoutiqueEdit: (boutique) {
                // Should open the boutique update view/dialog, just like the UserFormWidget
                _editBoutique(context, boutique);
              },
              onBoutiqueDelete: (boutique) {
                // Should pop the _showDeleteConfirmation and trigger a deletion
                _deleteBoutique(context, boutique);
              },
              onBoutiqueSelected: (boutique) {
                // Should open the boutique view, just like the user_detail_widget.dart
                BoutiqueRoutes.navigateToBoutiqueDetailView(
                  context,
                  boutique,
                  onEdit: () => _editBoutique(context, boutique),
                  onDelete: () => _deleteBoutique(context, boutique),
                );
              },
              onChainSelected: (chain) {
                // Should open the chain view, just like the user_detail_widget.dart
                BoutiqueRoutes.navigateToChainDetailView(
                  context,
                  chain,
                  onEdit: () => _editChain(context, chain),
                  onDelete: () => _deleteChain(context, chain),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionsForUser(
      BuildContext context, String userId, String role) {
    // Navigate to boutique list (permissions widget was removed)
    BoutiqueRoutes.navigateToBoutiqueList(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing boutiques for $userId ($role) - Permissions widget removed'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Create mock user permissions with full CRUD access for demo purposes
  UserPermissions _createMockUserPermissions() {
    return UserPermissions(
      boutiqueRights: BoutiqueRights(
        rights: [Right.create, Right.read, Right.update, Right.delete],
      ),
      chainRights: ChainRights(
        rights: [Right.create, Right.read, Right.update, Right.delete],
      ),
      // Add other required fields as needed for the demo
    );
  }

  // CRUD operation implementations following your specifications

  /// Edit boutique - should open the boutique update view/dialog, just like the UserFormWidget
  void _editBoutique(BuildContext context, BoutiqueMongo boutique) {
    BoutiqueRoutes.showBoutiqueEditDialog(
      context,
      boutique: boutique,
      onSaved: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Boutique "${boutique.displayName}" updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  /// Edit chain - should open the chain update view/dialog, just like the UserFormWidget
  void _editChain(BuildContext context, Chain chain) {
    BoutiqueRoutes.showChainEditDialog(
      context,
      chain: chain,
      onSaved: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chain "${chain.name}" updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  /// Delete boutique - should pop the _showDeleteConfirmation and trigger a deletion
  void _deleteBoutique(BuildContext context, BoutiqueMongo boutique) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Boutique'),
        content: Text('Are you sure you want to delete "${boutique.displayName}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In real app: context.read<BoutiqueProvider>().deleteBoutique(boutique);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Boutique "${boutique.displayName}" deleted - Demo Action'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Delete chain - should pop the _showDeleteConfirmation and, if no boutiques in it, 
  /// trigger a deletion of the chain and all the boutiques in it
  void _deleteChain(BuildContext context, Chain chain) {
    final hasBoutiques = chain.boutiques.isNotEmpty;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chain'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${chain.name}"?'),
            if (hasBoutiques) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        const Text('Warning', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('This chain contains ${chain.boutiques.length} boutique(s). '
                         'Deleting this chain will also delete all boutiques in it.'),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Text('This action cannot be undone.', style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In real app: context.read<BoutiqueProvider>().deleteChain(chain);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    hasBoutiques 
                        ? 'Chain "${chain.name}" and ${chain.boutiques.length} boutiques deleted - Demo Action'
                        : 'Chain "${chain.name}" deleted - Demo Action'
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(hasBoutiques ? 'Delete Chain & Boutiques' : 'Delete Chain'),
          ),
        ],
      ),
    );
  }

}
