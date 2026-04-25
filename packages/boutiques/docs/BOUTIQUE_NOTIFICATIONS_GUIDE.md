# Boutique Bus Guide

This guide explains how to use the boutique bus to keep your client app synchronized when boutique data changes through the `boutiques` package.

## Overview

The boutique bus provides a simple way for the `boutiques` package to notify other parts of your app when boutique data has been modified. This is particularly useful for:

- Updating offline-first views when boutique data changes
- Refreshing local storage when boutique information is updated
- Keeping different parts of your app in sync

## How It Works

1. **Bus**: A simple bus (`BoutiqueBus`) that allows the `boutiques` package to emit events
2. **Event Types**: Four types of events are emitted:
   - `created`: When a new boutique is created
   - `updated`: When an existing boutique is updated
   - `deleted`: When a boutique is deleted
   - `refreshed`: When boutique data is refreshed from the server
3. **Automatic Listening**: The bus is only active when the boutiques view is open

## Basic Usage

### 1. Update Your Client App's Route Configuration

Simply add the `onBoutiqueChanged` callback to your existing route configuration:

```dart
import 'package:boutiques_weebi/boutiques_weebi.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        // Your existing routes...
        ...BoutiqueRoutes.getProviderRoutes(
          getUserPermissions: (context) => _getUserPermissions(context),
          onBoutiqueChanged: _handleBoutiqueChanges, // NEW: Your boutique change handler
        ),
      },
    );
  }

  // Your client app's boutique change handler
  static void _handleBoutiqueChanges(BoutiqueEvent event) {
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
}
```

That's it! The bus automatically starts when the boutiques view opens and stops when it closes.

### 2. Update Your Local Storage

```dart
void _handleBoutiqueEvent(BoutiqueEvent event) {
  switch (event.type) {
    case BoutiqueEventType.updated:
      // Update your local boutique store
      final boutiqueStore = Provider.of<BoutiqueStore>(context, listen: false);
      boutiqueStore.refreshBoutiqueData();
      break;
    case BoutiqueEventType.created:
      // Add new boutique to local storage
      _addBoutiqueToLocalStorage(event.chainId);
      break;
    case BoutiqueEventType.deleted:
      // Remove boutique from local storage
      _removeBoutiqueFromLocalStorage(event.boutiqueId);
      break;
  }
}
```

### 3. Show User Notifications

```dart
void _handleBoutiqueEvent(BoutiqueEvent event) {
  // Show a snackbar or notification to the user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Boutique ${event.boutiqueId} has been updated'),
      duration: Duration(seconds: 3),
    ),
  );
}
```

## Advanced Usage

### Custom Boutique Listener

For more complex scenarios, you can create a custom listener:

```dart
class MyCustomBoutiqueListener extends BoutiqueListener {
  final VoidCallback? onDataChanged;
  final Function(String)? onBoutiqueDeleted;

  MyCustomBoutiqueListener(
    BoutiqueBus eventBus, {
    this.onDataChanged,
    this.onBoutiqueDeleted,
  }) : super(eventBus);

  @override
  void _onBoutiqueUpdated(BoutiqueEvent event) {
    super._onBoutiqueUpdated(event);
    // Custom logic for boutique updates
    onDataChanged?.call();
  }

  @override
  void _onBoutiqueDeleted(BoutiqueEvent event) {
    super._onBoutiqueDeleted(event);
    // Custom logic for boutique deletion
    onBoutiqueDeleted?.call(event.boutiqueId!);
  }
}
```

### Integration with Offline Storage

