import 'dart:html' as html;

/// Fetches /config.json from same origin (used when API_URL is not set at build time).
Future<String?> fetchConfigJson() async {
  final uri = Uri.base.resolve('/config.json');
  final response = await html.window.fetch(uri.toString());
  if (response.status != 200) return null;
  final text = await response.text();
  return text.isEmpty ? null : text;
}
