import 'dart:math';

import 'package:design_weebi/design_weebi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/catalog/catalog_notifier.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/core/theme/theme_extensions/app_data_table_theme.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/views/widgets/entity/entity_chrome.dart';

const int _catalogColumnCount = 7;

/// Search, filters, empty CTA, and paginated table — no portal chrome.
class CatalogListContent extends StatefulWidget {
  const CatalogListContent({
    super.key,
    required this.onCreate,
    required this.onOpen,
  });

  final VoidCallback onCreate;
  final ValueChanged<CalibrePb> onOpen;

  @override
  State<CatalogListContent> createState() => _CatalogListContentState();
}

class _CatalogListContentState extends State<CatalogListContent> {
  late final TextEditingController _searchController;
  final _tableScrollController = ScrollController();
  late final CatalogNotifier _notifier;
  late final _CatalogTableSource _source;

  @override
  void initState() {
    super.initState();
    _notifier = context.read<CatalogNotifier>();
    _searchController = TextEditingController(text: _notifier.query);
    _source = _CatalogTableSource(
      items: _notifier.items,
      offset: _notifier.offset,
      total: _notifier.total,
      onTap: widget.onOpen,
      categoryLabelOf: _notifier.categoriesLabelFor,
    );
    _notifier.addListener(_syncSource);
  }

  void _syncSource() {
    _source.update(
      items: _notifier.items,
      offset: _notifier.offset,
      total: _notifier.total,
      onTap: widget.onOpen,
      categoryLabelOf: _notifier.categoriesLabelFor,
    );
  }

