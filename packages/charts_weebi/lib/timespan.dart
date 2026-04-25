// Package imports:
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/intl.dart';
import 'package:models_weebi/utils.dart';

extension Formatter on Timespan {
  DateFormat dateFormat(
    DateFormat eeeDdateFormatter,
    DateFormat weekFormatter,
    DateFormat monthFormatter,
    DateFormat yearFormatter,
  ) {
    switch (this) {
      case Timespan.day:
        return eeeDdateFormatter;
      case Timespan.daySeven:
        return eeeDdateFormatter;
      case Timespan.week:
        return weekFormatter;
      case Timespan.weekFour:
        return weekFormatter;
      case Timespan.month:
        return monthFormatter;
      case Timespan.monthThree:
        return monthFormatter;
      case Timespan.monthThirteen:
        return monthFormatter;
      case Timespan.year:
        return yearFormatter;
      case Timespan.yearThree:
        return yearFormatter;
      default:
        throw 'unsupported timespan dateformat';
    }
  }
}
