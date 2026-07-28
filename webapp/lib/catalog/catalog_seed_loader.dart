import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:web_admin/catalog/catalog_seed_item.dart';

const String kFmcgCatalogSeedAsset = 'assets/catalog/fmcg_seed.json';

/// Loads the static FMCG discovery catalog from Flutter assets.
class CatalogSeedLoader {
  const CatalogSeedLoader();

  Future<CatalogSeed> loadFmcg() async {
    final raw = await rootBundle.loadString(kFmcgCatalogSeedAsset);
    final decoded = json.decode(raw) as Map<String, dynamic>;
    return CatalogSeed.fromJson(decoded);
  }
}
