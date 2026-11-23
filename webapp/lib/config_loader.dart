import 'dart:convert';

import 'config/api_url.dart';
import 'config/resolve_runtime_config.dart';
import 'config_loader_web.dart' if (dart.library.io) 'config_loader_stub.dart'
    as config_fetcher;
import 'environment.dart';

/// Loads configuration.
///
/// Order: container `/config.json` (`API_URL`) when that URL is non-empty,
/// otherwise the compiled [kApiUrl]. Deployed dev and prod set `API_URL` on
/// the Cloud Run service. [kApiUrl] remains the production fallback so a
/// container with no `API_URL` still reaches production.
Future<void> loadConfig() async {
  final runtime = await _readRuntimeConfig();
  final resolved = resolveRuntimeConfig(
    compiledApiUrl: kApiUrl,
    runtime: runtime,
  );
  Config.init(
    apiUrl: resolved.apiUrl,
    locale: resolved.locale,
    isBffMode: resolved.isBffMode,
    isDev: resolved.isDev,
  );
}

Future<Map<String, dynamic>?> _readRuntimeConfig() async {
  try {
    final configJson = await config_fetcher.fetchConfigJson();
    if (configJson == null || configJson.isEmpty) return null;
    final decoded = jsonDecode(configJson);
    if (decoded is! Map) return null;
    return decoded.map((key, value) => MapEntry(key.toString(), value));
  } catch (_) {
    return null;
  }
}
