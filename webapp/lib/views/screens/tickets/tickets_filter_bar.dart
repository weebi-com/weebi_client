import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_admin/generated/l10n.dart';

/// How to filter soft-deleted tickets.
enum DeletedFilter {
  exclude, // only non-deleted (default)
  only, // only deleted
}

/// A boutique option for filtering and display.
class BoutiqueOption {
  final String id;
  final String name;
  final List<int>? logo;
  final String? logoExtension;

  const BoutiqueOption({
    required this.id,
    required this.name,
    this.logo,
    this.logoExtension,
  });

  bool get hasLogo =>
      logo != null &&
      logo!.isNotEmpty &&
      (logoExtension?.isNotEmpty ?? false);
}

/// Filter state for tickets overview.
class TicketsFilterState {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool? statusActive; // null = all, true = active, false = inactive
  final DeletedFilter deletedFilter;
  final String? boutiqueId; // null = all boutiques
  final bool groupByBoutique;

  const TicketsFilterState({
    this.dateFrom,
    this.dateTo,
    this.statusActive,
    this.deletedFilter = DeletedFilter.exclude,
    this.boutiqueId,
    this.groupByBoutique = false,
  });

  TicketsFilterState copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? statusActive,
    DeletedFilter? deletedFilter,
    String? boutiqueId,
    bool? groupByBoutique,
  }) {
    return TicketsFilterState(
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      statusActive: statusActive ?? this.statusActive,
      deletedFilter: deletedFilter ?? this.deletedFilter,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      groupByBoutique: groupByBoutique ?? this.groupByBoutique,
    );
  }
}

/// Explains that filtering / grouping tickets by store requires an active license seat.
class TicketsSeatGatedBoutiqueViewsButton extends StatelessWidget {
  const TicketsSeatGatedBoutiqueViewsButton({super.key});

  void _showHint(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Lang.of(context);
    final detail = lang.ticketsSeatGatedBoutiqueViewsDetail;

    return Tooltip(
      message: detail,
      child: OutlinedButton.icon(
        onPressed: () => _showHint(context, detail),
        icon: Icon(
          Icons.lock_outline_rounded,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        label: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              lang.ticketsSeatGatedBoutiqueViewsTitle,
              style: theme.textTheme.labelLarge,
            ),
            Text(
              lang.ticketsSeatEntitlementSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      ),
    );
  }
}

/// Filter bar for tickets: date range, status, soft-deleted, boutique, group.
class TicketsFilterBar extends StatelessWidget {
  final TicketsFilterState filter;
  final ValueChanged<TicketsFilterState> onFilterChanged;
  final List<BoutiqueOption> availableBoutiques;
  /// When false, store filter and "group by store" are replaced by a seat-entitlement notice.
  final bool ticketBoutiqueViewsUnlocked;

  const TicketsFilterBar({
    super.key,
    required this.filter,
    required this.onFilterChanged,
    this.availableBoutiques = const [],
    this.ticketBoutiqueViewsUnlocked = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Lang.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.ticketsFiltersTitle,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DateRangeChip(
                  dateFrom: filter.dateFrom,
                  dateTo: filter.dateTo,
                  onChanged: (from, to) =>
                      onFilterChanged(filter.copyWith(dateFrom: from, dateTo: to)),
                ),
                _StatusFilterChip(
                  statusActive: filter.statusActive,
                  onChanged: (v) =>
                      onFilterChanged(filter.copyWith(statusActive: v)),
                ),
                _DeletedFilterChip(
                  deletedFilter: filter.deletedFilter,
                  onChanged: (v) =>
                      onFilterChanged(filter.copyWith(deletedFilter: v)),
                ),
                if (ticketBoutiqueViewsUnlocked) ...[
                  _BoutiqueFilterChip(
                    boutiqueId: filter.boutiqueId,
                    availableBoutiques: availableBoutiques,
                    onChanged: (v) => onFilterChanged(
                      v == null
                          ? TicketsFilterState(
                              dateFrom: filter.dateFrom,
                              dateTo: filter.dateTo,
                              statusActive: filter.statusActive,
                              deletedFilter: filter.deletedFilter,
                              boutiqueId: null,
                              groupByBoutique: filter.groupByBoutique,
                            )
                          : filter.copyWith(boutiqueId: v),
                    ),
                  ),
                  _GroupByBoutiqueChip(
                    groupByBoutique: filter.groupByBoutique,
                    onChanged: (v) =>
                        onFilterChanged(filter.copyWith(groupByBoutique: v)),
                  ),
                ] else
                  const TicketsSeatGatedBoutiqueViewsButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRangeChip extends StatelessWidget {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final void Function(DateTime? from, DateTime? to) onChanged;

  const _DateRangeChip({
    required this.dateFrom,
    required this.dateTo,
    required this.onChanged,
  });

  String _label(Lang lang) {
    if (dateFrom == null && dateTo == null) return lang.ticketsDateAll;
    final from = dateFrom != null
        ? '${dateFrom!.day}/${dateFrom!.month}/${dateFrom!.year}'
        : '…';
    final to = dateTo != null
        ? '${dateTo!.day}/${dateTo!.month}/${dateTo!.year}'
        : '…';
    return '$from → $to';
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InputChip(
          avatar: const Icon(Icons.calendar_today, size: 18),
          label: Text(_label(lang)),
          onPressed: () => _showDatePicker(context),
        ),
        if (dateFrom != null || dateTo != null)
          IconButton(
            icon: const Icon(Icons.clear, size: 18),
            onPressed: () => onChanged(null, null),
            tooltip: lang.ticketsTooltipClearDates,
          ),
      ],
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final from = dateFrom ?? now.subtract(const Duration(days: 30));
    final to = dateTo ?? now;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: from, end: to),
    );
    if (picked != null && context.mounted) {
      onChanged(picked.start, picked.end);
    }
  }
}

class _StatusFilterChip extends StatelessWidget {
  final bool? statusActive;
  final void Function(bool?) onChanged;

