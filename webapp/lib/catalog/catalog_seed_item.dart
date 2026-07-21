/// One prepared FMCG product from the static discovery seed.
class CatalogSeedItem {
  const CatalogSeedItem({
    required this.seedId,
    required this.title,
    required this.designation,
    required this.barcodeEan,
    required this.category,
    required this.suggestedPrice,
    required this.suggestedCost,
    required this.stockUnit,
    required this.unitsInOnePiece,
    required this.photoUrl,
  });

  final String seedId;
  final String title;
  final String designation;
  final String barcodeEan;
  final String category;
  final double suggestedPrice;
  final double suggestedCost;
  final String stockUnit;
  final double unitsInOnePiece;
  final String photoUrl;

  factory CatalogSeedItem.fromJson(Map<String, dynamic> json) {
    return CatalogSeedItem(
      seedId: json['seedId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      designation: json['designation'] as String? ?? json['title'] as String? ?? '',
      barcodeEan: json['barcodeEan'] as String? ?? '',
      category: json['category'] as String? ?? '',
      suggestedPrice: (json['suggestedPrice'] as num?)?.toDouble() ?? 0,
      suggestedCost: (json['suggestedCost'] as num?)?.toDouble() ?? 0,
      stockUnit: json['stockUnit'] as String? ?? 'unit',
      unitsInOnePiece: (json['unitsInOnePiece'] as num?)?.toDouble() ?? 1,
      photoUrl: json['photoUrl'] as String? ?? '',
    );
  }
}

/// Root of [assets/catalog/fmcg_seed.json].
class CatalogSeed {
  const CatalogSeed({
    required this.version,
    required this.vertical,
    required this.items,
  });

  final int version;
  final String vertical;
  final List<CatalogSeedItem> items;

  factory CatalogSeed.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return CatalogSeed(
      version: json['version'] as int? ?? 1,
      vertical: json['vertical'] as String? ?? 'fmcg',
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(CatalogSeedItem.fromJson)
          .toList(growable: false),
    );
  }

  List<String> get categories {
    final seen = <String>{};
    final ordered = <String>[];
    for (final item in items) {
      if (item.category.isEmpty) continue;
      if (seen.add(item.category)) {
        ordered.add(item.category);
      }
    }
    return ordered;
  }
}
