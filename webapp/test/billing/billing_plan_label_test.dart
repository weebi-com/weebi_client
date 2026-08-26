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
    test('entreprise productId (legacy label)', () {
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
    test('allows premium only for purchase', () {
      expect(isBillingCatalogProduct('premium'), isTrue);
      expect(isBillingCatalogProduct('entreprise'), isFalse);
      expect(isBillingCatalogProduct('syscohada'), isFalse);
      expect(isBillingCatalogProduct('pro'), isFalse);
      expect(isBillingCatalogProduct('solo'), isFalse);
    });
  });

  group('isSyscohadaBillingProduct', () {
    test('recognizes syscohada only', () {
      expect(isSyscohadaBillingProduct('syscohada'), isTrue);
      expect(isSyscohadaBillingProduct('premium'), isFalse);
    });
  });

  group('formatBillingOfferPrice', () {
    test('shows XOF first then EUR for premium', () {
      expect(
        formatBillingOfferPrice(
          amountCents: 1400,
          currency: 'eur',
          productId: 'premium',
        ),
        '9\u00A0900 XOF / 14.00 EUR',
      );
    });

    test('shows CFA first then EUR for premium in French', () {
      expect(
        formatBillingOfferPrice(
          amountCents: 1400,
          currency: 'eur',
          productId: 'premium',
          languageCode: 'fr',
        ),
        '9\u00A0900 CFA / 14.00 EUR',
      );
    });

    test('shows XOF first then EUR for syscohada', () {
      expect(
        formatBillingOfferPrice(
          amountCents: 290,
          currency: 'eur',
          productId: 'syscohada',
        ),
        '1\u00A0900 XOF / 2.90 EUR',
      );
    });

    test('shows CFA first then EUR for syscohada in French', () {
      expect(
        formatBillingOfferPrice(
          amountCents: 290,
          currency: 'eur',
          productId: 'syscohada',
          languageCode: 'fr',
        ),
        '1\u00A0900 CFA / 2.90 EUR',
      );
    });

    test('falls back to catalog amount when no XOF list price', () {
      expect(
        formatBillingOfferPrice(
          amountCents: 9900,
          currency: 'eur',
          productId: 'legacy',
        ),
        '99.00 EUR',
      );
    });

    test('shows CDF first then EUR for premium in DRC', () {
      expect(
        formatBillingOfferPrice(
          amountCents: 1400,
          currency: 'eur',
          productId: 'premium',
          pawapayCurrency: 'CDF',
        ),
        '39\u00A0900 CDF / 14.00 EUR',
      );
    });

    test('shows CDF first then EUR for syscohada in DRC', () {
      expect(
        formatBillingOfferPrice(
          amountCents: 290,
          currency: 'eur',
          productId: 'syscohada',
          languageCode: 'fr',
          pawapayCurrency: 'CDF',
        ),
        '7\u00A0900 CDF / 2.90 EUR',
      );
    });
  });

  group('pawapayOfferCurrency', () {
    test('defaults to XOF', () {
      expect(
        pawapayOfferCurrency(countryAlpha2s: const [], currencies: const []),
        'XOF',
      );
    });

    test('uses CDF when country is CD', () {
      expect(
        pawapayOfferCurrency(countryAlpha2s: const ['cd'], currencies: const []),
        'CDF',
      );
    });

    test('uses CDF when currency is CDF or CD', () {
      expect(
        pawapayOfferCurrency(
          countryAlpha2s: const [],
          currencies: const ['CDF'],
        ),
        'CDF',
      );
      expect(
        pawapayOfferCurrency(
          countryAlpha2s: const [],
          currencies: const ['cd'],
        ),
        'CDF',
      );
    });
  });

  group('isBillingCatalogLicense', () {
    test('allows ENTERPRISE and PREMIUM owned licenses', () {
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
