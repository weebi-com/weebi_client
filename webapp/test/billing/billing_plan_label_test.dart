import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/views/screens/billing/billing_plan_label.dart';

void main() {
  late Lang lang;

  setUpAll(() async {
    lang = await Lang.load(const Locale('en'));
  });

  group('billingPlanLabel', () {
    test('entreprise productId', () {
      expect(
        billingPlanLabel(lang, productId: 'entreprise'),
        'Weebi Entreprise',
      );
    });

    test('premium productId', () {
      expect(
        billingPlanLabel(lang, productId: 'premium'),
        'Weebi Premium',
      );
    });

    test('ENTERPRISE license plan', () {
      expect(
        billingPlanLabel(lang, licensePlan: LicensePlan.ENTERPRISE),
        'Weebi Entreprise',
      );
    });

    test('PREMIUM license plan', () {
      expect(
        billingPlanLabel(lang, licensePlan: LicensePlan.PREMIUM),
        'Weebi Premium',
      );
    });

    test('unknown productId is returned as-is', () {
      expect(
        billingPlanLabel(lang, productId: 'legacy-pack'),
        'legacy-pack',
      );
    });
  });

  group('isBillingCatalogProduct', () {
    test('allows entreprise and premium only', () {
      expect(isBillingCatalogProduct('entreprise'), isTrue);
      expect(isBillingCatalogProduct('premium'), isTrue);
      expect(isBillingCatalogProduct('pro'), isFalse);
      expect(isBillingCatalogProduct('solo'), isFalse);
    });
  });

  group('isBillingCatalogLicense', () {
    test('allows ENTERPRISE and PREMIUM only', () {
      expect(
        isBillingCatalogLicense(License()..licensePlan = LicensePlan.ENTERPRISE),
        isTrue,
      );
      expect(
        isBillingCatalogLicense(License()..licensePlan = LicensePlan.PREMIUM),
        isTrue,
      );
      final legacyPlan = LicensePlan.valueOf(3);
      if (legacyPlan != null) {
        expect(
          isBillingCatalogLicense(License()..licensePlan = legacyPlan),
          isFalse,
        );
      }
    });
  });
}
