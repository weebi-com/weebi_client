import 'package:models_weebi/closings.dart';
import 'package:models_weebi/extensions.dart';
import 'package:models_weebi/models.dart';
import 'package:models_weebi/reports.dart';
import 'package:models_weebi/utils.dart';

/// Seven calendar buckets from [anchor.lastSevenDays], oldest → newest.
///
/// Prefer this over sorting [DateTime.lastSevenDays] in place so callers do not
/// mutate shared extension output.
List<DateRange> sortedLastSevenDayRanges(DateTime anchor) {
  final ranges = List<DateRange>.from(anchor.lastSevenDays);
  ranges.sort((a, b) => a.start.compareTo(b.start));
  return ranges;
}

/// One [ReportFinancialBoutique] per [ranges] entry, reusing the same
/// [tickets] and [closingLedgerBoutiques] for every bucket (typical dashboard
/// pattern before per-range ticket lists).
List<ReportFinancialBoutique> buildBoutiqueFinancialReportsForRanges({
  required int shopId,
  required List<DateRange> ranges,
  required List<TicketWeebi> tickets,
  List<ClosingLedgerBoutique> closingLedgerBoutiques = const [],
}) {
  return [
    for (final r in ranges)
      ReportFinancialBoutique(
        shopId: shopId,
        tickets: tickets,
        closingLedgerBoutiques: closingLedgerBoutiques,
        startDate: r.start,
        endDate: r.end,
      ),
  ];
}
