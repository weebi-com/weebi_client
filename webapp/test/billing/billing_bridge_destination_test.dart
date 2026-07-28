import 'package:flutter_test/flutter_test.dart';
import 'package:web_admin/core/billing/billing_bridge_destination.dart';

void main() {
  group('parseBillingBridgeDestination', () {
    test('premium without year', () {
      final dest = parseBillingBridgeDestination(
        query: {'t': 'abc', 'product': 'premium'},
        requireToken: true,
      );
      expect(dest, isNotNull);
      expect(dest!.isPremium, isTrue);
      expect(dest.fiscalYear, isNull);
      expect(dest.billingLocation, '/billing?product=premium');
    });

    test('syscohada with year', () {
      final dest = parseBillingBridgeDestination(
        query: {'t': 'tok', 'product': 'syscohada', 'year': '2025'},
        requireToken: true,
      );
      expect(dest, isNotNull);
      expect(dest!.isSyscohada, isTrue);
      expect(dest.fiscalYear, 2025);
      expect(dest.billingLocation, '/billing?product=syscohada&year=2025');
    });

    test('missing token when required returns null', () {
      expect(
        parseBillingBridgeDestination(
          query: {'product': 'premium'},
          requireToken: true,
        ),
        isNull,
      );
    });

    test('syscohada without year returns null', () {
      expect(
        parseBillingBridgeDestination(
          query: {'product': 'syscohada'},
        ),
        isNull,
      );
    });

    test('unknown product returns null', () {
      expect(
        parseBillingBridgeDestination(
          query: {'product': 'entreprise'},
        ),
        isNull,
      );
    });

    test('billing deep-link without token still parses product', () {
      final dest = parseBillingBridgeDestination(
        query: {'product': 'premium'},
      );
      expect(dest?.isPremium, isTrue);
    });
  });

  group('bridgeTokenFromQuery', () {
    test('reads t', () {
      expect(bridgeTokenFromQuery({'t': ' xyz '}), 'xyz');
      expect(bridgeTokenFromQuery({}), isNull);
    });
  });
}
