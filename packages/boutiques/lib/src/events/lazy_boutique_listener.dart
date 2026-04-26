import 'package:flutter/foundation.dart';
import 'boutique_events.dart';

/// A lazy-loading boutique listener that only activates when needed
/// This prevents unnecessary overhead when cloud sync is not active
class LazyBoutiqueListener {
  final BoutiqueBus _eventBus;
  final void Function(BoutiqueEvent)? _onEvent;
  bool _isListening = false;
  bool _isActive = false;

  LazyBoutiqueListener(this._eventBus, {void Function(BoutiqueEvent)? onEvent})
      : _onEvent = onEvent;

  /// Activate the listener (only when cloud sync is active)
  void activate() {
    if (!_isActive) {
      _isActive = true;
      if (!_isListening) {
        _eventBus.listen(_handleEvent);
        _isListening = true;
        debugPrint('LazyBoutiqueListener: Activated and listening for boutique events');
      }
    }
  }

  /// Deactivate the listener (when cloud sync is disabled)
  void deactivate() {
    if (_isActive) {
      _isActive = false;
      if (_isListening) {
        _eventBus.unlisten(_handleEvent);
        _isListening = false;
        debugPrint('LazyBoutiqueListener: Deactivated and stopped listening');
      }
    }
  }

  /// Handle incoming boutique events
  void _handleEvent(BoutiqueEvent event) {
    if (!_isActive) return; // Skip if not active
    
    debugPrint('LazyBoutiqueListener: Received event: $event');
    
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
    debugPrint('LazyBoutiqueListener: Boutique created - Chain: ${event.chainId}');
    // Override this method in subclasses or use the onEvent callback
  }

  /// Called when a boutique is updated
  void _onBoutiqueUpdated(BoutiqueEvent event) {
    debugPrint('LazyBoutiqueListener: Boutique updated - ID: ${event.boutiqueId}, Chain: ${event.chainId}');
    // Override this method in subclasses or use the onEvent callback
  }

  /// Called when a boutique is deleted
  void _onBoutiqueDeleted(BoutiqueEvent event) {
    debugPrint('LazyBoutiqueListener: Boutique deleted - ID: ${event.boutiqueId}, Chain: ${event.chainId}');
    // Override this method in subclasses or use the onEvent callback
  }

  /// Called when boutique data is refreshed
  void _onBoutiqueRefreshed(BoutiqueEvent event) {
    debugPrint('LazyBoutiqueListener: Boutique data refreshed');
    // Override this method in subclasses or use the onEvent callback
  }

  /// Check if currently active and listening
  bool get isActive => _isActive;
  bool get isListening => _isListening;

  /// Dispose the listener
  void dispose() {
    deactivate();
  }
}
