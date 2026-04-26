// Flutter imports:
import 'package:design_weebi/design_weebi.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:models_weebi/collection.dart';

import 'package:intl/intl.dart' show NumberFormat, DateFormat;
import 'package:models_weebi/closings.dart';
import 'package:models_weebi/models.dart';
import 'package:models_weebi/reports.dart';

// Project imports:

class BoutiqueStockTableFrameView extends StatelessWidget {
  final BoutiqueWeebi boutique;
  final List<TicketWeebi> tickets;
  final List<ClosingStockBoutique> closingStockBoutiques;
  final List<CalibreWeebi> products;
  final NumberFormat numFormat;
  final DateFormat dateFormat;
  const BoutiqueStockTableFrameView(
      {required this.boutique,
      required this.tickets,
      required this.closingStockBoutiques,
      required this.products,
      required this.numFormat,
      required this.dateFormat,
      super.key});

  @override
  Widget build(BuildContext context) {
    final List<ReportStockBoutique> shopStockReports = [];
    final List<ReportStockArtCalibre> reportStockArtCalibres = [];
    Map<String, List<ReportStockArtCalibre>> reportsStockArtCalibreMap = {};
    // preloading reports
    for (final cSS in closingStockBoutiques) {
      final temp = ReportStockBoutique(
        shop: boutique,
        tickets: tickets,
        closingStockBoutiques: closingStockBoutiques,
        articlesC: products..sort((a, b) => a.id.compareTo(b.id)),
        startDate: cSS.closingRange.start,
        endDate: cSS.closingRange.end,
      );
      shopStockReports.add(temp);
    }
    // making reports using ComputeStockContactMixin
    for (final shopStockReport in shopStockReports) {
      reportStockArtCalibres.addAll(shopStockReport.reportStockArtCalibres);
    }

// grouping them so they are in right order
    reportsStockArtCalibreMap =
        groupBy(reportStockArtCalibres, (ReportStockArtCalibre rSP) {
      return '${rSP.id}';
    });
    for (var report in reportsStockArtCalibreMap.values) {
      report.sort((a, b) => a.start.compareTo(b.start));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('${boutique.id} ${boutique.name}'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              color: ColorsWeebi.expTableAccentColor, child: const SizedBox())
          // * Below was legacy broken code for a specific client
          // I removed it so we can rework this doing something simple
          // lesson learnt : avoid using flutter_expandable_table
          // powerful but not simple enough
          // StockExpandableTableBody(
          //  products,
          //  reportsStockArtCalibreMap,
          //  numFormat,
          //  dateFormat,
          //)),
          ),
    );
  }
}
