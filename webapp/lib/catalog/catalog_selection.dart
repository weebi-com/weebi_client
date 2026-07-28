import 'package:web_admin/catalog/catalog_seed_item.dart';

/// A seed item the boutique owner picked, with editable price/cost.
class CatalogSelectionEntry {
  CatalogSelectionEntry({
    required this.item,
    required this.price,
    required this.cost,
  });

  final CatalogSeedItem item;
  double price;
  double cost;

  factory CatalogSelectionEntry.fromSeed(CatalogSeedItem item) {
    return CatalogSelectionEntry(
      item: item,
      price: item.suggestedPrice,
      cost: item.suggestedCost,
    );
  }
}
