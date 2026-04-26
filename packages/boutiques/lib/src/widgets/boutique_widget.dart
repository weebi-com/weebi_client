import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import '../../boutique.dart';
import '../../dynamic_body.dart';

/// Widget for displaying boutique or chain details using dynamic body
class BoutiqueWidget extends StatelessWidget {
  final BoutiqueMongo? boutique;
  final Chain? chain;
  final bool isEditable;
  final VoidCallback? onEdit;

  const BoutiqueWidget({
    super.key,
    this.boutique,
    this.chain,
    this.isEditable = false,
    this.onEdit,
  }) : assert(boutique != null || chain != null, 'Either boutique or chain must be provided');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          if (isEditable && onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Edit ${_getType()}',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  String _getTitle() {
    if (boutique != null) {
      return boutique!.displayName;
    }
    if (chain != null) {
      return chain!.name;
    }
    return 'Details';
  }

  String _getType() {
    return boutique != null ? 'Boutique' : 'Chain';
  }

  Widget _buildBody() {
    if (boutique != null) {
      return BoutiqueDynamicBody<BoutiqueMongo>(pbObject: boutique!);
    }
    if (chain != null) {
      return BoutiqueDynamicBody<Chain>(pbObject: chain!);
    }
    return const Center(
      child: Text('No data to display'),
    );
  }
}

/// Convenience methods for creating boutique widgets
class BoutiqueWidgets {
  /// Create a boutique detail widget
  static Widget boutique({
    required BoutiqueMongo boutique,
    bool isEditable = false,
    VoidCallback? onEdit,
  }) {
    return BoutiqueWidget(
      boutique: boutique,
      isEditable: isEditable,
      onEdit: onEdit,
    );
  }

  /// Create a chain detail widget
  static Widget chain({
    required Chain chain,
    bool isEditable = false,
    VoidCallback? onEdit,
  }) {
    return BoutiqueWidget(
      chain: chain,
      isEditable: isEditable,
      onEdit: onEdit,
    );
  }

  /// Create a boutique detail widget with custom scaffold
  static Widget boutiqueWithCustomScaffold({
    required BoutiqueMongo boutique,
    bool isEditable = false,
    VoidCallback? onEdit,
    PreferredSizeWidget? appBar,
    Widget? drawer,
    Widget? endDrawer,
    Widget? floatingActionButton,
  }) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      body: BoutiqueDynamicBody<BoutiqueMongo>(pbObject: boutique),
    );
  }

  /// Create a chain detail widget with custom scaffold
  static Widget chainWithCustomScaffold({
    required Chain chain,
    bool isEditable = false,
    VoidCallback? onEdit,
    PreferredSizeWidget? appBar,
    Widget? drawer,
    Widget? endDrawer,
    Widget? floatingActionButton,
  }) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      body: BoutiqueDynamicBody<Chain>(pbObject: chain),
    );
  }
}
