import 'package:flutter/foundation.dart';
import 'boutique_events.dart';
import 'lazy_boutique_listener.dart';

/// Integration helper for boutique sync notifications
/// This shows the recommended way to integrate boutique notifications
/// in your app without unnecessary overhead
class BoutiqueSyncIntegration {
  static LazyBoutiqueListener? _listener;
  
  /// Initialize the boutique listener when cloud sync becomes active
  /// Call this when the user enables cloud sync or when you know
  /// boutique data will be modified through the boutiques package
  static void initialize(BoutiqueBus eventBus, {
    void Function(BoutiqueEvent)? onBoutiqueCreated,
    void Function(BoutiqueEvent)? onBoutiqueUpdated,
    void Function(BoutiqueEvent)? onBoutiqueDeleted,
    void Function(BoutiqueEvent)? onBoutiqueRefreshed,
  }) {
    if (_listener != null) {
      debugPrint('BoutiqueSyncIntegration: Already initialized');
      return;
    }

    _listener = LazyBoutiqueListener(
      eventBus,
      onEvent: (event) {
        // Handle all events here if needed
        switch (event.type) {
          case BoutiqueEventType.created:
            onBoutiqueCreated?.call(event);
            break;
          case BoutiqueEventType.updated:
            onBoutiqueUpdated?.call(event);
            break;
          case BoutiqueEventType.deleted:
            onBoutiqueDeleted?.call(event);
            break;
          case BoutiqueEventType.refreshed:
            onBoutiqueRefreshed?.call(event);
            break;
        }
      },
    );

    // Activate the listener
    _listener!.activate();
    debugPrint('BoutiqueSyncIntegration: Initialized and activated');
  }

  /// Deactivate the listener when cloud sync is disabled
  /// This prevents unnecessary overhead when the user is offline
  static void deactivate() {
    _listener?.deactivate();
    debugPrint('BoutiqueSyncIntegration: Deactivated');
  }

  /// Reactivate the listener when cloud sync is re-enabled
  static void reactivate() {
    _listener?.activate();
    debugPrint('BoutiqueSyncIntegration: Reactivated');
  }

  /// Clean up the listener (call this when the app is disposed)
  static void dispose() {
    _listener?.dispose();
    _listener = null;
    debugPrint('BoutiqueSyncIntegration: Disposed');
  }

  /// Check if the integration is active
  static bool get isActive => _listener?.isActive ?? false;
}

/// Example of how to integrate this in your app's cloud sync logic
/// 
/// ```dart
/// class CloudSyncManager {
///   final BoutiqueProvider _boutiqueProvider;
///   
///   CloudSyncManager(this._boutiqueProvider);
///   
///   void enableCloudSync() {
///     // Your existing cloud sync logic...
///     
///     // Initialize boutique notifications
///     BoutiqueSyncIntegration.initialize(
///       _boutiqueProvider.eventBus,
///       onBoutiqueUpdated: (event) {
///         // Refresh your local boutique data
///         _refreshLocalBoutiqueData();
///       },
///       onBoutiqueDeleted: (event) {
///         // Remove boutique from local storage
///         _removeBoutiqueFromLocalStorage(event.boutiqueId!);
///       },
///     );
///   }
///   
///   void disableCloudSync() {
///     // Your existing logic...
///     
///     // Deactivate boutique notifications
///     BoutiqueSyncIntegration.deactivate();
///   }
/// }
/// ```
