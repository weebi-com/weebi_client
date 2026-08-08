import 'package:flutter_test/flutter_test.dart';
import 'package:web_admin/core/billing/billing_url_utils.dart';

void main() {
  group('clearCheckoutQueryParams', () {
    test('removes all checkout params from hash fragment', () {
      const url =
          'https://app.weebi.com/some/path?orig=1#/billing?success=true&provider=stripe&checkout_id=cs_123&session_id=sess_456&keep=me';
      final cleaned = clearCheckoutQueryParams(url);
      expect(cleaned,
          'https://app.weebi.com/some/path?orig=1#/billing?keep=me');
    });

    test('removes fragment-only params', () {
      const url = 'https://app.weebi.com/#/billing?success=true';
      final cleaned = clearCheckoutQueryParams(url);
      expect(cleaned, 'https://app.weebi.com/#/billing');
    });

    test('preserves non-checkout params', () {
      const url = 'https://app.weebi.com/#/billing?product=premium&success=true';
      final cleaned = clearCheckoutQueryParams(url);
      expect(cleaned, 'https://app.weebi.com/#/billing?product=premium');
    });

    test('returns original URL if no query in fragment', () {
      const url = 'https://app.weebi.com/#/billing';
      final cleaned = clearCheckoutQueryParams(url);
      expect(cleaned, url);
    });

    test('returns original URL if no fragment', () {
      const url = 'https://app.weebi.com/billing?success=true';
      final cleaned = clearCheckoutQueryParams(url);
      expect(cleaned, url);
    });
  });
}
