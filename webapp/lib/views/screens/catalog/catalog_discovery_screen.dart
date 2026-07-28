import 'package:boutiques_weebi/boutiques_weebi.dart' show BoutiqueProvider;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:protos_weebi/protos_weebi_io.dart' show Chain;
import 'package:provider/provider.dart';
import 'package:web_admin/catalog/catalog.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/providers/server.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

/// Grocery-inspired accents for catalog discovery (not a theme override).
const Color _kCatalogGreen = Color(0xFF5EC401);
const Color _kCatalogOrange = Color(0xFFF37A20);
const Color _kPhotoWell = Color(0xFFF0F1F2);
const double _kCardRadius = 9;

class CatalogDiscoveryScreen extends StatelessWidget {
  const CatalogDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final articleClient =
            context.read<ArticleServiceClientProvider>().articleServiceClient;
        final notifier = CatalogDiscoveryNotifier(articleClient: articleClient);
        notifier.loadSeed();
        return notifier;
      },
      child: const _CatalogDiscoveryBody(),
    );
  }
}

class _CatalogDiscoveryBody extends StatefulWidget {
  const _CatalogDiscoveryBody();

  @override
  State<_CatalogDiscoveryBody> createState() => _CatalogDiscoveryBodyState();
}

class _CatalogDiscoveryBodyState extends State<_CatalogDiscoveryBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureChains());
  }

  Future<void> _ensureChains() async {
    final boutiqueProvider = context.read<BoutiqueProvider>();
    if (boutiqueProvider.chains.isEmpty) {
      await boutiqueProvider.loadChains();
    }
    if (!mounted) return;
    final chains = boutiqueProvider.chains;
    if (chains.isEmpty) return;

    final notifier = context.read<CatalogDiscoveryNotifier>();
    if (notifier.chainId != null && notifier.chainId!.isNotEmpty) return;

    final selected = boutiqueProvider.selectedChain ?? chains.first;
    await notifier.setChainId(selected.chainId);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= kScreenWidthLg;

    return PortalMasterLayout(
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              lang.menuCatalog,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lang.catalogDiscoverySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: kDefaultPadding),
            const _CatalogToolbar(),
            const SizedBox(height: kDefaultPadding * 0.75),
            Expanded(
              child: wide
                  ? const Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: _CatalogGridPane()),
                        SizedBox(width: kDefaultPadding),
                        SizedBox(width: 340, child: _SelectionBagPane()),
                      ],
                    )
                  : const Column(
                      children: [
                        Expanded(flex: 3, child: _CatalogGridPane()),
                        SizedBox(height: kDefaultPadding * 0.75),
                        Expanded(flex: 2, child: _SelectionBagPane()),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogToolbar extends StatelessWidget {
  const _CatalogToolbar();

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final notifier = context.watch<CatalogDiscoveryNotifier>();
    final boutiqueProvider = context.watch<BoutiqueProvider>();
    final chains = boutiqueProvider.chains;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 260,
          child: DropdownButtonFormField<String>(
            value: _dropdownValue(notifier.chainId, chains),
            decoration: InputDecoration(
              labelText: lang.catalogSelectChain,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            items: chains
                .map(
                  (c) => DropdownMenuItem(
                    value: c.chainId,
                    child: Text(
                      c.name.isNotEmpty ? c.name : c.chainId,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: chains.isEmpty
                ? null
                : (value) => notifier.setChainId(value),
          ),
        ),
        SizedBox(
          width: 280,
          child: TextField(
            decoration: InputDecoration(
              labelText: lang.search,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: notifier.setSearchQuery,
          ),
        ),
        if (notifier.isLoadingChainArticles)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }

  String? _dropdownValue(String? chainId, List<Chain> chains) {
    if (chainId == null || chainId.isEmpty) return null;
    final exists = chains.any((c) => c.chainId == chainId);
    return exists ? chainId : null;
  }
}

class _CatalogGridPane extends StatelessWidget {
  const _CatalogGridPane();

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final notifier = context.watch<CatalogDiscoveryNotifier>();

    if (notifier.isLoadingSeed) {
      return const Center(child: CircularProgressIndicator());
    }
    if (notifier.seedError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(notifier.seedError!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: notifier.loadSeed,
              child: Text(lang.refreshAction),
            ),
          ],
        ),
      );
    }

    final categories = notifier.categories;
    final items = notifier.filteredItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (categories.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(lang.catalogAllCategories),
                    selected: notifier.selectedCategory == null,
                    selectedColor: _kCatalogGreen.withValues(alpha: 0.25),
                    checkmarkColor: _kCatalogGreen,
                    onSelected: (_) => notifier.setSelectedCategory(null),
                  ),
                ),
                ...categories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: notifier.selectedCategory == category,
                      selectedColor: _kCatalogGreen.withValues(alpha: 0.25),
                      checkmarkColor: _kCatalogGreen,
                      onSelected: (_) =>
                          notifier.setSelectedCategory(category),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (categories.isNotEmpty) const SizedBox(height: 12),
        if (notifier.chainArticlesError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              notifier.chainArticlesError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Expanded(
          child: items.isEmpty
              ? Center(child: Text(lang.catalogNoProductsMatch))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth >= 1100
                        ? 4
                        : constraints.maxWidth >= 750
                            ? 3
                            : 2;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _ProductCard(
                          item: item,
                          picked: notifier.isPicked(item.seedId),
                          alreadyInCatalog:
                              notifier.isAlreadyInCatalog(item),
                          onPick: () => notifier.pick(item),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.item,
    required this.picked,
    required this.alreadyInCatalog,
    required this.onPick,
  });

  final CatalogSeedItem item;
  final bool picked;
  final bool alreadyInCatalog;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(_kCardRadius),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_kCardRadius),
                child: ColoredBox(
                  color: _kPhotoWell,
                  child: item.photoUrl.isEmpty
                      ? const Icon(Icons.image_not_supported_outlined)
                      : Image.network(
                          item.photoUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported_outlined,
                          ),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.barcodeEan,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.suggestedPrice.toStringAsFixed(0),
              style: theme.textTheme.titleMedium?.copyWith(
                color: _kCatalogOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (alreadyInCatalog)
              OutlinedButton(
                onPressed: null,
                child: Text(lang.catalogAlreadyInCatalog),
              )
            else
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: picked ? Colors.grey : _kCatalogGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: picked ? null : onPick,
                child: Text(
                  picked ? lang.catalogPicked : lang.catalogPick,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SelectionBagPane extends StatelessWidget {
  const _SelectionBagPane();

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final theme = Theme.of(context);
    final notifier = context.watch<CatalogDiscoveryNotifier>();
    final entries = notifier.selection;

    return Material(
      color: theme.colorScheme.surface,
      elevation: 1,
      borderRadius: BorderRadius.circular(_kCardRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    lang.catalogSelectionTitle(notifier.selectionCount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (entries.isNotEmpty)
                  TextButton(
                    onPressed: notifier.clearSelection,
                    child: Text(lang.catalogClearSelection),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        lang.catalogSelectionEmpty,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _SelectionRow(entry: entry);
                    },
                  ),
          ),
          if (notifier.submitError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                notifier.submitError!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          if (notifier.submitSuccess != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                notifier.submitSuccess!,
                style: const TextStyle(color: _kCatalogGreen),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _kCatalogGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: notifier.isSubmitting || entries.isEmpty
                  ? null
                  : () => notifier.materializeSelection(),
              child: notifier.isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(lang.catalogAddToCatalog),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({required this.entry});

  final CatalogSelectionEntry entry;

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final theme = Theme.of(context);
    final notifier = context.read<CatalogDiscoveryNotifier>();
    final item = entry.item;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(_kCardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ColoredBox(
                  color: _kPhotoWell,
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: item.photoUrl.isEmpty
                        ? const Icon(Icons.image_not_supported_outlined)
                        : Image.network(
                            item.photoUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported_outlined),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      item.barcodeEan,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: lang.catalogRemove,
                onPressed: () => notifier.remove(item.seedId),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MoneyField(
                  label: lang.catalogPrice,
                  value: entry.price,
                  onChanged: (v) => notifier.updatePrice(item.seedId, v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MoneyField(
                  label: lang.catalogCost,
                  value: entry.cost,
                  onChanged: (v) => notifier.updateCost(item.seedId, v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoneyField extends StatefulWidget {
  const _MoneyField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<_MoneyField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
  }

  @override
  void didUpdateWidget(covariant _MoneyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final formatted = _format(widget.value);
    if (_controller.text != formatted &&
        double.tryParse(_controller.text.replaceAll(',', '.')) != widget.value) {
      _controller.text = formatted;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      onChanged: (raw) {
        final parsed = double.tryParse(raw.replaceAll(',', '.'));
        if (parsed != null) {
          widget.onChanged(parsed);
        }
      },
    );
  }
}
