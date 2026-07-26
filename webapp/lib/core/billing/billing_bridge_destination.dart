/// Destination after App->Web magic-link exchange (premium + syscohada).
library;

import 'package:web_admin/views/screens/billing/billing_plan_label.dart';

const kWebBridgePremiumProductId = 'premium';

/// Query params from current URL. With hash routing, params may be in the
/// fragment (`#/billing?success=...` or `#/bridge?t=...`).
Map<String, String> billingQueryParamsFromLocation() {
  final base = Uri.base;
  final fragment = base.fragment;
  final qIndex = fragment.indexOf('?');
  if (qIndex >= 0) {
    return Uri.splitQueryString(fragment.substring(qIndex + 1));
  }
  return base.queryParameters;
}

class BillingBridgeDestination {
  const BillingBridgeDestination({
    required this.productId,
    this.fiscalYear,
  });

  final String productId;
  final int? fiscalYear;

  bool get isPremium => productId == kWebBridgePremiumProductId;
  bool get isSyscohada => isSyscohadaBillingProduct(productId);

  /// Hash route path used by go_router after successful exchange.
  String get billingLocation {
    final params = <String, String>{'product': productId};
    if (fiscalYear != null) {
      params['year'] = fiscalYear.toString();
    }
    final query = params.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return '/billing?$query';
  }
}

/// Parses bridge / billing deep-link query params.
///
/// Returns null when [token] is required and missing (bridge page), or when
/// product is unsupported.
BillingBridgeDestination? parseBillingBridgeDestination({
  required Map<String, String> query,
  bool requireToken = false,
}) {
  if (requireToken) {
    final token = query['t']?.trim() ?? '';
    if (token.isEmpty) return null;
  }

  final product = (query['product'] ?? '').trim().toLowerCase();
  if (product == kWebBridgePremiumProductId) {
    return const BillingBridgeDestination(productId: kWebBridgePremiumProductId);
  }
  if (isSyscohadaBillingProduct(product)) {
    final year = int.tryParse(query['year'] ?? '');
    if (year == null || year < 2000 || year > 2100) return null;
    return BillingBridgeDestination(
      productId: kSyscohadaProductId,
      fiscalYear: year,
    );
  }
  return null;
}

String? bridgeTokenFromQuery(Map<String, String> query) {
  final token = query['t']?.trim() ?? '';
  return token.isEmpty ? null : token;
}
