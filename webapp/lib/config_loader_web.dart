import 'core/web/web_platform.dart' as web;

/// Fetches /config.json from same origin (used when API_URL is not set at build time).
Future<String?> fetchConfigJson() async {
  final uri = Uri.base.resolve('/config.json');
  try {
    final text = await web.fetchText(uri);
    return text.isEmpty ? null : text;
  } catch (_) {
    return null;
  }
}
