// Flutter imports:
import 'package:charts_weebi/datatables_charts/charts/widgets/indicator.dart' show Indicator;
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:models_weebi/models.dart' show TicketType;

// Project imports:
import 'package:design_weebi/design_weebi.dart';
class PieChartSample3 extends StatefulWidget {
  final Map<TicketType, double> reportsMap;

  const PieChartSample3(this.reportsMap, {super.key});

  @override
  State<StatefulWidget> createState() => PieChartSample3State();
}

class PieChartSample3State extends State<PieChartSample3> {
  int touchedIndex = 0;

  List<PieChartSectionData> showingSections() {
    final list = <PieChartSectionData>[];
    final total = widget.reportsMap.values.fold(0.0, (pv, e) => pv + e);
    for (var i = 0; i < widget.reportsMap.length; i++) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;
      final widgetSize = isTouched ? 55.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      final pieSlice = PieChartSectionData(
        color: widget.reportsMap.keys.toList()[i].iconColor,
        value: widget.reportsMap.values.toList()[i],
        title:
            '${((widget.reportsMap.values.toList()[i] / total) * 100).round()}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: shadows,
        ),
        badgeWidget: _Badge(
          widget.reportsMap.keys.toList()[i].icon,
          size: widgetSize,
          borderColor: widget.reportsMap.keys.toList()[i].iconColor,
        ),
        badgePositionPercentageOffset: .98,
      );
      list.add(pieSlice);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(
            show: false,
          ),
          sectionsSpace: 0,
          centerSpaceRadius: 0,
          sections: showingSections(),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.icon, {
    required this.size,
    required this.borderColor,
  });
  final Icon icon;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(child: icon),
    );
  }
}

class FinancialTypesLegend extends StatelessWidget {
  const FinancialTypesLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Indicator(
          color: TicketType.financialTypes[index].iconColor,
          text: TicketType.financialTypes[index].toString(),
          isSquare: true,
        ),
      ),
      itemCount: TicketType.financialTypes.length,
    );
  }
}
