// Flutter imports:
import 'package:design_weebi/design_weebi.dart' show TextStyleWeebi;
import 'package:flutter/material.dart';

// Project imports:

List<DataColumn> financialColumns(void Function(int, bool) sortDate) => [
      DataColumn(
        label: const Expanded(
            child: Text('Intervalle', overflow: TextOverflow.visible)),
        numeric: false,
        onSort: sortDate,
      ),
      const DataColumn(
          label: Expanded(
              child: Text('ventes cash',
                  overflow: TextOverflow.visible, style: TextStyleWeebi.white)),
          numeric: true,
          tooltip: 'ventes/sell'),
      const DataColumn(
          label: Expanded(
              child: Text('versements c',
                  overflow: TextOverflow.visible, style: TextStyleWeebi.white)),
          numeric: true,
          tooltip: 'versement des clients/sellCovered'),
      const DataColumn(
          label: Expanded(
              child: Text('ventes a c',
                  overflow: TextOverflow.visible, style: TextStyleWeebi.white)),
          numeric: true,
          tooltip: 'ventes à crédit/sellDeferred'),
      const DataColumn(
        label: Expanded(
            child: Text('achats',
                overflow: TextOverflow.visible, style: TextStyleWeebi.white)),
        numeric: true,
        tooltip: 'achats/spend',
      ),
      const DataColumn(
        label: Expanded(
            child: Text('versements f',
                overflow: TextOverflow.visible, style: TextStyleWeebi.white)),
        numeric: true,
        tooltip: 'versements aux fournisseurs /spendCovered',
      ),
      const DataColumn(
          label: Expanded(
              child: Text('achats a c',
                  overflow: TextOverflow.visible, style: TextStyleWeebi.white)),
          numeric: true,
          tooltip: 'achats a credit /spendDeferred'),
      // const DataColumn(
      //     label:
      //         Expanded(child: Text('salaires', overflow: TextOverflow.visible)),
      //     numeric: true),
    ];
