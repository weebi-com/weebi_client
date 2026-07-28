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
