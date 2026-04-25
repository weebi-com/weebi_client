import 'package:flutter/material.dart';
import 'package:boutiques_weebi/boutiques_weebi.dart';

/// Simple example showing how to use the boutique bus
/// Just replace BoutiqueListWidget with BoutiqueListWithBus
class SimpleBusUsageExample extends StatelessWidget {
  const SimpleBusUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boutiques with Bus')),
      body: BoutiqueListWithBus(
        // All the same props as BoutiqueListWidget
        showChainHeaders: true,
        allowSelection: true,
        
        // NEW: Handle boutique changes
        onBoutiqueChanged: (event) {
          // This is called whenever boutique data changes
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
        },
      ),
    );
  }

  void _refreshLocalBoutiqueData(String boutiqueId) {
    // Your existing logic to refresh local boutique data
    // print('Refreshing boutique data for: $boutiqueId');
  }

  void _removeBoutiqueFromLocalStorage(String boutiqueId) {
    // Your existing logic to remove boutique from local storage
    // print('Removing boutique from local storage: $boutiqueId');
  }

  void _refreshAllLocalBoutiqueData() {
    // Your existing logic to refresh all local boutique data
    // print('Refreshing all local boutique data');
  }

  void _addBoutiqueToLocalStorage(String chainId) {
    // Your existing logic to add boutique to local storage
    // print('Adding boutique to local storage for chain: $chainId');
  }
}

/// Migration guide: How to update your existing code
/// 
/// BEFORE:
/// ```dart
/// BoutiqueListWidget(
///   showChainHeaders: true,
///   allowSelection: true,
///   // ... other props
/// )
/// ```
/// 
/// AFTER:
/// ```dart
/// BoutiqueListWithBus(
///   showChainHeaders: true,
///   allowSelection: true,
///   // ... other props (same as before)
///   onBoutiqueChanged: (event) {
///     // Handle boutique changes here
///   },
/// )
/// ```
