import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import '../../boutique.dart';
import '../l10n/boutique_ui_strings.dart';
import '../providers/boutique_provider.dart';
import '../boutique_form_extensions.dart';
import 'boutique_form_widget.dart';

/// Wrap builder to report errors
class FutureBuilder2<T> extends FutureBuilder<T> {
  final String callerName;

  FutureBuilder2({
    super.key,
    super.future,
    super.initialData,
    required AsyncWidgetBuilder<T> builder,
    this.callerName = 'Unknown',
  }) : super(builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
          if (snapshot.hasError) {
            FlutterError.reportError(FlutterErrorDetails(
                context: ErrorDescription('from $callerName'),
                exception: snapshot.error!,
                stack: snapshot.stackTrace));
          }
          return builder(context, snapshot);
        });
}

/// Boutique list widget that displays boutiques grouped by chains with CRUD operations
class BoutiqueListWidget extends StatelessWidget {
  final bool showChainHeaders;
  final bool allowSelection;
  final bool autoLoad; // whether to auto-load chains on first build
  final UserPermissions?
      userPermissions; // NEW: User permissions to determine CRUD capabilities
  final BoutiqueFormExtensionsFactory? formExtensionsFactory;
  final BoutiqueDetailExtrasFactory? detailExtrasFactory;
  final Function(BoutiqueMongo)? onBoutiqueSelected;
  final Function(Chain)? onChainSelected;
  final Function(BoutiqueMongo)? onBoutiqueEdit;
  final Function(Chain)? onChainEdit;
  final Function(BoutiqueMongo)? onBoutiqueDelete;
  final Function(Chain)? onChainDelete;
  final Function(String?)? onCreateBoutique; // Pass chainId
  final VoidCallback? onCreateChain;

  const BoutiqueListWidget({
    super.key,
    this.showChainHeaders = true,
    this.allowSelection = true,
    this.autoLoad = true,
    this.userPermissions, // NEW: Optional user permissions
    this.formExtensionsFactory,
    this.detailExtrasFactory,
    this.onBoutiqueSelected,
    this.onChainSelected,
    this.onBoutiqueEdit,
    this.onChainEdit,
    this.onBoutiqueDelete,
    this.onChainDelete,
    this.onCreateBoutique,
    this.onCreateChain,
  });

  /// Check if user can create boutiques
  bool get canCreateBoutique {
    if (onCreateBoutique != null) return true;
    if (userPermissions == null) return false;
    return userPermissions!.hasBoutiqueRights() &&
        userPermissions!.boutiqueRights.rights.contains(Right.create);
  }

  /// Check if user can edit boutiques
  bool get canEditBoutique {
    if (onBoutiqueEdit != null) return true;
    if (userPermissions == null) return false;
    return userPermissions!.hasBoutiqueRights() &&
        userPermissions!.boutiqueRights.rights.contains(Right.update);
  }

  /// Check if user can delete boutiques
  bool get canDeleteBoutique {
    if (onBoutiqueDelete != null) return true;
    if (userPermissions == null) return false;
    return userPermissions!.hasBoutiqueRights() &&
        userPermissions!.boutiqueRights.rights.contains(Right.delete);
  }

  /// Check if user can create chains
  bool get canCreateChain {
    if (onCreateChain != null) return true;
    if (userPermissions == null) return false;
    return userPermissions!.hasChainRights() &&
        userPermissions!.chainRights.rights.contains(Right.create);
  }

  /// Check if user can edit chains
  bool get canEditChain {
    if (onChainEdit != null) return true;
    if (userPermissions == null) return false;
    return userPermissions!.hasChainRights() &&
        userPermissions!.chainRights.rights.contains(Right.update);
  }

  /// Check if user can delete chains
  bool get canDeleteChain {
    if (onChainDelete != null) return true;
    if (userPermissions == null) return false;
    return userPermissions!.hasChainRights() &&
        userPermissions!.chainRights.rights.contains(Right.delete);
  }

  /// Check if any CRUD operations are enabled
  bool get enableCrud {
    return canCreateBoutique ||
        canEditBoutique ||
        canDeleteBoutique ||
        canCreateChain ||
        canEditChain ||
        canDeleteChain;
  }

