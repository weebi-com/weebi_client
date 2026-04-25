import 'package:boutiques_weebi/boutiques_weebi.dart';
import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart' show UserPermissions, BoutiqueMongo, Chain;

/// Route factory for boutique management
/// Provides clean route builders that client apps can integrate
class BoutiqueRoutes {
  /// Standard Material App routes (English defaults - override for localization)
  /// Optional: Pass userPermissions to enable CRUD operations and callbacks
  static Map<String, WidgetBuilder> getMaterialRoutes({
    UserPermissions? userPermissions,
  }) => {
        '/boutiques': (context) => buildBoutiqueListWithCustomScaffold(
          appBar:
              AppBar(title: const Text(BoutiqueUiStrings.appBarBoutiquesChains)),
          drawer: null,
          endDrawer: null,
          userPermissions: userPermissions,
        ),
      };

  /// Provider-based routes that use callback to get UserPermissions lazily
  /// Use this when UserPermissions are only available after app initialization
  /// 
  /// Usage:
  /// ```dart
  /// routes: {
  ///   ...BoutiqueRoutes.getProviderRoutes(
  ///     getUserPermissions: (context) => context.read<Gatekeeper>().userPermissions,
  ///   ),
  /// }
  /// ```
  static Map<String, WidgetBuilder> getProviderRoutes({
    required UserPermissions? Function(BuildContext) getUserPermissions,
    void Function(BoutiqueEvent)? onBoutiqueChanged,
  }) => {
        '/boutiques': (context) => _buildAuthenticatedBoutiqueList(context, getUserPermissions, onBoutiqueChanged),
      };


