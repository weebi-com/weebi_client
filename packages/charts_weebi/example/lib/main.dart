import 'package:charts_weebi/charts_weebi.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:models_weebi/models.dart';
import 'package:models_weebi/utils.dart';

/// Fixed "today" so chart buckets stay stable between runs (swap for
/// [DateTime.now] when you want a live demo).
final DateTime _demoAnchor = DateTime(2024, 6, 15);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChartsWeebiExampleApp());
}

class ChartsWeebiExampleApp extends StatelessWidget {
  const ChartsWeebiExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Charts Weebi example',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const _ChartsDemoPage(),
    );
  }
}

class _ChartsDemoPage extends StatefulWidget {
  const _ChartsDemoPage();

  @override
  State<_ChartsDemoPage> createState() => _ChartsDemoPageState();
}

class _ChartsDemoPageState extends State<_ChartsDemoPage> {
  int _shopId = 1;

  @override
  Widget build(BuildContext context) {
    final ranges = sortedLastSevenDayRanges(_demoAnchor);
    final dateRanges = DateRangesWithTimeSpan(Timespan.daySeven, ranges);

    // One sell per day. `shopTkFinFlows` in models still aggregates every
    // ticket unless you enable per-boutique filtering there; [_shopId] is
    // already passed on each [ReportFinancialBoutique] for when that lands.
    final tickets = <TicketWeebi>[
      for (var i = 0; i < 7; i++)
        TicketWeebi.dummySell.copyWith(
          id: 100 + i + _shopId * 10,
          date: _demoAnchor.subtract(Duration(days: i)),
          creationDate: _demoAnchor.subtract(Duration(days: i)),
          statusUpdateDate: _demoAnchor.subtract(Duration(days: i)),
        ),
    ];

    final reports = buildBoutiqueFinancialReportsForRanges(
      shopId: _shopId,
      ranges: ranges,
      tickets: tickets,
    );

    final eeeD = DateFormat('EEE d');
    final week = DateFormat("'week' w yyyy");
    final month = DateFormat('MMM yyyy');
    final year = DateFormat('y');

    return Scaffold(
      appBar: AppBar(
        title: const Text('charts_weebi — financial charts'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            'Demo data: 7-day window around ${_demoAnchor.toIso8601String().split('T').first}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text('Boutique 1')),
              ButtonSegment(value: 2, label: Text('Boutique 2')),
            ],
            selected: {_shopId},
            onSelectionChanged: (s) => setState(() => _shopId = s.first),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 720,
            child: BoutiqueFinancialChartsFrame(
              dateRangesWithTimeSpan: dateRanges,
              reports: reports,
              eeeDdateFormatter: eeeD,
              weekFormatter: week,
              monthFormatter: month,
              yearFormatter: year,
            ),
          ),
        ],
      ),
    );
  }
}
