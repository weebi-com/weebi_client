import 'package:flutter/foundation.dart';
import 'boutique_events.dart';

/// A helper class to listen for boutique events and handle them
/// This can be used in the client app to react to boutique data changes
class BoutiqueListener {
  final BoutiqueBus _eventBus;
  final void Function(BoutiqueEvent)? _onEvent;
  bool _isListening = false;

  BoutiqueListener(this._eventBus, {void Function(BoutiqueEvent)? onEvent})
      : _onEvent = onEvent;

  /// Start listening for boutique events
  void startListening() {
    if (!_isListening) {
      _eventBus.listen(_handleEvent);
      _isListening = true;
      debugPrint('BoutiqueListener: Started listening for boutique events');
    }
  }

  /// Stop listening for boutique events
  void stopListening() {
    if (_isListening) {
      _eventBus.unlisten(_handleEvent);
      _isListening = false;
      debugPrint('BoutiqueListener: Stopped listening for boutique events');
    }
  }

  /// Handle incoming boutique events
  void _handleEvent(BoutiqueEvent event) {
    debugPrint('BoutiqueListener: Received event: $event');
    
    // Call the custom handler if provided
    _onEvent?.call(event);
    
    // Handle specific event types
    switch (event.type) {
      case BoutiqueEventType.created:
        _onBoutiqueCreated(event);
        break;
      case BoutiqueEventType.updated:
        _onBoutiqueUpdated(event);
        break;
      case BoutiqueEventType.deleted:
        _onBoutiqueDeleted(event);
        break;
      case BoutiqueEventType.refreshed:
        _onBoutiqueRefreshed(event);
        break;
    }
  }

  /// Called when a boutique is created
  void _onBoutiqueCreated(BoutiqueEvent event) {
    debugPrint('BoutiqueListener: Boutique created - Chain: ${event.chainId}');
    // Override this method in subclasses or use the onEvent callback
  }
  /// Called when a boutique is updated
  void _onBoutiqueUpdated(BoutiqueEvent event) {
    debugPrint('BoutiqueListener: Boutique updated - ID: ${event.boutiqueId}, Chain: ${event.chainId}');
    // Override this method in subclasses or use the onEvent callback
  }

  /// Called when a boutique is deleted
  void _onBoutiqueDeleted(BoutiqueEvent event) {
    debugPrint('BoutiqueListener: Boutique deleted - ID: ${event.boutiqueId}, Chain: ${event.chainId}');
    // Override this method in subclasses or use the onEvent callback
  }

  /// Called when boutique data is refreshed
  void _onBoutiqueRefreshed(BoutiqueEvent event) {
    debugPrint('BoutiqueListener: Boutique data refreshed');
    // Override this method in subclasses or use the onEvent callback
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Dispose the listener
  void dispose() {
    stopListening();
  }
}
