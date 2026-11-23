import 'core/web/web_platform.dart' as web;

/// Fetches /config.json from the same origin. The container writes this file
/// from API_URL at start; a non-empty API_URL overrides the compiled fallback.
Future<String?> fetchConfigJson() async {
  final uri = Uri.base.resolve('/config.json');
  try {
    final text = await web.fetchText(uri);
    return text.isEmpty ? null : text;
  } catch (_) {
    return null;
  }
}
