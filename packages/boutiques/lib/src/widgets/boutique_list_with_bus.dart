import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:boutiques_weebi/boutiques_weebi.dart';

/// Wrapper for BoutiqueListWidget that automatically handles boutique bus notifications
/// This ensures the bus is only active when the boutiques view is open
class BoutiqueListWithBus extends StatefulWidget {
  final bool showChainHeaders;
  final bool allowSelection;
  final UserPermissions? userPermissions;
  final Function(BoutiqueMongo)? onBoutiqueSelected;
  final Function(Chain)? onChainSelected;
  final Function(BoutiqueMongo)? onBoutiqueEdit;
  final Function(Chain)? onChainEdit;
  final Function(BoutiqueMongo)? onBoutiqueDelete;
  final Function(Chain)? onChainDelete;
  final Function(String?)? onCreateBoutique;
  final VoidCallback? onCreateChain;
  final void Function(BoutiqueEvent)? onBoutiqueChanged;

  const BoutiqueListWithBus({
    super.key,
    this.showChainHeaders = true,
    this.allowSelection = true,
    this.userPermissions,
    this.onBoutiqueSelected,
    this.onChainSelected,
    this.onBoutiqueEdit,
    this.onChainEdit,
    this.onBoutiqueDelete,
    this.onChainDelete,
    this.onCreateBoutique,
    this.onCreateChain,
    this.onBoutiqueChanged,
  });

  @override
  State<BoutiqueListWithBus> createState() => _BoutiqueListWithBusState();
}

class _BoutiqueListWithBusState extends State<BoutiqueListWithBus> {
  late BoutiqueBus _bus;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _setupBus();
  }

  void _setupBus() {
    // Get the BoutiqueProvider from the widget tree
    final boutiqueProvider = context.read<BoutiqueProvider>();
    _bus = boutiqueProvider.bus;
    
    // Start listening to boutique changes
    _bus.listen(_handleBoutiqueEvent);
    _isListening = true;
  }

  void _handleBoutiqueEvent(BoutiqueEvent event) {
    // Call the custom handler if provided
    widget.onBoutiqueChanged?.call(event);
    
    // You can add your own logic here to refresh local data, etc.
    // For example:
    // - Refresh local boutique storage
    // - Update offline views
    // - Show notifications to user
  }

  @override
  void dispose() {
    // Stop listening when the view is closed
    if (_isListening) {
      _bus.unlisten(_handleBoutiqueEvent);
      _isListening = false;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BoutiqueListWidget(
      showChainHeaders: widget.showChainHeaders,
      allowSelection: widget.allowSelection,
      userPermissions: widget.userPermissions,
      onBoutiqueSelected: widget.onBoutiqueSelected,
      onChainSelected: widget.onChainSelected,
      onBoutiqueEdit: widget.onBoutiqueEdit,
      onChainEdit: widget.onChainEdit,
      onBoutiqueDelete: widget.onBoutiqueDelete,
      onChainDelete: widget.onChainDelete,
      onCreateBoutique: widget.onCreateBoutique,
      onCreateChain: widget.onCreateChain,
    );
  }
}
