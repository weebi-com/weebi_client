// Flutter imports:
import 'package:charts_weebi/datatables_charts/charts/boutique/financials/boutique_financial_charts_frame.dart';
import 'package:charts_weebi/datatables_charts/reports/boutique_financial_pluto_table.dart';
import 'package:design_weebi/design_weebi.dart';
import 'package:flutter/material.dart';
// import 'package:gatekeeper_weebi/gatekeeper_weebi.dart';

// Package imports:
import 'package:intl/intl.dart' show DateFormat;
import 'package:models_weebi/closings.dart';
import 'package:models_weebi/extensions.dart';
import 'package:models_weebi/models.dart';
import 'package:models_weebi/reports.dart';
import 'package:models_weebi/utils.dart';
import 'package:provider/provider.dart';

class BoutiqueFinancialTableFrameView extends StatefulWidget {
  // this look strange to have shop here
  // but it is because this view can be reused to display a company's shops stats

  final int shopId;
  final List<ClosingLedgerBoutique> closingLedgerBoutiques;
  final List<TicketWeebi> tickets;
  final DateFormat eeeDdateFormatter,
      weekFormatter,
      monthFormatter,
      yearFormatter;
  const BoutiqueFinancialTableFrameView({
    required this.tickets,
    required this.closingLedgerBoutiques,
    this.shopId = 0,
    required this.eeeDdateFormatter,
    required this.weekFormatter,
    required this.monthFormatter,
    required this.yearFormatter,
    super.key,
  });

  @override
  State<BoutiqueFinancialTableFrameView> createState() =>
      _BoutiqueFinancialTableFrameViewState();
}

class _BoutiqueFinancialTableFrameViewState
    extends State<BoutiqueFinancialTableFrameView> {
  final reports = <ReportFinancialBoutique>[];
  Timespan timespan = Timespan.daySeven;
  DateRangesWithTimeSpan dateRangesWithTimeSpan =
      DateRangesWithTimeSpan(Timespan.daySeven, DateTime.now().lastSevenDays);
  ScrollController? controller;
  ScrollController? horizontalController;

  @override
  void initState() {
    super.initState();

    controller = ScrollController();
    horizontalController = ScrollController();

    dateRangesWithTimeSpan =
        DateRangesWithTimeSpan(timespan, DateTime.now().lastSevenDays);
    for (final daterange in dateRangesWithTimeSpan.ranges
      ..sort((a, b) => a.start.compareTo(b.start))) {
      final h = ReportFinancialBoutique(
        shopId: widget.shopId,
        tickets: widget.tickets,
        closingLedgerBoutiques: widget.closingLedgerBoutiques,
        startDate: daterange.start,
        endDate: daterange.end,
      );
      reports.add(h);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    horizontalController?.dispose();
    super.dispose();
  }

  void setDateRangeTimeSpan(Timespan? temp) {
    if (temp != null) {
      setState(() {
        timespan = temp;
      });
      if (timespan == Timespan.daySeven) {
        dateRangesWithTimeSpan =
            DateRangesWithTimeSpan(timespan, DateTime.now().lastSevenDays);
      } else if (timespan == Timespan.weekFour) {
        dateRangesWithTimeSpan =
            DateRangesWithTimeSpan(timespan, DateTime.now().lastFourWeeks);
      } else if (timespan == Timespan.monthThree) {
        dateRangesWithTimeSpan =
            DateRangesWithTimeSpan(timespan, DateTime.now().lastThreeMonths);
      } else if (timespan == Timespan.monthThirteen) {
        dateRangesWithTimeSpan =
            DateRangesWithTimeSpan(timespan, DateTime.now().lastThirteenMonths);
      } else if (timespan == Timespan.yearThree) {
        dateRangesWithTimeSpan =
            DateRangesWithTimeSpan(timespan, DateTime.now().lastThreeYears);
      }
    }

    setState(() {
      reports.clear();
      for (final daterange in dateRangesWithTimeSpan.ranges
        ..sort((a, b) => a.start.compareTo(b.start))) {
        final h = ReportFinancialBoutique(
          shopId: widget.shopId,
          tickets: widget.tickets,
          closingLedgerBoutiques: widget.closingLedgerBoutiques,
          startDate: daterange.start,
          endDate: daterange.end,
        );
        reports.add(h);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO check with server for this
    // final gatekeeper = context.read<Gatekeeper>();
    return Scaffold(
      appBar: AppBar(
        title: Text('suiviDesFinances'),
        backgroundColor: ColorsWeebi.tealSell,
      ),
      body: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            RadioMenuButton(
                              child: Text(
                                  '${Timespan.daySeven.chartLength} jours'),
                              value: Timespan.daySeven,
                              groupValue: timespan,
                              onChanged: setDateRangeTimeSpan,
                              //controlAffinity: ListTileControlAffinity.platform,
                            ),
                            RadioMenuButton(
                              child: Text(
                                  '${Timespan.weekFour.chartLength} semaines'),
                              value: Timespan.weekFour,
                              groupValue: timespan,
                              onChanged: setDateRangeTimeSpan,
                              // controlAffinity: ListTileControlAffinity.platform,
                            ),
                            RadioMenuButton(
                              child: Text(
                                  '${Timespan.monthThree.chartLength} mois'),
                              value: Timespan.monthThree,
                              groupValue: timespan,
                              onChanged: setDateRangeTimeSpan,
                              // controlAffinity: ListTileControlAffinity.platform,
                            ),
                            RadioMenuButton(
                              child: Text(
                                  '${Timespan.monthThirteen.chartLength} mois'),
                              value: Timespan.monthThirteen,
                              groupValue: timespan,
                              onChanged: setDateRangeTimeSpan,
                              // controlAffinity: ListTileControlAffinity.platform,
                            ),
                            RadioMenuButton(
                              child:
                                  Text('${Timespan.yearThree.chartLength} ans'),
                              value: Timespan.yearThree,
                              groupValue: timespan,
                              onChanged: setDateRangeTimeSpan,
                              // controlAffinity: ListTileControlAffinity.platform,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Flexible(
                        flex: 3,
                        fit: FlexFit.loose,
                        child: BoutiqueFinancialChartsFrame(
                          dateRangesWithTimeSpan: dateRangesWithTimeSpan,
                          reports: reports,
                          eeeDdateFormatter: widget.eeeDdateFormatter,
                          weekFormatter: widget.weekFormatter,
                          monthFormatter: widget.monthFormatter,
                          yearFormatter: widget.yearFormatter,
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
                BoutiqueFinancialTableBody(
                  reports,
                  timespan,
                  widget.eeeDdateFormatter,
                  widget.weekFormatter,
                  widget.monthFormatter,
                  widget.yearFormatter,
                )
              ],
            ),
    );
  }
}
