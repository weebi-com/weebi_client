import 'package:flutter_test/flutter_test.dart';
import 'package:web_admin/catalog/catalog_calibre_mapper.dart';
import 'package:web_admin/catalog/catalog_seed_item.dart';
import 'package:web_admin/catalog/catalog_selection.dart';

void main() {
  test('CatalogSeed.fromJson parses items and categories', () {
    final seed = CatalogSeed.fromJson({
      'version': 1,
      'vertical': 'fmcg',
      'items': [
        {
          'seedId': 'a',
          'title': 'Cola',
          'designation': 'Cola 33cl',
          'barcodeEan': '123',
          'category': 'Boissons',
          'suggestedPrice': 500,
          'suggestedCost': 350,
          'stockUnit': 'unit',
          'unitsInOnePiece': 1,
          'photoUrl': 'https://example.com/a.jpg',
        },
        {
          'seedId': 'b',
          'title': 'Chips',
          'barcodeEan': '456',
          'category': 'Snacks',
          'suggestedPrice': 600,
          'suggestedCost': 400,
          'photoUrl': '',
        },
      ],
    });

    expect(seed.items, hasLength(2));
    expect(seed.categories, ['Boissons', 'Snacks']);
    expect(seed.items.first.designation, 'Cola 33cl');
    expect(seed.items.last.designation, 'Chips');
  });

  test('CatalogCalibreMapper assigns sequential ids and retail articles', () {
    const mapper = CatalogCalibreMapper();
    final entries = [
      CatalogSelectionEntry.fromSeed(
        const CatalogSeedItem(
          seedId: 'a',
          title: 'Cola',
          designation: 'Cola 33cl',
          barcodeEan: '123',
          category: 'Boissons',
          suggestedPrice: 500,
          suggestedCost: 350,
          stockUnit: 'unit',
          unitsInOnePiece: 1,
          photoUrl: '',
        ),
      )..price = 550,
    ];

    final calibres = mapper.toCalibres(entries: entries, startingCalibreId: 7);
    expect(calibres, hasLength(1));
    expect(calibres.first.id, 7);
    expect(calibres.first.articlesRetail, hasLength(1));
    expect(calibres.first.articlesRetail.first.price, 550);
    expect(calibres.first.articlesRetail.first.barcodeEAN, '123');
    expect(CatalogCalibreMapper.nextCalibreId([1, 7, 3]), 8);
  });
}
