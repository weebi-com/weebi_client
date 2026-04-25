import 'dart:convert';

import 'config/api_url.dart';
import 'config_loader_web.dart' if (dart.library.io) 'config_loader_stub.dart'
    as config_fetcher;
import 'environment.dart';

/// Loads configuration. Order: hardcoded kApiUrl → config.json. Change lib/config/api_url.dart when merging dev ↔ prod.
Future<void> loadConfig() async {
  // 1) Hardcoded (set per branch; merge triggers build with correct URL)
  if (kApiUrl.isNotEmpty) {
    Config.init(apiUrl: kApiUrl, locale: 'fr');
    return;
  }

  // 2) Runtime fetch (optional)
  try {
    final configJson = await config_fetcher.fetchConfigJson();
    if (configJson != null && configJson.isNotEmpty) {
      final map = jsonDecode(configJson) as Map<String, dynamic>;
      Config.init(
        apiUrl: (map['API_URL'] as String?) ?? '',
        locale: (map['LOCALE'] as String?) ?? 'fr',
      );
      return;
    }
  } catch (_) {}

  Config.init(apiUrl: '', locale: 'fr');
}
