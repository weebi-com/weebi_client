// Flutter imports:
import 'package:charts_weebi/datatables_charts/charts/charts_helpers.dart' show ChartsHelper;
import 'package:charts_weebi/datatables_charts/charts/widgets/legend_widget.dart' show Legend, LegendsListWidget;
import 'package:charts_weebi/datatables_charts/charts/widgets/title_widget.dart';
import 'package:design_weebi/design_weebi.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:models_weebi/models.dart' show TicketType, FinFlowType;
import 'package:models_weebi/reports.dart';
import 'package:models_weebi/utils.dart';


class BarChartVerticalSpends extends StatelessWidget {
  final Timespan timespan;
  final List<ReportFinancialBoutique> reports;
  final double maxY;
  final double minY;
  final int divider;
  final double _leftTitlesInterval;
  final double width;
  final int leftLabelsCount;
  final DateFormat eeeDdateFormatter,
      weekFormatter,
      monthFormatter,
      yearFormatter;
  BarChartVerticalSpends(
    this.timespan,
    this.reports,
    this.minY,
    this.maxY,
    this.divider,
    this._leftTitlesInterval,
    this.eeeDdateFormatter,
    this.weekFormatter,
    this.monthFormatter,
    this.yearFormatter, {
    super.key,
    this.width = 8,
    this.leftLabelsCount = 6,
  });

  final betweenSpace = 0.2;

  BarChartGroupData generateGroupData(
    int x,
    double spend,
    double spendCovered,
  ) {
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      barRods: [
        BarChartRodData(
          fromY: 0,
          toY: spend,
          color: TicketType.spend.iconColor,
          width: 10,
        ),
        BarChartRodData(
          fromY: spend + betweenSpace,
          toY: spend + betweenSpace + spendCovered,
          color: TicketType.spendCovered.iconColor,
          width: 10,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TitleChartWidget('Dépenses'),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 3,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(enabled: false),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: _leftTitlesInterval,
                      getTitlesWidget: (value, meta) =>
                          ChartsHelper.leftSideTitles(value, meta, divider),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
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
                barGroups: [
                  for (var i = 0; i < reports.length; i++)
                    generateGroupData(
                        i,
                        reports[i].financialFlows.spend.sumTotal.toDouble() /
                            divider,
                        reports[i]
                                .financialFlows
                                .spendCovered
                                .sumTotal
                                .toDouble() /
                            divider),
                ],
                maxY: maxY + (betweenSpace * 2).toInt(),
              ),
            ),
          ),
          LegendsListWidget(
            legends: [
              Legend(TicketType.spend.toString(),
                  TicketType.spend.iconColor,
                  icon: TicketType.spend.icon),
              Legend(TicketType.spendCovered.toString(),
                  TicketType.spendCovered.iconColor,
                  icon: TicketType.spendCovered.icon),
            ],
          ),
        ],
      ),
    );
  }
}
