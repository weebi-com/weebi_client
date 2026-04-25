import 'package:flutter/foundation.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

/// Event types for boutique data changes
enum BoutiqueEventType {
  created, // not need in weebi's common use case
  updated,
  deleted,
  refreshed,
}

/// Event data for boutique changes
class BoutiqueEvent {
  final BoutiqueEventType type;
  final String? boutiqueId;
  final String? chainId;
  final Timestamp timestamp;
  final Map<String, dynamic>? metadata;

  BoutiqueEvent({
    required this.type,
    this.boutiqueId,
    this.chainId,
    Timestamp? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? Timestamp.fromDateTime(DateTime.now());

  @override
  String toString() {
    return 'BoutiqueEvent(type: $type, boutiqueId: $boutiqueId, chainId: $chainId, timestamp: $timestamp)';
  }
}

/// Simple bus for boutique data changes
/// This allows the boutiques package to notify other parts of the app
/// when boutique data has been modified
class BoutiqueBus {
  static final BoutiqueBus _instance = BoutiqueBus._internal();
  factory BoutiqueBus() => _instance;
  BoutiqueBus._internal();

  final List<void Function(BoutiqueEvent)> _listeners = [];

  /// Subscribe to boutique events
  void listen(void Function(BoutiqueEvent) listener) {
    _listeners.add(listener);
  }

  /// Unsubscribe from boutique events
  void unlisten(void Function(BoutiqueEvent) listener) {
    _listeners.remove(listener);
  }

  /// Emit a boutique event to all listeners
  void emit(BoutiqueEvent event) {
    for (final listener in _listeners) {
      try {
        listener(event);
      } catch (e) {
        debugPrint('Error in boutique event listener: $e');
      }
    }
  }

  /// Clear all listeners
  void clear() {
    _listeners.clear();
  }

  /// Get the number of active listeners
  int get listenerCount => _listeners.length;
}