```dart
class OfflineBoutiqueManager {
  final BoutiqueBus _eventBus;
  late BoutiqueListener _listener;

  OfflineBoutiqueManager(this._eventBus) {
    _listener = BoutiqueListener(_eventBus, onEvent: _handleEvent);
    _listener.startListening();
  }

  void _handleEvent(BoutiqueEvent event) {
    switch (event.type) {
      case BoutiqueEventType.updated:
        _syncBoutiqueToLocalStorage(event.boutiqueId!);
        break;
      case BoutiqueEventType.deleted:
        _removeBoutiqueFromLocalStorage(event.boutiqueId!);
        break;
      case BoutiqueEventType.refreshed:
        _refreshAllLocalBoutiqueData();
        break;
    }
  }

  void _syncBoutiqueToLocalStorage(String boutiqueId) {
    // Your logic to sync boutique data to local storage
  }

  void _removeBoutiqueFromLocalStorage(String boutiqueId) {
    // Your logic to remove boutique from local storage
  }

  void _refreshAllLocalBoutiqueData() {
    // Your logic to refresh all local boutique data
  }

  void dispose() {
    _listener.dispose();
  }
}
```

## Event Details

### BoutiqueEvent Properties

- `type`: The type of event (created, updated, deleted, refreshed)
- `boutiqueId`: The ID of the boutique (null for refreshed events)
- `chainId`: The ID of the chain (null for refreshed events)
- `timestamp`: When the event occurred
- `metadata`: Additional event data (optional)

### Event Types

- **created**: Emitted when a new boutique is created
- **updated**: Emitted when a boutique is updated
- **deleted**: Emitted when a boutique is deleted
- **refreshed**: Emitted when boutique data is refreshed from the server

## Performance Considerations

### Zero Overhead When Inactive
The `LazyBoutiqueListener` and `BoutiqueSyncIntegration` are designed to have **zero performance overhead** when cloud sync is not active:

- **No memory usage** when deactivated
- **No CPU cycles** consumed when inactive  
- **No event processing** when cloud sync is disabled

### When to Activate
Only activate the listener when:
- User has enabled cloud sync
- Boutique data will be modified through the `boutiques` package
- You need to keep offline views synchronized

### Recommended Integration Points

```dart
// ✅ GOOD: Activate only when cloud sync is enabled
class CloudSyncManager {
  void enableCloudSync() {
    // Your existing cloud sync logic...
    
    // Initialize boutique notifications
    BoutiqueSyncIntegration.initialize(
      boutiqueProvider.eventBus,
      onBoutiqueUpdated: _handleBoutiqueUpdate,
    );
  }
  
  void disableCloudSync() {
    // Deactivate to save resources
    BoutiqueSyncIntegration.deactivate();
  }
}

// ❌ BAD: Don't activate at app startup
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Don't initialize here - user might not use cloud sync
    return MaterialApp(...);
  }
}
```

## Best Practices

1. **Lazy activation**: Only activate when cloud sync is enabled
2. **Always dispose**: Call `BoutiqueSyncIntegration.dispose()` when app is disposed
3. **Handle errors gracefully**: The event system includes error handling
4. **Use specific event types**: Listen for specific event types rather than handling all events generically
5. **Update UI appropriately**: Use `setState()` or state management solutions to update your UI when events occur
6. **Consider performance**: Don't perform heavy operations in event handlers; consider using `compute()` for CPU-intensive tasks

## Example Integration

See `example/boutique_notification_example.dart` for a complete working example that demonstrates:

- Setting up boutique event listeners
- Handling different event types
- Updating UI based on events
- Managing listener lifecycle

## Troubleshooting

### Common Issues

1. **Events not received**: Make sure you're listening to the same `BoutiqueBus` instance that the `BoutiqueProvider` is using
2. **Memory leaks**: Always dispose your listeners in the `dispose()` method
3. **UI not updating**: Make sure to call `setState()` or use your state management solution when handling events

### Debug Mode

The `BoutiqueListener` includes debug logging. You can see event notifications in your debug console when running in debug mode.

## Conclusion

This notification system provides a clean, simple way to keep your client app synchronized with boutique data changes. It's designed to be lightweight and easy to integrate into existing Flutter applications without requiring complex setup or external dependencies.
