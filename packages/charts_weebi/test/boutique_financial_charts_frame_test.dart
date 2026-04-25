import 'package:charts_weebi/charts_weebi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:models_weebi/extensions.dart';
import 'package:models_weebi/reports.dart';
import 'package:models_weebi/utils.dart';

Widget _pumpChartsFrame({
  required List<ReportFinancialBoutique> reports,
  required DateRangesWithTimeSpan dateRangesWithTimeSpan,
}) {
  // Locale-neutral patterns avoid intl initialization in tests.
  final df = DateFormat('E d');
  return MaterialApp(
    home: Scaffold(
      body: BoutiqueFinancialChartsFrame(
        dateRangesWithTimeSpan: dateRangesWithTimeSpan,
        reports: reports,
        eeeDdateFormatter: df,
        weekFormatter: df,
        monthFormatter: df,
        yearFormatter: df,
      ),
    ),
  );
}

void main() {
  testWidgets('shows empty state when there is no report', (tester) async {
    final anchor = DateTime(2024, 6, 15);
    await tester.pumpWidget(
      _pumpChartsFrame(
        reports: const [],
        dateRangesWithTimeSpan:
            DateRangesWithTimeSpan(Timespan.daySeven, anchor.lastSevenDays),
      ),
    );
    expect(find.text('Pas de données'), findsOneWidget);
  });

  testWidgets('renders treasury title when reports are non-empty', (tester) async {
    final anchor = DateTime(2024, 6, 15);
    final ranges = sortedLastSevenDayRanges(anchor);
    await tester.pumpWidget(
      _pumpChartsFrame(
        reports: buildBoutiqueFinancialReportsForRanges(
          shopId: 1,
          ranges: ranges,
          tickets: const [],
        ),
        dateRangesWithTimeSpan: DateRangesWithTimeSpan(Timespan.daySeven, ranges),
      ),
    );
    expect(find.text('Variations De Tresorerie'), findsOneWidget);
  });
}
