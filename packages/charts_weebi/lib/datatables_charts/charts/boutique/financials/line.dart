// Flutter imports:
import 'package:charts_weebi/datatables_charts/charts/charts_helpers.dart';
import 'package:charts_weebi/datatables_charts/charts/widgets/legend_widget.dart' show Legend, LegendsListWidget;
import 'package:charts_weebi/datatables_charts/charts/widgets/title_widget.dart' show TitleChartWidget;
import 'package:design_weebi/design_weebi.dart' show ColorsWeebi;
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:models_weebi/models.dart' show FinFlowType;
import 'package:models_weebi/reports.dart';
import 'package:models_weebi/utils.dart';


class LineChartSample2 extends StatefulWidget {
  final Timespan timespan;
  final List<ReportFinancialBoutique> reports;
  final double minY;
  final double maxY;
  final int divider;
  final double leftTitlesInterval;

  final DateFormat eeeDdateFormatter,
      weekFormatter,
      monthFormatter,
      yearFormatter;
  const LineChartSample2(
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
  });

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    Color(0xFF50E4FF),
    Color(0xFF2196F3),
  ];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TitleChartWidget('Variations De Tresorerie'),
            const SizedBox(height: 8),
            AspectRatio(
              aspectRatio: 3,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 18,
                  left: 12,
                  top: 24,
                  bottom: 12,
                ),
                child: LineChart(
                  showAvg ? avgData() : mainData(),
                ),
              ),
            ),
            LegendsListWidget(
              legends: [
                Legend(
                  'Recettes - Dépenses',
                  gradientColors.last,
                  icon: const Icon(
                    Icons.insert_chart,
                    color: ColorsWeebi.blueInventory,
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          top: 10,
          right: 30,
          height: 60,
          child: TextButton(
            onPressed: () => setState(() => showAvg = !showAvg),
            child: Text(
              'Moyenne',
              style: TextStyle(
                fontSize: 12,
                color: gradientColors.last,
              ),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        drawHorizontalLine: true,
        horizontalInterval: widget.leftTitlesInterval,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: ColorsWeebi.blueInventory,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            interval: 1,
            getTitlesWidget: (value, meta) => ChartsHelper.bottomTitles(
              value,
              meta,
              widget.timespan,
              widget.reports[value.toInt()].start,
              widget.eeeDdateFormatter,
              widget.weekFormatter,
              widget.monthFormatter,
              widget.yearFormatter,
            ),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: widget.leftTitlesInterval,
            reservedSize: 42,
            getTitlesWidget: (value, meta) =>
                ChartsHelper.leftSideTitles(value, meta, widget.divider),
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: widget.reports.length.toDouble() - 1,
      minY: widget.minY,
      maxY: widget.maxY,
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (var i = 0; i < widget.reports.length; i++)
              FlSpot(
                  i.toDouble(),
                  widget.reports[i].financialFlows.cashflow.toDouble() /
                      widget.divider),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withValues(alpha: 0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: false,
        horizontalInterval: widget.leftTitlesInterval,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            interval: 1,
            // interval: 1,
            getTitlesWidget: (value, meta) => ChartsHelper.bottomTitles(
              value,
              meta,
              widget.timespan,
              widget.reports[value.toInt()].start,
              widget.eeeDdateFormatter,
              widget.weekFormatter,
              widget.monthFormatter,
              widget.yearFormatter,
            ),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            interval: widget.leftTitlesInterval,
            getTitlesWidget: (value, meta) =>
                ChartsHelper.leftSideTitles(value, meta, widget.divider),
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: widget.reports.length.toDouble() - 1,
      minY: widget.minY,
      maxY: widget.maxY,
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (var i = 0; i < widget.reports.length; i++)
              FlSpot(i.toDouble(),
                  widget.reports.cashFlowAverage / widget.divider),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withValues(alpha: 0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withValues(alpha: 0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
