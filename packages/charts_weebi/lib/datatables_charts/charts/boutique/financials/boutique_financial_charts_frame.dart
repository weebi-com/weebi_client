// Flutter imports:
import 'package:charts_weebi/datatables_charts/charts/boutique/financials/bar_compare.dart';
import 'package:charts_weebi/datatables_charts/charts/boutique/financials/bar_vertical_sells.dart';
import 'package:charts_weebi/datatables_charts/charts/boutique/financials/bar_vertical_spends.dart';
import 'package:charts_weebi/datatables_charts/charts/boutique/financials/line.dart';
import 'package:charts_weebi/datatables_charts/charts/boutique/financials/pie_chart.dart';
import 'package:charts_weebi/datatables_charts/charts/charts_helpers.dart' show ChartsHelper;
import 'package:charts_weebi/datatables_charts/charts/widgets/title_widget.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart' show DateFormat;
import 'package:models_weebi/models.dart' show FinFlowType;
import 'package:models_weebi/reports.dart';
import 'package:models_weebi/utils.dart';


class BoutiqueFinancialChartsFrame extends StatelessWidget {
  final double width = 8;
  final DateRangesWithTimeSpan dateRangesWithTimeSpan;
  final List<ReportFinancialBoutique> reports;
  final int leftLabelsCount = 6;
  final DateFormat eeeDdateFormatter,
      weekFormatter,
      monthFormatter,
      yearFormatter;
  const BoutiqueFinancialChartsFrame({
    super.key,
    required this.dateRangesWithTimeSpan,
    required this.reports,
    required this.eeeDdateFormatter,
    required this.weekFormatter,
    required this.monthFormatter,
    required this.yearFormatter,
  });

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const SingleChildScrollView(
        child: Column(
          children: [
            Center(child: Text('Pas de données')),
            SizedBox(height: 300),
          ],
        ),
      );
    }

    // prepare barchartmargin
    double minYBCMargin = double.maxFinite;
    double maxYBCMargin = double.minPositive;
    var aggregatorBCMargin = 0.0;

    // prepare barchartvertical sells
    double minYBCVSell = double.maxFinite;
    double maxYBCVSell = double.minPositive;
    var aggregatorBCVSell = 0.0;

    // prepare barchartvertical spends
    double minYBCVSpend = double.maxFinite;
    double maxYBCVSpend = double.minPositive;
    var aggregatorBCVSpend = 0.0;

    // prepare line cashflow
    double minLCF = double.infinity;
    double maxLCF = -double.infinity;
    var aggregatorLCF = 0.0;

    // a single iteration over all reports for better perfs
    for (final report in reports) {
      ///
      /// line cashflow
      final cashFlow = report.financialFlows.cashflow.toDouble();
      // cashFlows.add(cashFlow);
      aggregatorLCF += cashFlow;
      if (minLCF > cashFlow) {
        minLCF = cashFlow;
      }
      if (maxLCF < cashFlow) {
        maxLCF = cashFlow;
      }

      ///
      /// BarChart Margin
      final a = report.financialFlows.sellAndSellCoveredTotal.toDouble();
      final b = report.financialFlows.spendAndSpendCoveredTotal.toDouble();
      final reportYDataBCM = a > b ? a : b;
      aggregatorBCMargin += reportYDataBCM;
      if (minYBCMargin > reportYDataBCM) {
        minYBCMargin = reportYDataBCM;
      }
      if (maxYBCMargin < reportYDataBCM) {
        maxYBCMargin = reportYDataBCM;
      }

      ///
      /// BarChartVertical Sell
      final reportYDataBCVSell =
          (report.financialFlows.sell.sumTotal.toDouble() +
              report.financialFlows.sellCovered.sumTotal.toDouble());
      aggregatorBCVSell += reportYDataBCVSell;
      if (minYBCVSell > reportYDataBCVSell) {
        minYBCVSell = reportYDataBCVSell;
      }
      if (maxYBCVSell < reportYDataBCVSell) {
        maxYBCVSell = reportYDataBCVSell;
      }

      ///
      /// BarChartVertical Spend
      final reportYDataBCVSpend =
          (report.financialFlows.spend.sumTotal.toDouble() +
              report.financialFlows.spendCovered.sumTotal.toDouble());
      aggregatorBCVSpend += reportYDataBCVSpend;
      if (minYBCVSpend > reportYDataBCVSpend) {
        minYBCVSpend = reportYDataBCVSpend;
      }
      if (maxYBCVSpend < reportYDataBCVSpend) {
        maxYBCVSpend = reportYDataBCVSpend;
      }
    }

    final dividerLineCashflow =
        ChartsHelper.divider(aggregatorLCF, reports.length);
    minLCF = (minLCF / dividerLineCashflow).floorToDouble();
    maxLCF = (maxLCF / dividerLineCashflow).ceilToDouble();

    final dividerBCMargin =
        ChartsHelper.divider(aggregatorBCMargin, reports.length);
    minYBCMargin = (minYBCMargin / dividerBCMargin).floorToDouble();
    maxYBCMargin = (maxYBCMargin / dividerBCMargin).ceilToDouble();

    final dividerBVSell =
        ChartsHelper.divider(aggregatorBCVSell, reports.length);
    minYBCVSell = (minYBCVSell / dividerBVSell).floorToDouble();
    maxYBCVSell = (maxYBCVSell / dividerBVSell).ceilToDouble();

    final dividerBVSpend =
        ChartsHelper.divider(aggregatorBCVSpend, reports.length);
    minYBCVSpend = (minYBCVSpend / dividerBVSpend).floorToDouble();
    maxYBCVSpend = (maxYBCVSpend / dividerBVSpend).ceilToDouble();

    final temp = ((maxLCF - minLCF) / (leftLabelsCount - 1)).floorToDouble();
    final leftTitlesIntervalLCF =
        ((maxLCF - minLCF) / (leftLabelsCount - 1)).floorToDouble() == 0 ? 1.0 : temp;


    final leftTitlesIntervalYBC =
        ((maxYBCMargin - minYBCMargin) / (leftLabelsCount - 1)).floorToDouble();
    final leftTitlesIntervalYBVSell =
        ((maxYBCVSell - minYBCVSell) / (leftLabelsCount - 1)).floorToDouble();
    final leftTitlesIntervalYBVSpend =
        ((maxYBCVSpend - minYBCVSpend) / (leftLabelsCount - 1)).floorToDouble();

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
/*           leftTitlesIntervalLCF == 0 &&
              leftTitlesIntervalYBC == 0 &&
              leftTitlesIntervalYBVSell == 0 &&
              leftTitlesIntervalYBVSpend == 0 &&
              reports.totalPerType.values.any((element) => element > 0.0) ==
                  false */
          if (leftTitlesIntervalLCF != 0) ...[
            LineChartSample2(
              dateRangesWithTimeSpan.timespan,
              reports,
              minLCF,
              maxLCF,
              dividerLineCashflow,
              leftTitlesIntervalLCF,
              eeeDdateFormatter,
              weekFormatter,
              monthFormatter,
              yearFormatter,
            ),
            const Divider()
          ],
          if (leftTitlesIntervalYBC != 0) ...[
            BarChartMargin(
                dateRangesWithTimeSpan.timespan,
                reports,
                minYBCMargin,
                maxYBCMargin,
                dividerBCMargin,
                leftTitlesIntervalYBC,
                eeeDdateFormatter,
                weekFormatter,
                monthFormatter,
                yearFormatter,
                width: width,
                leftLabelsCount: leftLabelsCount),
            const Divider()
          ],
          if (leftTitlesIntervalYBVSell != 0) ...[
            BarChartVerticalSells(
                dateRangesWithTimeSpan.timespan,
                reports,
                minYBCVSell,
                maxYBCVSell,
                dividerBVSell,
                leftTitlesIntervalYBVSell,
                eeeDdateFormatter,
                weekFormatter,
                monthFormatter,
                yearFormatter,
                width: width,
                leftLabelsCount: leftLabelsCount),
            const Divider()
          ],
          if (leftTitlesIntervalYBVSpend != 0) ...[
            BarChartVerticalSpends(
                dateRangesWithTimeSpan.timespan,
                reports,
                minYBCVSpend,
                maxYBCVSpend,
                dividerBVSpend,
                leftTitlesIntervalYBVSpend,
                eeeDdateFormatter,
                weekFormatter,
                monthFormatter,
                yearFormatter,
                width: width,
                leftLabelsCount: leftLabelsCount),
            const Divider(),
          ],
          const SizedBox(height: 12), //easier to handle this title here
          if (reports.totalPerType.values.any((element) => element > 0.0)) ...[
            TitleChartWidget('Part de chaque type d’opération dans l’ensemble des transactions'),
            PieChartSample3(reports.totalPerType),
            const SizedBox(height: 200, child: FinancialTypesLegend()),
          ],
          const SizedBox(height: 300)
        ],
      ),
    );
  }
}
