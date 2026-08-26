import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/generated/l10n.dart';

/// Catalog product IDs sold as seat licenses in the billing portal.
const billingCatalogProductIds = {'premium'};

/// Punctual SYSCOHADA accounting product (one-shot per fiscal year, not a subscription).
const kSyscohadaProductId = 'syscohada';

bool isBillingCatalogProduct(String productId) =>
    billingCatalogProductIds.contains(productId.toLowerCase());

bool isSyscohadaBillingProduct(String productId) =>
    productId.trim().toLowerCase() == kSyscohadaProductId;

/// Owned licenses still shown in the portal (includes legacy Entreprise).
bool isBillingCatalogLicense(License license) =>
    license.licensePlan == LicensePlan.ENTERPRISE ||
    license.licensePlan == LicensePlan.PREMIUM;

/// Display name for catalog / license plan.
String billingPlanLabel(
  Lang lang, {
  String? productId,
  LicensePlan? licensePlan,
}) {
  final pid = productId?.toLowerCase();
  if (pid == 'entreprise' || licensePlan == LicensePlan.ENTERPRISE) {
    return lang.billingPlanEntreprise;
  }
  if (pid == 'premium' || licensePlan == LicensePlan.PREMIUM) {
    return lang.billingPlanPremium;
  }
  if (pid == kSyscohadaProductId) {
    return lang.billingSyscohadaTitle;
  }
  if (productId != null && productId.isNotEmpty) return productId;
  return licensePlan?.name ?? '';
}

/// Marketing XOF/XAF list prices (aligned with PawaPay checkout amounts).
int? billingXofListPrice(String productId) =>
    billingPawapayListPrice(productId, 'XOF');

/// PawaPay list price for [productId] in [currency] (XOF, XAF, or CDF).
int? billingPawapayListPrice(String productId, String currency) {
  final id = productId.trim().toLowerCase();
  final cur = currency.trim().toUpperCase();
  final isFcfa = cur == 'XOF' || cur == 'XAF';
  if (isFcfa) {
    switch (id) {
      case kSyscohadaProductId:
        return 1900;
      case 'premium':
        return 9900;
      default:
        return null;
    }
  }
  if (cur == 'CDF') {
    switch (id) {
      case kSyscohadaProductId:
        return 7900;
      case 'premium':
        return 39900;
      default:
        return null;
    }
  }
  return null;
}

/// True when country is DRC (`CD`) or billing currency is `CDF` / `CD`.
bool isDrcPawapayMarket({
  required Iterable<String> countryAlpha2s,
  required Iterable<String> currencies,
}) {
  for (final c in countryAlpha2s) {
    if (c.trim().toUpperCase() == 'CD') return true;
  }
  for (final cur in currencies) {
    final u = cur.trim().toUpperCase();
    if (u == 'CDF' || u == 'CD') return true;
  }
  return false;
}

/// Display/checkout currency for PawaPay offers: CDF in DRC, otherwise XOF.
String pawapayOfferCurrency({
  required Iterable<String> countryAlpha2s,
  required Iterable<String> currencies,
}) =>
    isDrcPawapayMarket(
      countryAlpha2s: countryAlpha2s,
      currencies: currencies,
    )
        ? 'CDF'
        : 'XOF';

/// Collect country and currency hints from loaded chains.
String pawapayOfferCurrencyFromChains(Iterable<Chain> chains) {
  final countries = <String>[];
  final currencies = <String>[];
  for (final chain in chains) {
    if (chain.hasCurrency() && chain.currency.trim().isNotEmpty) {
      currencies.add(chain.currency);
    }
    for (final b in chain.boutiques) {
      final boutique = b.boutique;
      if (boutique.hasAddressFull() &&
          boutique.addressFull.hasCountry() &&
          boutique.addressFull.country.code2Letters.trim().isNotEmpty) {
        countries.add(boutique.addressFull.country.code2Letters);
      }
      if (boutique.hasCurrency() && boutique.currency.trim().isNotEmpty) {
        currencies.add(boutique.currency);
      }
    }
  }
  return pawapayOfferCurrency(
    countryAlpha2s: countries,
    currencies: currencies,
  );
}

/// Offer price for the billing UI: prefer local PawaPay list price, then catalog EUR.
///
/// Example (en, FCFA): `9 900 XOF / 14.00 EUR`
/// Example (fr, FCFA): `9 900 CFA / 14.00 EUR`
/// Example (en, DRC): `39 900 CDF / 14.00 EUR`
String formatBillingOfferPrice({
  required int amountCents,
  required String currency,
  required String productId,
  String languageCode = 'en',
  String pawapayCurrency = 'XOF',
}) {
  final catalogCurrency =
      currency.trim().isNotEmpty ? currency.trim().toUpperCase() : 'EUR';
  final isFcfa =
      catalogCurrency == 'XOF' || catalogCurrency == 'XAF';
  final catalogAmount = isFcfa
      ? (amountCents / 100).round().toString()
      : (amountCents / 100).toStringAsFixed(2);
  final catalogCode = isFcfa
      ? _cfaDisplayCode(languageCode)
      : catalogCurrency;
  final catalogLabel = '$catalogAmount $catalogCode';

  final offerCurrency = pawapayCurrency.trim().toUpperCase().isEmpty
      ? 'XOF'
      : pawapayCurrency.trim().toUpperCase();
  final list = billingPawapayListPrice(productId, offerCurrency);
  if (list == null) return catalogLabel;
  final mobileLabel =
      '${_formatThousandsSpaces(list)} ${_mobileMoneyDisplayCode(offerCurrency, languageCode)}';
  if (isFcfa && (offerCurrency == 'XOF' || offerCurrency == 'XAF')) {
    return mobileLabel;
  }
  if (catalogCurrency == offerCurrency) return mobileLabel;
  return '$mobileLabel / $catalogLabel';
}

/// French UI uses CFA for XOF/XAF; CDF keeps its ISO code.
String _cfaDisplayCode(String languageCode) =>
    languageCode.toLowerCase().startsWith('fr') ? 'CFA' : 'XOF';

String _mobileMoneyDisplayCode(String currency, String languageCode) {
  if (currency == 'XOF' || currency == 'XAF') {
    return _cfaDisplayCode(languageCode);
  }
  return currency;
}

String _formatThousandsSpaces(int value) {
  final digits = value.abs().toString();
  final buf = StringBuffer();
  if (value < 0) buf.write('-');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('\u00A0');
    buf.write(digits[i]);
  }
  return buf.toString();
}