  /// Route builders for custom integration
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/boutiques':
        return MaterialPageRoute(
          builder: (context) => buildBoutiqueListWithCustomScaffold(
            appBar:
              AppBar(title: const Text(BoutiqueUiStrings.appBarBoutiquesChains)),
            drawer: null,
            endDrawer: null,
          ),
          settings: settings,
        );
      case '/boutiques/detail':
        final args = settings.arguments as Map<String, dynamic>?;
        final boutique = args?['boutique'] as BoutiqueMongo?;
        if (boutique == null) return null;
        return MaterialPageRoute(
          builder: (context) => BoutiqueWidget(boutique: boutique),
          settings: settings,
        );
      case '/chains/detail':
        final args = settings.arguments as Map<String, dynamic>?;
        final chain = args?['chain'] as Chain?;
        if (chain == null) return null;
        return MaterialPageRoute(
          builder: (context) => BoutiqueWidget(chain: chain),
          settings: settings,
        );
      default:
        return null;
    }
  }

  /// Widget builders (can be used standalone)
  static Widget buildBoutiqueList(BuildContext context) => const BoutiqueListWidget();
  
  static Widget buildBoutiqueDetail(
    BuildContext context, 
    BoutiqueMongo boutique
  ) => BoutiqueWidget(boutique: boutique);

  static Widget buildChainDetail(
    BuildContext context, 
    Chain chain
  ) => BoutiqueWidget(chain: chain);

  // New detail view builders (for full-screen detail views)
  static Widget buildBoutiqueDetailView(
    BuildContext context, 
    BoutiqueMongo boutique, {
    VoidCallback? onEdit, 
    VoidCallback? onDelete
  }) => BoutiqueDetailView(boutique: boutique, onEdit: onEdit, onDelete: onDelete);
  
  static Widget buildChainDetailView(
    BuildContext context, 
    Chain chain, {
    VoidCallback? onEdit, 
    VoidCallback? onDelete
  }) => BoutiqueDetailView(chain: chain, onEdit: onEdit, onDelete: onDelete);

  // Form widget builders (for edit dialogs)
  static Widget buildBoutiqueForm(
    BuildContext context, {
    BoutiqueMongo? boutique, 
    VoidCallback? onSaved
  }) => BoutiqueFormWidget(boutique: boutique, onSaved: onSaved);
  
  static Widget buildChainForm(
    BuildContext context, {
    Chain? chain, 
    VoidCallback? onSaved
  }) => BoutiqueFormWidget(chain: chain, onSaved: onSaved);

  /// Custom scaffold builders where client provides the scaffold structure
  static Widget buildBoutiqueListWithCustomScaffold({
    required PreferredSizeWidget? appBar,
    required Widget? drawer,
    required Widget? endDrawer,
    Widget? floatingActionButton,
    UserPermissions? userPermissions, // NEW: Optional permissions for CRUD
    void Function(BoutiqueEvent)? onBoutiqueChanged, // NEW: Callback for boutique changes
  }) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      body: Builder(
        builder: (context) => BoutiqueListWithBus(
          userPermissions: userPermissions, // Pass permissions for CRUD
          allowSelection: true,
          // Default demo callbacks when permissions are provided
          onBoutiqueSelected: userPermissions != null 
              ? (boutique) => navigateToBoutiqueDetailView(context, boutique)
              : null,
          onChainSelected: userPermissions != null
              ? (chain) => navigateToChainDetailView(context, chain)
              : null,
          onBoutiqueEdit: userPermissions != null
              ? (boutique) => showBoutiqueEditDialog(context, boutique: boutique)
              : null,
          onChainEdit: userPermissions != null
              ? (chain) => showChainEditDialog(context, chain: chain)
              : null,
          onCreateBoutique: userPermissions != null
              ? (chainId) {
                  if (chainId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BoutiqueCreateView.createBoutique(chainId: chainId),
                      ),
                    );
                  }
                }
              : null,
          onCreateChain: userPermissions != null
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BoutiqueCreateView.createChain(),
                  ),
                )
              : null,
          // NEW: Handle boutique changes via bus (from client app)
          onBoutiqueChanged: onBoutiqueChanged,
          // Delete operations would need provider access, so keeping them simple for now
          onBoutiqueDelete: userPermissions != null
              ? (boutique) => _showSimpleDeleteDialog(context, 'boutique', boutique.displayName)
              : null,
          onChainDelete: userPermissions != null
              ? (chain) => _showSimpleDeleteDialog(context, 'chain', chain.name)
              : null,
        ),
      ),
    );
  }


  static Widget buildBoutiqueDetailWithCustomScaffold({
    required PreferredSizeWidget? appBar,
    required Widget? drawer,
    required Widget? endDrawer,
    required BoutiqueMongo boutique,
  }) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      body: BoutiqueDetailWidget(boutique: boutique),
    );
  }

  static Widget buildChainDetailWithCustomScaffold({
    required PreferredSizeWidget? appBar,
    required Widget? drawer,
    required Widget? endDrawer,
    required Chain chain,
  }) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      body: ChainDetailWidget(chain: chain),
    );
  }

  /// Navigation helpers
  static void navigateToBoutiqueList(BuildContext context) {
    Navigator.pushNamed(context, '/boutiques');
  }

  static void navigateToBoutiqueDetail(
    BuildContext context,
    BoutiqueMongo boutique,
  ) {
    Navigator.pushNamed(
      context,
      '/boutiques/detail',
      arguments: {'boutique': boutique},
    );
  }

  static void navigateToChainDetail(
    BuildContext context,
    Chain chain,
  ) {
    Navigator.pushNamed(
      context,
      '/chains/detail',
      arguments: {'chain': chain},
    );
  }

  // Navigation helpers for new views
  static void navigateToBoutiqueDetailView(
    BuildContext context,
    BoutiqueMongo boutique, {
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => buildBoutiqueDetailView(context, boutique, onEdit: onEdit, onDelete: onDelete),
      ),
    );
  }

  static void navigateToChainDetailView(
    BuildContext context,
    Chain chain, {
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => buildChainDetailView(context, chain, onEdit: onEdit, onDelete: onDelete),
      ),
    );
  }

  // Show edit forms as dialogs
  static Future<void> showBoutiqueEditDialog(
    BuildContext context, {
    BoutiqueMongo? boutique,
    VoidCallback? onSaved,
  }) {
    return showDialog(
      context: context,
      builder: (context) => buildBoutiqueForm(context, boutique: boutique, onSaved: onSaved),
    );
  }

  static Future<void> showChainEditDialog(
    BuildContext context, {
    Chain? chain,
    VoidCallback? onSaved,
  }) {
    return showDialog(
      context: context,
      builder: (context) => buildChainForm(context, chain: chain, onSaved: onSaved),
    );
  }

  /// Private helper for authenticated boutique list
  static Widget _buildAuthenticatedBoutiqueList(
    BuildContext context, 
    UserPermissions? Function(BuildContext) getUserPermissions,
    void Function(BoutiqueEvent)? onBoutiqueChanged,
  ) {
    final userPermissions = getUserPermissions(context);
    return buildBoutiqueListWithCustomScaffold(
      appBar:
          AppBar(title: const Text(BoutiqueUiStrings.appBarBoutiquesChains)),
      drawer: null,
      endDrawer: null,
      userPermissions: userPermissions,
      onBoutiqueChanged: onBoutiqueChanged,
    );
  }

  /// Standalone widget that uses callback to get UserPermissions
  /// Use this if you want to embed the boutique list directly in your widget tree
  /// 
  /// Usage:
  /// ```dart
  /// body: BoutiqueRoutes.buildProviderBoutiqueList(
  ///   getUserPermissions: (context) => context.read<Gatekeeper>().userPermissions,
  /// ),
  /// ```
  static Widget buildProviderBoutiqueList({
    required UserPermissions? Function(BuildContext) getUserPermissions,
  }) {
    return Builder(
      builder: (context) {
        final userPermissions = getUserPermissions(context);
        return BoutiqueListWidget(
          userPermissions: userPermissions,
          allowSelection: true,
          // Default callbacks when permissions are provided
          onBoutiqueSelected: userPermissions != null 
              ? (boutique) => navigateToBoutiqueDetailView(context, boutique)
              : null,
          onChainSelected: userPermissions != null
              ? (chain) => navigateToChainDetailView(context, chain)
              : null,
          onBoutiqueEdit: userPermissions != null
              ? (boutique) => showBoutiqueEditDialog(context, boutique: boutique)
              : null,
          onChainEdit: userPermissions != null
              ? (chain) => showChainEditDialog(context, chain: chain)
              : null,
          onCreateBoutique: userPermissions != null
              ? (chainId) {
                  if (chainId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BoutiqueCreateView.createBoutique(chainId: chainId),
                      ),
                    );
                  }
                }
              : null,
          onCreateChain: userPermissions != null
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BoutiqueCreateView.createChain(),
                  ),
                )
              : null,
          onBoutiqueDelete: userPermissions != null
              ? (boutique) => _showSimpleDeleteDialog(context, 'boutique', boutique.displayName)
              : null,
          onChainDelete: userPermissions != null
              ? (chain) => _showSimpleDeleteDialog(context, 'chain', chain.name)
              : null,
        );
      },
    );
  }

  /// Simple delete dialog helper for basic routes
  static void _showSimpleDeleteDialog(BuildContext context, String type, String name) {
    final isChain = type == 'chain';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChain
            ? BoutiqueUiStrings.deleteChainTitle
            : BoutiqueUiStrings.deleteBoutiqueTitle),
        content: Text(BoutiqueUiStrings.deleteConfirmContent(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(BoutiqueUiStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isChain
                      ? BoutiqueUiStrings.demoDeletedChain(name)
                      : BoutiqueUiStrings.demoDeletedBoutique(name)),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(BoutiqueUiStrings.deleteAction),
          ),
        ],
      ),
    );
  }
} 