// Flutter imports:
import 'package:charts_weebi/datatables_charts/charts/charts_helpers.dart' show ChartsHelper;
import 'package:charts_weebi/datatables_charts/charts/widgets/legend_widget.dart' show Legend, LegendsListWidget;
import 'package:charts_weebi/datatables_charts/charts/widgets/title_widget.dart' show TitleChartWidget;
import 'package:design_weebi/design_weebi.dart' show ColorsWeebi;
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:models_weebi/models.dart' show TicketType, FinFlowType;
import 'package:models_weebi/reports.dart';
import 'package:models_weebi/utils.dart';

// Project imports:

// Project imports:

class BarChartMargin extends StatelessWidget {
  final Timespan timespan;
  final List<ReportFinancialBoutique> reports;
  final Color leftBarColor = ColorsWeebi.green;
  final Color rightBarColor = ColorsWeebi.redSpend;
  final double maxY;
  final double minY;
  final int divider;
  final double leftTitlesInterval;
  final double width;
  final int leftLabelsCount;
  final DateFormat eeeDdateFormatter;
  final DateFormat weekFormatter;
  final DateFormat monthFormatter;
  final DateFormat yearFormatter;
  const BarChartMargin(
    this.timespan,
    this.reports,
    this.minY,
    this.maxY,
    this.divider,
    this.leftTitlesInterval,
    this.eeeDdateFormatter,
    this.weekFormatter,
    this.monthFormatter,
    this.yearFormatter, {
    super.key,
    this.width = 8,
    this.leftLabelsCount = 6,
  });

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: leftBarColor,
          width: width,
        ),
        BarChartRodData(
          toY: y2,
          color: rightBarColor,
          width: width,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    late List<BarChartGroupData> rawBarGroups;
    late List<BarChartGroupData> showingBarGroups;
    // reports.sort((a, b) => a.start.compareTo(b.start));

    final items = List<BarChartGroupData>.generate(
        reports.length,
        (index) => makeGroupData(
            index,
            reports[index].financialFlows.sellAndSellCoveredTotal.toDouble() /
                divider,
            reports[index].financialFlows.spendAndSpendCoveredTotal.toDouble() /
                divider));

    rawBarGroups = items;
    showingBarGroups = rawBarGroups;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TitleChartWidget('comparaisonDesRecettesEtDesDepenses'),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 3,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (a, b, c, d) => null,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: leftTitlesInterval,
                      getTitlesWidget: (value, meta) =>
                          ChartsHelper.leftSideTitles(value, meta, divider),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) =>
                          ChartsHelper.bottomTitles(
                        value,
                        meta,
                        timespan,
                        reports[value.toInt()].start,
                        eeeDdateFormatter,
                        weekFormatter,
                        monthFormatter,
                        yearFormatter,
                      ),
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: showingBarGroups,
                gridData: const FlGridData(show: true, drawVerticalLine: false),
              ),
            ),
          ),
          LegendsListWidget(
            legends: [
              Legend(
                  '${TicketType.sell.toString()} + ${TicketType.sellCovered.toString()}',
                  ColorsWeebi.green),
              Legend(
                  '${TicketType.spend.toString()} + ${TicketType.spendCovered.toString()}',
                  ColorsWeebi.redSpend),
            ],
          ),
        ],
      ),
    );
  }
}
