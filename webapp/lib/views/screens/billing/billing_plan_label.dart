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

/// Marketing XOF list prices (aligned with PawaPay checkout amounts).
int? billingXofListPrice(String productId) {
  switch (productId.trim().toLowerCase()) {
    case kSyscohadaProductId:
      return 1900;
    case 'premium':
      return 9900;
    default:
      return null;
  }
}

/// Offer price for the billing UI: prefer XOF when known, then catalog EUR.
///
/// Example (en): `9 900 XOF / 14.00 EUR`
/// Example (fr): `9 900 CFA / 14.00 EUR`
String formatBillingOfferPrice({
  required int amountCents,
  required String currency,
  required String productId,
  String languageCode = 'en',
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

  final xof = billingXofListPrice(productId);
  if (xof == null) return catalogLabel;
  final xofLabel =
      '${_formatThousandsSpaces(xof)} ${_cfaDisplayCode(languageCode)}';
  if (isFcfa) return xofLabel;
  return '$xofLabel / $catalogLabel';
}

/// French UI uses CFA; ISO XOF stays for other languages.
String _cfaDisplayCode(String languageCode) =>
    languageCode.toLowerCase().startsWith('fr') ? 'CFA' : 'XOF';

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
