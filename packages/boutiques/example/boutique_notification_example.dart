import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boutiques_weebi/boutiques_weebi.dart';

/// Example showing how to listen for boutique data changes
/// This demonstrates how the client app can be notified when boutique
/// information is updated through the boutiques package
class BoutiqueNotificationExample extends StatefulWidget {
  const BoutiqueNotificationExample({super.key});

  @override
  State<BoutiqueNotificationExample> createState() => _BoutiqueNotificationExampleState();
}

class _BoutiqueNotificationExampleState extends State<BoutiqueNotificationExample> {
  late BoutiqueListener _boutiqueListener;
  final List<String> _notifications = [];

  @override
  void initState() {
    super.initState();
    
    // Get the BoutiqueProvider from the widget tree
    final boutiqueProvider = context.read<BoutiqueProvider>();
    
    // Create a listener for boutique events
    _boutiqueListener = BoutiqueListener(
      boutiqueProvider.bus,
      onEvent: _handleBoutiqueEvent,
    );
    
    // Start listening for events
    _boutiqueListener.startListening();
  }

  @override
  void dispose() {
    _boutiqueListener.dispose();
    super.dispose();
  }

  /// Handle boutique events
  void _handleBoutiqueEvent(BoutiqueEvent event) {
    setState(() {
      _notifications.add(
        '${DateTime.now().toString().substring(11, 19)} - '
        '${_getEventDescription(event)}'
      );
    });
    
    // Here you can trigger any action you need:
    // - Refresh local boutique data
    // - Update UI
    // - Show notifications to user
    // - Sync with offline storage
    // - etc.
  }

  String _getEventDescription(BoutiqueEvent event) {
    switch (event.type) {
      case BoutiqueEventType.created:
        return 'New boutique created in chain ${event.chainId}';
      case BoutiqueEventType.updated:
        return 'Boutique ${event.boutiqueId} updated in chain ${event.chainId}';
      case BoutiqueEventType.deleted:
        return 'Boutique ${event.boutiqueId} deleted from chain ${event.chainId}';
      case BoutiqueEventType.refreshed:
        return 'Boutique data refreshed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boutique Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Show current boutique data
          Expanded(
            flex: 2,
            child: Consumer<BoutiqueProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                return ListView.builder(
                  itemCount: provider.chains.length,
                  itemBuilder: (context, index) {
                    final chain = provider.chains[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: const Icon(Icons.account_tree),
                        title: Text(chain.name),
                        subtitle: Text('${chain.boutiqueCount} boutiques'),
                        trailing: Text(chain.formattedLastUpdate),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Show notifications
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Boutique Change Notifications:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _notifications.isEmpty
                        ? const Text(
                            'No notifications yet. Try updating boutique data.',
                            style: TextStyle(color: Colors.grey),
                          )
                        : ListView.builder(
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  _notifications[index],
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/* /// Example of a custom boutique listener for specific use cases
class CustomBoutiqueListener extends BoutiqueListener {
  final VoidCallback? onBoutiqueDataChanged;
  final VoidCallback? onBoutiqueDeleted;

  CustomBoutiqueListener(
    BoutiqueBus eventBus, {
    this.onBoutiqueDataChanged,
    this.onBoutiqueDeleted,
  }) : super(eventBus);

  @override
  void _onBoutiqueCreated(BoutiqueEvent event) {
    super._onBoutiqueCreated(event);
    // Custom logic for boutique creation
    onBoutiqueDataChanged?.call();
  }

  @override
  void _onBoutiqueUpdated(BoutiqueEvent event) {
    super._onBoutiqueUpdated(event);
    // Custom logic for boutique updates
    onBoutiqueDataChanged?.call();
  }

  @override
  void _onBoutiqueDeleted(BoutiqueEvent event) {
    super._onBoutiqueDeleted(event);
    // Custom logic for boutique deletion
    onBoutiqueDeleted?.call();
  }

  @override
  void _onBoutiqueRefreshed(BoutiqueEvent event) {
    super._onBoutiqueRefreshed(event);
    // Custom logic for data refresh
    onBoutiqueDataChanged?.call();
  }
}
 */