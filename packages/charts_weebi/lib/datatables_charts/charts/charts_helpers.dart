// Flutter imports:
import 'package:charts_weebi/timespan.dart';
import 'package:design_weebi/design_weebi.dart' show TextStyleWeebi;
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:models_weebi/utils.dart';

// Project imports:

class ChartsHelper {
  static int divider(double aggregator, int reportsLength) {
    final averageY = aggregator ~/ reportsLength;
    return averageY < 1000
        ? 1
        : averageY < 1000000
            ? 1000
            : averageY < 1000000000
                ? 1000000
                : 1000000000;
  }

  static Widget bottomTitles(
    double value,
    TitleMeta meta,
    Timespan timespan,
    DateTime date,
    DateFormat eeeDdateFormatter,
    DateFormat weekFormatter,
    DateFormat monthFormatter,
    DateFormat yearFormatter,
  ) {
    final Widget textWidget = Text(
        (timespan == Timespan.weekFour || timespan == Timespan.week)
            ? '${timespan.dateFormat(eeeDdateFormatter, weekFormatter, monthFormatter, yearFormatter).format(date)}-${timespan.dateFormat(
                  eeeDdateFormatter,
                  weekFormatter,
                  monthFormatter,
                  yearFormatter,
                ).format(date.add(Duration(days: 6)))}'
            : timespan
                .dateFormat(
                  eeeDdateFormatter,
                  weekFormatter,
                  monthFormatter,
                  yearFormatter,
                )
                .format(date),
        style: TextStyleWeebi.chartBottomLegend);

    return SideTitleWidget(meta: meta,
      space: 8, //margin top
      child: textWidget,
    );
  }

  static Widget leftSideTitles(double value, TitleMeta meta, int divider) {
    String text = '';
    if (divider == 1000) {
      text = 'K';
    } else if (divider == 1000000) {
      text = 'M';
    } else if (divider == 1000000000) {
      text = 'B';
    }
    return SideTitleWidget(
      meta: meta,
      space: 0,
      child:
          Text('${value.toInt()}$text', style: TextStyleWeebi.chartLeftLegend),
    );
  }
}
