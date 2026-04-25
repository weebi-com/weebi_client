// Flutter imports:
// ignore_for_file: unused_element

// Flutter imports:
import 'package:charts_weebi/timespan.dart';
import 'package:design_weebi/design_weebi.dart' show ColorsWeebi, TextStyleWeebi;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:intl/intl.dart' show DateFormat;
import 'package:models_weebi/reports.dart';
import 'package:models_weebi/utils.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pdf_widgets;
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:printing/printing.dart' as pdf_printing;

// Project imports:

import 'package:pluto_grid_plus_export/pluto_grid_plus_export.dart'
    as pluto_grid_plus_export;

class BoutiqueFinancialTableBody extends StatelessWidget {
  final List<ReportFinancialBoutique> reports;
  final Timespan timespan;
  final DateFormat eeeDdateFormatter,
      weekFormatter,
      monthFormatter,
      yearFormatter;
  const BoutiqueFinancialTableBody(
      this.reports,
      this.timespan,
      this.eeeDdateFormatter,
      this.weekFormatter,
      this.monthFormatter,
      this.yearFormatter,
      {super.key});

  @override
  Widget build(BuildContext context) {
    DraggableScrollableController controllerDrag =
        DraggableScrollableController();
    final columns = [
      PlutoColumn(
          width: 142,
          enableColumnDrag: false,
          enableContextMenu: false,
          enableRowDrag: false,
          title: 'Type',
          field: 'type',
          type: PlutoColumnType.text(),
          readOnly: true,
          frozen: PlutoColumnFrozen.start),
      ...(reports.cast<ReportFinancialBoutique>().map(
            (e) => PlutoColumn(
              width: timespan == Timespan.day
                  ? 111
                  : PlutoGridSettings.columnWidth,
              textAlign: PlutoColumnTextAlign.center,
              readOnly: true,
              enableColumnDrag: false,
              enableContextMenu: false,
              enableRowDrag: false,
              title: (timespan == Timespan.weekFour ||
                      timespan == Timespan.week)
                  ? '${timespan.dateFormat(eeeDdateFormatter, weekFormatter, monthFormatter, yearFormatter).format(e.start)}-${timespan.dateFormat(eeeDdateFormatter, weekFormatter, monthFormatter, yearFormatter).format(e.end)}'
                  : timespan
                      .dateFormat(eeeDdateFormatter, weekFormatter,
                          monthFormatter, yearFormatter)
                      .format(e.start),
              field: e.start.toIso8601String(),
              type: PlutoColumnType.number(),
            ),
          ))
    ];

    final cellsTotalMap = reports.cast<ReportFinancialBoutique>().cellsTotalMap;

    final rows = [
      for (final row in cellsTotalMap.entries)
        PlutoRow(
          cells: {
            'type': PlutoCell(value: row.key.toString()),
            for (final cell in row.value.entries)
              cell.key.start.toIso8601String(): PlutoCell(value: cell.value),
          },
        )
    ];

    return DraggableScrollableSheet(
      controller: controllerDrag,
      initialChildSize: 0.35,
      minChildSize: 0.1,
      maxChildSize: 0.7,
      builder: (BuildContext context, ScrollController scrollController) =>
          SingleChildScrollView(
        controller: scrollController,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.6,
          child: PlutoGrid(
            key: UniqueKey(),
            columns: columns,
            rows: rows,
            configuration: PlutoGridConfiguration(),
            mode: PlutoGridMode.readOnly,
            createHeader: (stateManager) =>
                _Header(timespan, stateManager: stateManager),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  final Timespan timespan;
  const _Header(this.timespan, {required this.stateManager});

  final PlutoGridStateManager stateManager;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  bool isLoading = false;

  void _printToPdfAndShareOrSave() async {
    final themeData = pdf_widgets.ThemeData.withFont(
      base: pdf_widgets.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
      ),
      bold: pdf_widgets.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
      ),
    );

    var plutoGridPdfExport = pluto_grid_plus_export.PlutoGridDefaultPdfExport(
      title: "Pluto Grid Sample pdf print",
      creator: "Pluto Grid Rocks!",
      format: pdf.PdfPageFormat.a4.landscape,
      themeData: themeData,
    );

    //Unhandled Exception: MissingPluginException(No implementation found for method sharePdf on channel net.nfet.printing)
    await pdf_printing.Printing.sharePdf(
        bytes: await plutoGridPdfExport.export(widget.stateManager),
        filename: plutoGridPdfExport.getFilename());
  }

  void _defaultExportGridAsCSV() async {
    final tableauDesOperations = 'tableau_des_operations';

    String title = '${tableauDesOperations}_${widget.timespan.properString}';
    var exported =
        pluto_grid_plus_export.PlutoGridExport.exportCSV(widget.stateManager);
    // TODO find a safe way to save this file for OS and web
    // await FileSaverV2.saveCsv(content: exported, fileName: title);
  }

  void _defaultExportGridAsCSVCompatibleWithExcel() async {
    // String title = "pluto_grid_export";
    // var exportCSV =
    //     pluto_grid_export.PlutoGridExport.exportCSV(widget.stateManager);
    // var exported = const Utf8Encoder().convert(
    //     // FIX Add starting \u{FEFF} / 0xEF, 0xBB, 0xBF
    //     // This allows open the file in Excel with proper character interpretation
    //     // See https://stackoverflow.com/a/155176
    //     '\u{FEFF}$exportCSV');
    // await FileSaver.instance.saveFile("$title.csv", exported, ".csv");
  }

  void _defaultExportGridAsCSVFakeExcel() async {
    // String title = "pluto_grid_export";
    // var exportCSV =
    //     pluto_grid_export.PlutoGridExport.exportCSV(widget.stateManager);
    // var exported = const Utf8Encoder().convert(
    //     // FIX Add starting \u{FEFF} / 0xEF, 0xBB, 0xBF
    //     // This allows open the file in Excel with proper character interpretation
    //     // See https://stackoverflow.com/a/155176
    //     '\u{FEFF}$exportCSV');
    // await FileSaver.instance.saveFile("$title.xls", exported, ".xls");
  }

  // void _exportGridAsTSV() async {
  //   String title = "pluto_grid_export";
  //   var exported = const Utf8Encoder().convert(PlutoGridExport.exportCSV(
  //     widget.stateManager,
  //     fieldDelimiter: "\t",
  //   ));
  //   await FileSaver.instance.saveFile("$title.csv", exported, ".csv");
  // }

  void _defaultExportGridAsCSVWithSemicolon() async {
    // String title = "pluto_grid_export";
    // var exported =
    //     const Utf8Encoder().convert(pluto_grid_export.PlutoGridExport.exportCSV(
    //   widget.stateManager,
    //   fieldDelimiter: ";",
    // ));
    // await FileSaver.instance.saveFile("$title.csv", exported, ".csv");
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.stateManager.headerHeight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'suiviParTypeDeTicket',
                style: TextStyleWeebi.blackBoldBig,
              ),
            ),
            IgnorePointer(
              ignoring: isLoading,
              child: ElevatedButton.icon(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(ColorsWeebi.green)),
                icon: const Icon(
                  Icons.save_alt,
                  color: Colors.white,
                ),
                label: const Text(
                  'sauvegarder',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  setState(() => isLoading = true);
                  _defaultExportGridAsCSV();
                  setState(() => isLoading = false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
