import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_admin/core/constants/values.dart';
import 'package:web_admin/core/services/fx_rate_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    FxRateService().resetCachesForTest();
    SharedPreferences.setMockInitialValues({});
  });

  group('FxRateService', () {
    test('applyRateToAmounts multiplies each amount', () {
      expect(
        FxRateService.applyRateToAmounts(2.0, [10, 0.5, 3]),
        [20.0, 1.0, 6.0],
      );
    });

    test('FxRateSnapshot json roundtrip', () {
      final original = FxRateSnapshot(
        base: 'EUR',
        quote: 'USD',
        rate: 1.1,
        fetchedAtUtc: DateTime.utc(2026, 1, 15, 12),
      );
      final decoded = FxRateSnapshot.fromJson(
        jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
      );
      expect(decoded, isNotNull);
      expect(decoded!.base, 'EUR');
      expect(decoded.quote, 'USD');
      expect(decoded.rate, 1.1);
      expect(
        decoded.fetchedAtUtc.toIso8601String(),
        original.fetchedAtUtc.toIso8601String(),
      );
    });

    test('getRate returns 1 for identical currencies', () async {
      final s = await FxRateService().getRate(base: 'eur', quote: 'EUR');
      expect(s, isNotNull);
      expect(s!.rate, 1.0);
    });

    test('getRate uses SharedPreferences backup without network', () async {
      final snap = FxRateSnapshot(
        base: 'EUR',
        quote: 'USD',
        rate: 1.25,
        fetchedAtUtc: DateTime.utc(2026, 3, 1),
      );
      SharedPreferences.setMockInitialValues({
        '${SharePrefKeys.fxRateBackupPrefix}EUR_USD': jsonEncode(snap.toJson()),
      });

      final got = await FxRateService().getRate(base: 'EUR', quote: 'USD');
      expect(got, isNotNull);
      expect(got!.rate, 1.25);
      expect(got.base, 'EUR');
      expect(got.quote, 'USD');
    });

    test('second getRate for same pair returns cached in-memory snapshot',
        () async {
      final snap = FxRateSnapshot(
        base: 'GBP',
        quote: 'USD',
        rate: 1.3,
        fetchedAtUtc: DateTime.utc(2026, 3, 1),
      );
      SharedPreferences.setMockInitialValues({
        '${SharePrefKeys.fxRateBackupPrefix}GBP_USD': jsonEncode(snap.toJson()),
      });
      final svc = FxRateService();
      final a = await svc.getRate(base: 'GBP', quote: 'USD');
      final b = await svc.getRate(base: 'GBP', quote: 'USD');
      expect(identical(a, b), isTrue);
    });

    test('convertPrimaryAmountsToSecondary uses one resolved rate', () async {
      final snap = FxRateSnapshot(
        base: 'EUR',
        quote: 'USD',
        rate: 2.0,
        fetchedAtUtc: DateTime.utc(2026, 3, 1),
      );
      SharedPreferences.setMockInitialValues({
        '${SharePrefKeys.fxRateBackupPrefix}EUR_USD': jsonEncode(snap.toJson()),
      });

      final batch = await FxRateService().convertPrimaryAmountsToSecondary(
        primaryIso: 'EUR',
        secondaryIso: 'USD',
        primaryAmounts: [10, 5],
      );
      expect(batch, isNotNull);
      expect(batch!.secondaryAmounts, [20.0, 10.0]);
      expect(batch.snapshot.rate, 2.0);
    });

    test('frankfurterSupportsPair is true only when both ISO codes are ECB set',
        () {
      expect(FxRateService.frankfurterSupportsPair('EUR', 'USD'), isTrue);
      expect(FxRateService.frankfurterSupportsPair('eur', 'usd'), isTrue);
      expect(FxRateService.frankfurterSupportsPair('EUR', 'CDF'), isFalse);
      expect(FxRateService.frankfurterSupportsPair('CDF', 'USD'), isFalse);
    });
  });
}
