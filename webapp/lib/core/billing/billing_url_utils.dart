/// Pure functions for billing URL manipulation, safe for unit testing.
library;

/// Removes checkout-related query parameters from a Flutter web hash fragment.
///
/// Example: `https://app.weebi.com/#/billing?success=true&checkout_id=123`
/// becomes `https://app.weebi.com/#/billing`.
String clearCheckoutQueryParams(String currentUrl) {
  final uri = Uri.parse(currentUrl);
  final fragment = uri.fragment;
  final qIndex = fragment.indexOf('?');
  if (qIndex < 0) return currentUrl;

  final path = fragment.substring(0, qIndex);
  final cleaned = Map<String, String>.from(
    Uri.splitQueryString(fragment.substring(qIndex + 1)),
  );

  cleaned.remove('success');
  cleaned.remove('provider');
  cleaned.remove('checkout_id');
  cleaned.remove('session_id');

  final newFragment = cleaned.isEmpty
      ? path
      : '$path?${Uri(queryParameters: cleaned).query}';

  return '${uri.origin}${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}#$newFragment';
}
