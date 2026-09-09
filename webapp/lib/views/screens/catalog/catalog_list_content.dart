import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/catalog/catalog_notifier.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/core/theme/theme_extensions/app_data_table_theme.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/views/widgets/entity/entity_chrome.dart';

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
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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
    final source = _CatalogTableSource(
      items: notifier.items,
      offset: notifier.offset,
      total: notifier.total,
      onTap: widget.onOpen,
    );
    return Theme(
      data: theme.copyWith(
        cardTheme: tableTheme?.cardTheme,
        dataTableTheme: tableTheme?.dataTableThemeData,
      ),
      child: SingleChildScrollView(
        child: PaginatedDataTable(
          source: source,
          rowsPerPage: notifier.pageSizeUsed,
          showCheckboxColumn: false,
          showFirstLastButtons: true,
          onPageChanged: notifier.setPage,
          columns: [
            DataColumn(label: Text(lang.catalogColumnTitle)),
            DataColumn(label: Text(lang.catalogColumnPrice), numeric: true),
            DataColumn(label: Text(lang.catalogCost), numeric: true),
            DataColumn(label: Text(lang.catalogColumnBarcode)),
          ],
        ),
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
  });

  final List<CalibrePb> items;
  final int offset;
  final int total;
  final ValueChanged<CalibrePb> onTap;

  @override
  DataRow? getRow(int index) {
    if (index < offset || index >= offset + items.length) {
      return DataRow.byIndex(
        index: index,
        cells: List.generate(4, (_) => const DataCell(Text(''))),
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
        DataCell(Text(_formatAmount(retail?.price), style: style)),
        DataCell(Text(_formatAmount(retail?.cost), style: style)),
        DataCell(Text(retail?.barcodeEAN ?? '', style: style)),
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