  @override
  Widget build(BuildContext context) {
    return _BoutiqueListContent(
      showChainHeaders: showChainHeaders,
      allowSelection: allowSelection,
      autoLoad: autoLoad,
      // Pass specific permission flags instead of generic enableCrud
      canCreateBoutique: canCreateBoutique,
      canEditBoutique: canEditBoutique,
      canDeleteBoutique: canDeleteBoutique,
      canCreateChain: canCreateChain,
      canEditChain: canEditChain,
      canDeleteChain: canDeleteChain,
      formExtensionsFactory: formExtensionsFactory,
      detailExtrasFactory: detailExtrasFactory,
      onBoutiqueSelected: onBoutiqueSelected,
      onChainSelected: onChainSelected,
      onBoutiqueEdit: onBoutiqueEdit,
      onChainEdit: onChainEdit,
      onBoutiqueDelete: onBoutiqueDelete,
      onChainDelete: onChainDelete,
      onCreateBoutique: onCreateBoutique,
      onCreateChain: onCreateChain,
    );
  }
}

/// Internal stateful widget that handles the actual content
class _BoutiqueListContent extends StatefulWidget {
  final bool showChainHeaders;
  final bool allowSelection;
  final bool autoLoad;
  // Specific permission flags instead of generic enableCrud
  final bool canCreateBoutique;
  final bool canEditBoutique;
  final bool canDeleteBoutique;
  final bool canCreateChain;
  final bool canEditChain;
  final bool canDeleteChain;
  final BoutiqueFormExtensionsFactory? formExtensionsFactory;
  final BoutiqueDetailExtrasFactory? detailExtrasFactory;
  final Function(BoutiqueMongo)? onBoutiqueSelected;
  final Function(Chain)? onChainSelected;
  final Function(BoutiqueMongo)? onBoutiqueEdit;
  final Function(Chain)? onChainEdit;
  final Function(BoutiqueMongo)? onBoutiqueDelete;
  final Function(Chain)? onChainDelete;
  final Function(String?)? onCreateBoutique;
  final VoidCallback? onCreateChain;

  const _BoutiqueListContent({
    required this.showChainHeaders,
    required this.allowSelection,
    required this.autoLoad,
    required this.canCreateBoutique,
    required this.canEditBoutique,
    required this.canDeleteBoutique,
    required this.canCreateChain,
    required this.canEditChain,
    required this.canDeleteChain,
    this.formExtensionsFactory,
    this.detailExtrasFactory,
    this.onBoutiqueSelected,
    this.onChainSelected,
    this.onBoutiqueEdit,
    this.onChainEdit,
    this.onBoutiqueDelete,
    this.onChainDelete,
    this.onCreateBoutique,
    this.onCreateChain,
  });

  /// Check if any CRUD operations are enabled
  bool get enableCrud {
    return canCreateBoutique ||
        canEditBoutique ||
        canDeleteBoutique ||
        canCreateChain ||
        canEditChain ||
        canDeleteChain;
  }

  @override
  State<_BoutiqueListContent> createState() => _BoutiqueListContentState();
}

class _BoutiqueListContentState extends State<_BoutiqueListContent> {
  String _searchQuery = '';
  DateTime? _lastErrorSnackAt;

