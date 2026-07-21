import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/catalog/catalog_selection.dart';

/// Maps picked seed items to [CalibrePb] for [ArticleService.createMany].
class CatalogCalibreMapper {
  const CatalogCalibreMapper();

  List<CalibrePb> toCalibres({
    required List<CatalogSelectionEntry> entries,
    required int startingCalibreId,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    final calibres = <CalibrePb>[];
    var nextId = startingCalibreId;

    for (final entry in entries) {
      final calibreId = nextId++;
      final retail = ArticleRetailPb.create()
        ..id = 1
        ..calibreId = calibreId
        ..designation = entry.item.designation
        ..kind = ArticleKindPb.retail
        ..status = true
        ..creationDate = now
        ..updateDate = now
        ..statusUpdateDate = now
        ..price = entry.price
        ..cost = entry.cost
        ..unitsInOnePiece = entry.item.unitsInOnePiece
        ..barcodeEAN = entry.item.barcodeEan;

      final calibre = CalibrePb.create()
        ..id = calibreId
        ..creationDate = now
        ..updateDate = now
        ..statusUpdateDate = now
        ..status = true
        ..title = entry.item.title
        ..stockUnit = _stockUnitFromSeed(entry.item.stockUnit)
        ..kind = ArticleKindPb.retail
        ..articlesRetail.add(retail);

      calibres.add(calibre);
    }

    return calibres;
  }

  /// Next free positive id given existing chain calibre ids.
  static int nextCalibreId(Iterable<int> existingIds) {
    var maxId = 0;
    for (final id in existingIds) {
      if (id > maxId) maxId = id;
    }
    return maxId + 1;
  }

  CalibrePb_StockUnit _stockUnitFromSeed(String raw) {
    switch (raw.toLowerCase()) {
      case 'centiliter':
      case 'cl':
        return CalibrePb_StockUnit.centiliter;
      case 'centimeter':
      case 'cm':
        return CalibrePb_StockUnit.centimeter;
      case 'gram':
      case 'g':
        return CalibrePb_StockUnit.gram;
      case 'kilogram':
      case 'kg':
        return CalibrePb_StockUnit.kilogram;
      case 'liter':
      case 'l':
        return CalibrePb_StockUnit.liter;
      case 'meter':
      case 'm':
        return CalibrePb_StockUnit.meter;
      case 'unit':
      default:
        return CalibrePb_StockUnit.unit;
    }
  }
}