  const _StatusFilterChip({
    required this.statusActive,
    required this.onChanged,
  });

  String _label(Lang lang) {
    if (statusActive == null) return lang.ticketsStatusAll;
    return statusActive! ? lang.ticketsStatusActive : lang.ticketsStatusInactive;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    return PopupMenuButton<bool?>(
      tooltip: lang.ticketsTooltipFilterByStatus,
      itemBuilder: (_) => [
        PopupMenuItem(value: null, child: Text(lang.ticketsStatusAll)),
        PopupMenuItem(value: true, child: Text(lang.ticketsStatusActive)),
        PopupMenuItem(value: false, child: Text(lang.ticketsStatusInactive)),
      ],
      onSelected: onChanged,
      child: InputChip(
        avatar: Icon(
          statusActive == null ? Icons.filter_list : Icons.check_circle_outline,
          size: 18,
          color: statusActive == true
              ? Colors.green
              : statusActive == false
                  ? Colors.grey
                  : null,
        ),
        label: Text(_label(lang)),
      ),
    );
  }
}

class _DeletedFilterChip extends StatelessWidget {
  final DeletedFilter deletedFilter;
  final void Function(DeletedFilter) onChanged;

  const _DeletedFilterChip({
    required this.deletedFilter,
    required this.onChanged,
  });

  String _label(Lang lang) {
    switch (deletedFilter) {
      case DeletedFilter.exclude:
        return lang.ticketsDeletedExclude;
      case DeletedFilter.only:
        return lang.ticketsDeletedChip;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    return PopupMenuButton<DeletedFilter>(
      tooltip: lang.ticketsTooltipFilterDeleted,
      itemBuilder: (_) => [
        PopupMenuItem(
          value: DeletedFilter.exclude,
          child: Text(lang.ticketsDeletedExclude),
        ),
        PopupMenuItem(
          value: DeletedFilter.only,
          child: Text(lang.ticketsDeletedOnly),
        ),
      ],
      onSelected: onChanged,
      child: InputChip(
        avatar: Icon(
          Icons.delete_outline,
          size: 18,
          color: deletedFilter == DeletedFilter.only
              ? Colors.red
              :   null,
        ),
        label: Text(_label(lang)),
      ),
    );
  }
}

class _BoutiqueFilterChip extends StatelessWidget {
  final String? boutiqueId;
  final List<BoutiqueOption> availableBoutiques;
  final void Function(String?) onChanged;

  const _BoutiqueFilterChip({
    required this.boutiqueId,
    required this.availableBoutiques,
    required this.onChanged,
  });

  String _label(Lang lang) {
    if (boutiqueId == null) return lang.ticketsBoutiqueAll;
    final b = availableBoutiques.where((x) => x.id == boutiqueId).firstOrNull;
    return b?.name ?? boutiqueId ?? lang.ticketsBoutiqueFallback;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    return PopupMenuButton<String?>(
      tooltip: lang.ticketsTooltipFilterBoutique,
      itemBuilder: (_) => [
        PopupMenuItem(value: null, child: Text(lang.ticketsBoutiqueAll)),
        ...availableBoutiques.map(
          (b) => PopupMenuItem(value: b.id, child: Text(b.name)),
        ),
      ],
      onSelected: onChanged,
      child: InputChip(
        avatar: _BoutiqueAvatar(
          boutiqueId: boutiqueId,
          availableBoutiques: availableBoutiques,
          selected: boutiqueId != null,
        ),
        label: Text(_label(lang)),
      ),
    );
  }
}

class _BoutiqueAvatar extends StatelessWidget {
  final String? boutiqueId;
  final List<BoutiqueOption> availableBoutiques;
  final bool selected;

  const _BoutiqueAvatar({
    required this.boutiqueId,
    required this.availableBoutiques,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    if (boutiqueId == null) {
      return Icon(Icons.store, size: 18, color: selected ? Colors.blue : null);
    }
    final b = availableBoutiques.where((x) => x.id == boutiqueId).firstOrNull;
    if (b != null && b.hasLogo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.memory(
          Uint8List.fromList(b.logo!),
          width: 18,
          height: 18,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.store,
            size: 18,
            color: selected ? Colors.blue : null,
          ),
        ),
      );
    }
    return Icon(Icons.store, size: 18, color: selected ? Colors.blue : null);
  }
}

class _GroupByBoutiqueChip extends StatelessWidget {
  final bool groupByBoutique;
  final void Function(bool) onChanged;

  const _GroupByBoutiqueChip({
    required this.groupByBoutique,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    return FilterChip(
      avatar: Icon(
        Icons.view_list,
        size: 18,
        color: groupByBoutique ? Colors.blue : null,
      ),
      label: Text(
        groupByBoutique
            ? lang.ticketsGroupByBoutique
            : lang.ticketsSortChronological,
      ),
      selected: groupByBoutique,
      onSelected: onChanged,
    );
  }
}
