import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/contacts/provider/contacts_provider.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/core/theme/theme_extensions/app_data_table_theme.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/views/widgets/entity/entity_chrome.dart';

class ContactsListContent extends StatefulWidget {
  const ContactsListContent({
    super.key,
    required this.onCreate,
    required this.onOpen,
  });

  final VoidCallback onCreate;
  final ValueChanged<ContactPb> onOpen;

  @override
  State<ContactsListContent> createState() => _ContactsListContentState();
}

class _ContactsListContentState extends State<ContactsListContent> {
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
    final notifier = context.watch<ContactsNotifier>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(lang.menuContacts, style: theme.textTheme.headlineMedium),
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
            if (notifier.contacts.isNotEmpty ||
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
          Text(
            notifier.error!,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        Expanded(child: _table(context, notifier, lang)),
      ],
    );
  }

  Widget _table(BuildContext context, ContactsNotifier notifier, Lang lang) {
    if (notifier.isLoading && notifier.contacts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (notifier.contacts.isEmpty &&
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
        dataTableTheme: tableTheme?.dataTableThemeData,
      ),
      child: SingleChildScrollView(
        child: PaginatedDataTable(
          source: _ContactsTableSource(
            items: notifier.contacts,
            offset: notifier.offset,
            total: notifier.total,
            onTap: widget.onOpen,
          ),
          rowsPerPage: notifier.pageSize,
          showCheckboxColumn: false,
          showFirstLastButtons: true,
          onPageChanged: notifier.setPage,
          columns: [
            DataColumn(label: Text(lang.contactLastName)),
            DataColumn(label: Text(lang.contactFirstName)),
            DataColumn(label: Text(lang.contactPhone)),
            DataColumn(label: Text(lang.contactMail)),
            DataColumn(label: Text(lang.contactIsClient)),
            DataColumn(label: Text(lang.contactIsSupplier)),
            DataColumn(label: Text(lang.catalogColumnStatus)),
          ],
        ),
      ),
    );
  }
}

class _ContactsTableSource extends DataTableSource {
  _ContactsTableSource({
    required this.items,
    required this.offset,
    required this.total,
    required this.onTap,
  });

  final List<ContactPb> items;
  final int offset;
  final int total;
  final ValueChanged<ContactPb> onTap;

  @override
  DataRow? getRow(int index) {
    if (index < offset || index >= offset + items.length) {
      return DataRow.byIndex(
        index: index,
        cells: List.generate(7, (_) => const DataCell(Text(''))),
      );
    }
    final contact = items[index - offset];
    final phone = contact.hasPhone()
        ? '+${contact.phone.countryCode} ${contact.phone.number}'
        : '';
    return DataRow.byIndex(
      index: index,
      onSelectChanged: (_) => onTap(contact),
      cells: [
        DataCell(Text(contact.lastName)),
        DataCell(Text(contact.firstName)),
        DataCell(Text(phone)),
        DataCell(Text(contact.mail)),
        DataCell(Text(contact.isClient ? '✓' : '')),
        DataCell(Text(contact.isSupplier ? '✓' : '')),
        DataCell(Text(contact.status ? '✓' : '✗')),
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