  @override
  void didUpdateWidget(covariant CatalogListContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onOpen != widget.onOpen) {
      _source.onTap = widget.onOpen;
    }
  }

  @override
  void dispose() {
    _notifier.removeListener(_syncSource);
    _searchController.dispose();
    _tableScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final theme = Theme.of(context);
    final notifier = context.watch<CatalogNotifier>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(lang.menuCatalog, style: theme.textTheme.headlineMedium),
        const SizedBox(height: kDefaultPadding),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 280,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: lang.search,
                ),
                onSubmitted: notifier.setQuery,
              ),
            ),
            SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(lang.statusAll)),
                ButtonSegment(value: 1, label: Text(lang.statusActive)),
                ButtonSegment(value: 2, label: Text(lang.statusInactive)),
              ],
              selected: {notifier.statusFilter},
              onSelectionChanged: (s) => notifier.setStatusFilter(s.first),
            ),
            if (notifier.items.isNotEmpty ||
                notifier.total > 0 ||
                notifier.query.isNotEmpty)
              FilledButton.icon(
                onPressed: widget.onCreate,
                icon: const Icon(Icons.add),
                label: Text(lang.entityCreate),
              ),
          ],
        ),
        const SizedBox(height: kDefaultPadding),
        if (notifier.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              notifier.error!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        Expanded(child: _buildBody(context, notifier, lang)),
      ],
    );
  }

  Widget _buildBody(
      BuildContext context, CatalogNotifier notifier, Lang lang) {
    if (notifier.isLoading && notifier.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (notifier.items.isEmpty &&
        notifier.total == 0 &&
        notifier.query.isEmpty) {
      return EntityEmptyState(
        message: lang.entityEmptyHint,
        actionLabel: lang.entityCreate,
        onCreate: widget.onCreate,
      );
    }
    final theme = Theme.of(context);
    final tableTheme = theme.extension<AppDataTableTheme>();
    return Theme(
      data: theme.copyWith(
        cardTheme: tableTheme?.cardTheme,
        dataTableTheme: (tableTheme?.dataTableThemeData ?? theme.dataTableTheme)
            .copyWith(
          headingRowColor:
              const WidgetStatePropertyAll(ColorsWeebi.orangeArticle),
          headingTextStyle: const TextStyle(color: Colors.black),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dataTableWidth = max(kScreenWidthXxl, constraints.maxWidth);
          return Scrollbar(
            controller: _tableScrollController,
            thumbVisibility: true,
            trackVisibility: true,
            notificationPredicate: (notification) =>
                notification.metrics.axis == Axis.horizontal,
            child: SingleChildScrollView(
              key: const Key('catalogTableHScroll'),
              scrollDirection: Axis.horizontal,
              controller: _tableScrollController,
              child: SizedBox(
                width: dataTableWidth,
                height: constraints.maxHeight,
                child: SingleChildScrollView(
                  child: PaginatedDataTable(
                    key: ValueKey(
                      'catalog-${notifier.offset}-${notifier.total}-'
                      '${notifier.items.map((c) => c.id).join(',')}',
                    ),
                    source: _source,
                    rowsPerPage: notifier.pageSizeUsed,
                    showCheckboxColumn: false,
                    showFirstLastButtons: true,
                    onPageChanged: notifier.setPage,
                    columns: [
                      DataColumn(label: Text(lang.catalogColumnTitle)),
                      DataColumn(label: Text(lang.catalogColumnCategory)),
                      DataColumn(
                          label: Text(lang.catalogColumnPrice), numeric: true),
                      DataColumn(label: Text(lang.catalogCost), numeric: true),
                      DataColumn(label: Text(lang.catalogColumnBarcode)),
                      DataColumn(label: Text(lang.catalogStockUnit)),
                      DataColumn(label: Text(lang.catalogUnitsInOnePiece)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CatalogTableSource extends DataTableSource {
  _CatalogTableSource({
    required this.items,
    required this.offset,
    required this.total,
    required this.onTap,
    required this.categoryLabelOf,
  });

  List<CalibrePb> items;
  int offset;
  int total;
  ValueChanged<CalibrePb> onTap;
  String Function(int calibreId) categoryLabelOf;

  void update({
    required List<CalibrePb> items,
    required int offset,
    required int total,
    required ValueChanged<CalibrePb> onTap,
    required String Function(int calibreId) categoryLabelOf,
  }) {
    this.items = items;
    this.offset = offset;
    this.total = total;
    this.onTap = onTap;
    this.categoryLabelOf = categoryLabelOf;
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index < offset || index >= offset + items.length) {
      return DataRow.byIndex(
        index: index,
        cells: List.generate(
          _catalogColumnCount,
          (_) => const DataCell(Text('')),
        ),
      );
    }
    final calibre = items[index - offset];
    final retail =
        calibre.articlesRetail.isEmpty ? null : calibre.articlesRetail.first;
    final style = calibre.status ? null : const TextStyle(color: Colors.grey);
    return DataRow.byIndex(
      index: index,
      color: calibre.status
          ? null
          : const WidgetStatePropertyAll(Color(0x14757575)),
      onSelectChanged: (_) => onTap(calibre),
      cells: [
        DataCell(Text(_listName(calibre), style: style)),
        DataCell(Text(categoryLabelOf(calibre.id), style: style)),
        DataCell(Text(_formatAmount(retail?.price), style: style)),
        DataCell(Text(_formatAmount(retail?.cost), style: style)),
        DataCell(Text(retail?.barcodeEAN ?? '', style: style)),
        DataCell(Text(_stockUnitLabel(calibre.stockUnit), style: style)),
        DataCell(Text(_formatAmount(retail?.unitsInOnePiece), style: style)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => max(total, items.length);

  @override
  int get selectedRowCount => 0;
}

String _listName(CalibrePb calibre) {
  if (calibre.articlesRetail.length <= 1) {
    if (calibre.title.trim().isNotEmpty) return calibre.title;
    return calibre.articlesRetail.isEmpty
        ? ''
        : calibre.articlesRetail.first.designation;
  }
  return calibre.title;
}

String _formatAmount(double? value) {
  if (value == null) return '';
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toString();
}

String _stockUnitLabel(CalibrePb_StockUnit unit) {
  if (unit == CalibrePb_StockUnit.unknown) return '';
  return unit.name;
}