  @override
  void initState() {
    super.initState();
    // Auto-load only when explicitly enabled
    if (widget.autoLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeDataLoading();
      });
    }
  }

  void _initializeDataLoading() {
    if (!mounted) return;
    final provider = context.read<BoutiqueProvider>();
    if (provider.chains.isEmpty && !provider.isLoading) {
      provider.loadChains();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BoutiqueProvider>(
      builder: (context, provider, child) {
        // Show loading during initial load
        if (provider.isLoading && provider.chains.isEmpty) {
          // Use determinate indicator to avoid endless animation during tests
          return const Center(child: CircularProgressIndicator(value: 0.0));
        }

        if (provider.error != null && provider.chains.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                SelectableText(BoutiqueUiStrings.errorPrefix('${provider.error}')),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadChains(),
                  child: const Text(BoutiqueUiStrings.retry),
                ),
              ],
            ),
          );
        }

        if (provider.chains.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const SelectableText(BoutiqueUiStrings.noChainsOrBoutiques),
                if (widget.canCreateChain && widget.onCreateChain != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: widget.onCreateChain,
                    icon: const Icon(Icons.add),
                    label: const Text(BoutiqueUiStrings.createChain),
                  ),
                ],
              ],
            ),
          );
        }

        return Stack(
          children: [
            Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: _buildBoutiqueList(provider),
                ),
              ],
            ),
            // Floating Action Buttons for CRUD operations
            if (widget.enableCrud) _buildFABs(provider),
            // Non-blocking error banner when data exists
            if (provider.error != null && provider.chains.isNotEmpty)
              if (!(_lastErrorSnackAt != null &&
                  DateTime.now().difference(_lastErrorSnackAt!) <
                      const Duration(seconds: 2)))
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[300]),
                          const SizedBox(width: 8),
                          Expanded(
                              child: SelectableText(BoutiqueUiStrings
                                  .errorPrefix('${provider.error}'))),
                          TextButton(
                            onPressed: () => provider.loadChains(),
                            child: const Text(BoutiqueUiStrings.retry),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }

  Widget _buildFABs(BoutiqueProvider provider) {
    // Check permissions and availability
    final hasChains = provider.chains.isNotEmpty;
    final canCreateChainWithCallback =
        widget.canCreateChain && widget.onCreateChain != null;
    final canCreateBoutiqueWithCallback = widget.canCreateBoutique &&
        widget.onCreateBoutique != null &&
        hasChains;

    if (!canCreateChainWithCallback && !canCreateBoutiqueWithCallback) {
      return const SizedBox.shrink();
    }

    // Get safe area padding for mobile-friendly positioning
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final rightPadding = mediaQuery.padding.right;

    // Use safe area padding + additional margin for mobile-friendly positioning
    final bottomPosition = bottomPadding + 16;
    final rightPosition = rightPadding + 16;

    // If we can only do one action, show simple FAB
    if (canCreateChainWithCallback && !canCreateBoutiqueWithCallback) {
      return Positioned(
        bottom: bottomPosition,
        right: rightPosition,
        child: FloatingActionButton(
          onPressed: widget.onCreateChain,
          tooltip: BoutiqueUiStrings.tooltipCreateChain,
          child: const Icon(Icons.account_tree),
        ),
      );
    }

    if (canCreateBoutiqueWithCallback && !canCreateChainWithCallback) {
      return Positioned(
        bottom: bottomPosition,
        right: rightPosition,
        child: FloatingActionButton(
          onPressed: () => _showBoutiqueCreationDialog(provider),
          tooltip: BoutiqueUiStrings.tooltipCreateBoutique,
          child: const Icon(Icons.store),
        ),
      );
    }

    // If we can do both, show expandable FAB
    return Positioned(
      bottom: bottomPosition,
      right: rightPosition,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canCreateChainWithCallback)
            FloatingActionButton.small(
              onPressed: widget.onCreateChain,
              tooltip: BoutiqueUiStrings.tooltipCreateChain,
              heroTag: 'create_chain',
              child: const Icon(Icons.account_tree),
            ),
          const SizedBox(height: 8),
          if (canCreateBoutiqueWithCallback) ...[
            FloatingActionButton(
              onPressed: () => _showBoutiqueCreationDialog(provider),
              tooltip: BoutiqueUiStrings.tooltipCreateBoutique,
              heroTag: 'create_boutique',
              child: const Icon(Icons.store),
            ),
          ],
        ],
      ),
    );
  }

  void _showBoutiqueCreationDialog(BoutiqueProvider provider) {
    if (provider.chains.length == 1) {
      // If only one chain, create boutique directly
      widget.onCreateBoutique?.call(provider.chains.first.chainId);
    } else {
      // Show chain selection dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(BoutiqueUiStrings.selectChainTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: provider.chains.map((chain) {
              return ListTile(
                leading: const Icon(Icons.account_tree),
                title: Text(chain.name),
                subtitle: Text(
                    BoutiqueUiStrings.chainBoutiqueCount(chain.boutiqueCount)),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onCreateBoutique?.call(chain.chainId);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(BoutiqueUiStrings.cancel),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: const InputDecoration(
          hintText: BoutiqueUiStrings.searchHint,
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        // Mobile-friendly improvements
        textInputAction: TextInputAction.search,
        keyboardType: TextInputType.text,
      ),
    );
  }

  Widget _buildBoutiqueList(BoutiqueProvider provider) {
    // Filter chains locally to avoid relying on provider mocks for search
    final List<Chain> chains;
    if (_searchQuery.isEmpty) {
      chains = provider.chains;
    } else {
      final lowercaseQuery = _searchQuery.toLowerCase();
      chains = provider.chains.where((chain) {
        final matchesChainName =
            chain.name.toLowerCase().contains(lowercaseQuery);
        final matchesAnyBoutique = chain.boutiques.any((b) =>
            b.displayName.toLowerCase().contains(lowercaseQuery) ||
            b.formattedAddress.toLowerCase().contains(lowercaseQuery));
        return matchesChainName || matchesAnyBoutique;
      }).toList();
    }

    if (chains.isEmpty) {
      return const Center(
        child: Text(BoutiqueUiStrings.noResults),
      );
    }

    return ListView.builder(
      // Mobile-friendly padding
      padding: const EdgeInsets.only(bottom: 80), // Space for FABs
      itemCount: chains.length,
      itemBuilder: (context, index) {
        final chain = chains[index];
        final boutiques = _searchQuery.isEmpty
            ? chain.boutiques
            : chain.boutiques
                .where((b) =>
                    b.displayName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    b.formattedAddress
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                .toList();

        if (boutiques.isEmpty && _searchQuery.isNotEmpty) {
          return const SizedBox.shrink();
        }

        return _buildChainSection(chain, boutiques);
      },
    );
  }

  Widget _buildChainSection(Chain chain, List<BoutiqueMongo> boutiques) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showChainHeaders) _buildChainHeader(chain),
          ...boutiques.map((boutique) => _buildBoutiqueItem(boutique, chain)),
        ],
      ),
    );
  }

  Widget _buildChainHeader(Chain chain) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_tree,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: widget.allowSelection
                  ? () => widget.onChainSelected?.call(chain)
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chain.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  Text(
                    chain.summary,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          if (kIsWeb ||
              (Platform.isAndroid == false && Platform.isIOS == false)) ...[
            if (chain.formattedCreatedAt.isNotEmpty)
              Chip(
                label: Text(chain.formattedCreatedAt),
                backgroundColor: Colors.grey[200],
              ),
          ],
          // CRUD action buttons for chains (based on specific permissions)
          if (widget.canCreateBoutique ||
              widget.canEditChain ||
              widget.canDeleteChain) ...[
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add boutique to chain button (requires boutique create permission)
                if (widget.canCreateBoutique)
                  IconButton(
                    icon: Icon(Icons.add_business,
                        color: Colors.green[600], size: 20),
                    onPressed: widget.onCreateBoutique != null
                        ? () => widget.onCreateBoutique!(chain.chainId)
                        : null,
                    tooltip: BoutiqueUiStrings.addBoutiqueToChain(chain.name),
                  ),
                // Edit chain button (requires chain update permission)
                if (widget.canEditChain)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showEditChainDialog(chain),
                    tooltip: BoutiqueUiStrings.editChain,
                  ),
                // Delete chain button (requires chain delete permission)
                if (widget.canDeleteChain)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[600], size: 20),
                    onPressed: () => _showDeleteChainConfirmation(chain),
                    tooltip: BoutiqueUiStrings.deleteChain,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBoutiqueItem(BoutiqueMongo boutique, Chain chain) {
    final isSelected = widget.allowSelection &&
        context.watch<BoutiqueProvider>().selectedBoutique?.boutiqueId ==
            boutique.boutiqueId;

    return InkWell(
      onTap: widget.allowSelection
          ? () {
              context.read<BoutiqueProvider>().selectBoutique(boutique);
              widget.onBoutiqueSelected?.call(boutique);
            }
          : null,
      // Mobile-friendly touch feedback
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : null,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[300]!,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Boutique logo or icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: (boutique.logo.isNotEmpty &&
                      boutique.logoExtension.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        Uint8List.fromList(boutique.logo),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.store),
                      ),
                    )
                  : const Icon(Icons.store),
            ),
            const SizedBox(width: 16),
            // Boutique details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    boutique.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (boutique.formattedAddress.isNotEmpty)
                    Text(
                      boutique.formattedAddress,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (boutique.formattedPhone.isNotEmpty)
                    Text(
                      boutique.formattedPhone,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 4),
                  // Display status text for tests
                  Text(boutique.statusText),
                  const SizedBox(height: 4),
                  if (boutique.currencyCode.isNotEmpty)
                    Chip(
                      avatar: const Icon(
                        Icons.monetization_on_outlined,
                        size: 18,
                      ),
                      label: Text(boutique.currencyCode),
                      backgroundColor: Colors.green[50],
                    ),
                  if (boutique.currencyCode.isNotEmpty &&
                      boutique.devices.isNotEmpty)
                    const SizedBox(height: 4),
                  if (boutique.devices.isNotEmpty)
                    Chip(
                      label: SizedBox(
                        height: 20,
                        child: Wrap(
                          children: [
                            Icon(Icons.important_devices),
                            const SizedBox(width: 4),
                            Text('x${boutique.devices.length}'),
                          ],
                        ),
                      ),
                      backgroundColor: Colors.blue[100],
                    ),
                ],
              ),
            ),
            // Action buttons
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // CRUD buttons (based on specific permissions)
                    if (widget.canEditBoutique || widget.canDeleteBoutique) ...[
                      // Edit boutique button (requires boutique update permission)
                      if (widget.canEditBoutique)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showEditBoutiqueDialog(boutique),
                          tooltip: BoutiqueUiStrings.editBoutique,
                          // Mobile-friendly touch target
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                        ),
                      // Delete boutique button (requires boutique delete permission)
                      if (widget.canDeleteBoutique)
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: Colors.red[600], size: 20),
                          onPressed: () =>
                              _showDeleteBoutiqueConfirmation(boutique),
                          tooltip: BoutiqueUiStrings.deleteBoutique,
                          // Mobile-friendly touch target
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteChainConfirmation(Chain chain) {
    // Check if chain has boutiques - important condition as you specified
    final hasBoutiques = chain.boutiques.isNotEmpty;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(BoutiqueUiStrings.deleteChainTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(BoutiqueUiStrings.deleteChainConfirm(chain.name)),
            const SizedBox(height: 12),
            if (hasBoutiques) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning,
                            color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          BoutiqueUiStrings.warning,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      BoutiqueUiStrings.deleteChainWithBoutiquesWarning(
                          chain.boutiques.length),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            const Text(
              BoutiqueUiStrings.actionCannotUndo,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(BoutiqueUiStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteChain(chain);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(hasBoutiques
                ? BoutiqueUiStrings.deleteChainAndBoutiques
                : BoutiqueUiStrings.deleteChainTitle),
          ),
        ],
      ),
    );
  }

  void _showDeleteBoutiqueConfirmation(BoutiqueMongo boutique) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(BoutiqueUiStrings.deleteBoutiqueTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(BoutiqueUiStrings.deleteBoutiqueConfirm(
                boutique.displayName)),
            const SizedBox(height: 12),
            const Text(BoutiqueUiStrings.actionCannotUndo),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(BoutiqueUiStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteBoutique(boutique);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(BoutiqueUiStrings.deleteAction),
          ),
        ],
      ),
    );
  }

  /// Shows the edit dialog for a chain
  void _showEditChainDialog(Chain chain) {
    showDialog(
      context: context,
      builder: (context) => BoutiqueFormWidget(
        chain: chain,
        formExtensions: widget.formExtensionsFactory?.call(
          editingChain: chain,
        ),
        onSaved: () {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(BoutiqueUiStrings.chainUpdatedSuccess(chain.name)),
              backgroundColor: Colors.green,
            ),
          );
          // Call the optional callback if provided
          widget.onChainEdit?.call(chain);
        },
      ),
    );
  }

  /// Shows the edit dialog for a boutique
  void _showEditBoutiqueDialog(BoutiqueMongo boutique) {
    // Capture ScaffoldMessenger reference before showing dialog
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => BoutiqueFormWidget(
        boutique: boutique,
        formExtensions: widget.formExtensionsFactory?.call(
          editingBoutique: boutique,
        ),
        onSaved: () {
          // Show success message using captured reference
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(BoutiqueUiStrings.boutiqueUpdatedSuccess(
                  boutique.displayName)),
              backgroundColor: Colors.green,
            ),
          );
          // Don't call the callback to avoid any state refresh issues
        },
      ),
    );
  }

  /// Handles the actual deletion of a chain
  Future<void> _deleteChain(Chain chain) async {
    final provider = context.read<BoutiqueProvider>();

    try {
      final success = await provider.deleteChain(chain.chainId);

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(BoutiqueUiStrings.chainDeletedSuccess(chain.name)),
            backgroundColor: Colors.green,
          ),
        );

        // Call the optional callback if provided
        widget.onChainDelete?.call(chain);
      } else if (mounted) {
        // Show error message
        final errorMessage =
            provider.error ?? BoutiqueUiStrings.failedDeleteChainFallback;
        setState(() {
          _lastErrorSnackAt = DateTime.now();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SelectableText(BoutiqueUiStrings.errorPrefix(errorMessage)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(BoutiqueUiStrings.unexpectedError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handles the actual deletion of a boutique
  Future<void> _deleteBoutique(BoutiqueMongo boutique) async {
    final provider = context.read<BoutiqueProvider>();

    try {
      final success =
          await provider.deleteBoutique(boutique.chainId, boutique.boutiqueId);

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(BoutiqueUiStrings.boutiqueDeletedSuccess(
                    boutique.displayName)),
            backgroundColor: Colors.green,
          ),
        );

        // Note: onBoutiqueDelete callback removed to prevent double confirmation dialog
        // The deletion has already been confirmed and executed at this point
      } else if (mounted) {
        // Show error message
        final errorMessage =
            provider.error ?? BoutiqueUiStrings.failedDeleteBoutiqueFallback;
        setState(() {
          _lastErrorSnackAt = DateTime.now();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SelectableText(BoutiqueUiStrings.errorPrefix(errorMessage)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(BoutiqueUiStrings.unexpectedError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
