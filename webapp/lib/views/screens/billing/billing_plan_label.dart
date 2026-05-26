import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/generated/l10n.dart';

/// Catalog product IDs sold in the billing portal.
const billingCatalogProductIds = {'entreprise', 'premium'};

bool isBillingCatalogProduct(String productId) =>
    billingCatalogProductIds.contains(productId.toLowerCase());

bool isBillingCatalogLicense(License license) =>
    license.licensePlan == LicensePlan.ENTERPRISE ||
    license.licensePlan == LicensePlan.PREMIUM;

/// Display name for catalog / license plan (Entreprise and Premium only).
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
  if (productId != null && productId.isNotEmpty) return productId;
  return licensePlan?.name ?? '';
}
