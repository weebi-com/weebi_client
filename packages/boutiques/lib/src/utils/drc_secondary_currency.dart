import 'package:fl_country_code_picker_weebi/fl_country_code_picker.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

/// ISO 3166-1 alpha-2 for the Democratic Republic of the Congo.
const String kDrcCountryCodeAlpha2 = 'CD';

/// ISO 4217 code for Congolese Franc.
const String kCongoleseFrancIso4217 = 'CDF';

/// Default secondary display currency for the DRC use case.
const String kDefaultSecondaryDisplayCurrencyUsd = 'USD';

/// Keys aligned with proto JSON names for firm/chain, stored on [BoutiquePb.additionalAttributes].
const String kAttrDualCurrencyEnabled = 'dualCurrencyEnabled';
const String kAttrSecondaryDisplayCurrency = 'secondaryDisplayCurrency';

/// Web/admin default: allow secondary display currency for all boutiques.
bool shouldShowSecondaryCurrencyForBoutique({
  required CountryCode? addressCountry,
  required String billingCurrencyIso,
}) =>
    true;

/// PoS restriction: country is DRC or billing currency is CDF.
bool shouldShowSecondaryCurrencyForBoutiqueDrc({
  required CountryCode? addressCountry,
  required String billingCurrencyIso,
}) {
  final isDrc = addressCountry != null &&
      addressCountry.code.toUpperCase() == kDrcCountryCodeAlpha2;
  final isCdf = _normIso(billingCurrencyIso) == kCongoleseFrancIso4217;
  return isDrc || isCdf;
}

/// Chain forms have no address country; gate on billing currency only.
bool shouldShowSecondaryCurrencyForChain(String billingCurrencyIso) =>
    _normIso(billingCurrencyIso) == kCongoleseFrancIso4217;

String _normIso(String code) => code.trim().toUpperCase();

/// ISO 4217 used to decide if dual/secondary UI applies for a boutique when the
/// billing field is empty (inherit): use [existingNestedBoutique], then [parentChain].
String billingIsoForBoutiqueDualEligibility({
  required String billingFieldText,
  BoutiquePb? existingNestedBoutique,
  Chain? parentChain,
}) {
  final fromField = billingFieldText.trim();
  if (fromField.isNotEmpty) return fromField.toUpperCase();
  if (existingNestedBoutique != null &&
      existingNestedBoutique.hasCurrency() &&
      existingNestedBoutique.currency.trim().isNotEmpty) {
    return existingNestedBoutique.currency.trim().toUpperCase();
  }
  if (parentChain != null &&
      parentChain.hasCurrency() &&
      parentChain.currency.trim().isNotEmpty) {
    return parentChain.currency.trim().toUpperCase();
  }
  return '';
}

void applyDualCurrencyToChain(
  Chain chain, {
  required String billingCurrencyIso,
  required bool dualEnabled,
  required String secondaryTrimmedUpper,
}) {
  final eligible = shouldShowSecondaryCurrencyForChain(billingCurrencyIso);
  if (!eligible) {
    chain.isDualCurrencyEnabled = false;
    chain.clearSecondaryDisplayCurrency();
    return;
  }
  if (dualEnabled) {
    chain.isDualCurrencyEnabled = true;
    chain.secondaryDisplayCurrency = secondaryTrimmedUpper.isNotEmpty
        ? secondaryTrimmedUpper
        : kDefaultSecondaryDisplayCurrencyUsd;
  } else {
    chain.isDualCurrencyEnabled = false;
    chain.clearSecondaryDisplayCurrency();
  }
}

void applyDualCurrencyToChainRequest(
  ChainRequest request, {
  required String billingCurrencyIso,
  required bool dualEnabled,
  required String secondaryTrimmedUpper,
}) {
  final eligible = shouldShowSecondaryCurrencyForChain(billingCurrencyIso);
  if (!eligible) {
    request.isDualCurrencyEnabled = false;
    request.clearSecondaryDisplayCurrency();
    return;
  }
  if (dualEnabled) {
    request.isDualCurrencyEnabled = true;
    request.secondaryDisplayCurrency = secondaryTrimmedUpper.isNotEmpty
        ? secondaryTrimmedUpper
        : kDefaultSecondaryDisplayCurrencyUsd;
  } else {
    request.isDualCurrencyEnabled = false;
    request.clearSecondaryDisplayCurrency();
  }
}

void applyDualCurrencyToBoutiquePb(
  BoutiquePb boutique, {
  required bool eligible,
  required bool dualEnabled,
  required String secondaryTrimmedUpper,
}) {
  boutique.additionalAttributes.remove(kAttrDualCurrencyEnabled);
  boutique.additionalAttributes.remove(kAttrSecondaryDisplayCurrency);
  if (!eligible || !dualEnabled) {
    boutique.isDualCurrencyEnabled = false;
    boutique.clearSecondaryDisplayCurrency();
    return;
  }
  boutique.isDualCurrencyEnabled = true;
  boutique.secondaryDisplayCurrency = secondaryTrimmedUpper.isNotEmpty
      ? secondaryTrimmedUpper
      : kDefaultSecondaryDisplayCurrencyUsd;
}

/// Reads dual display settings from [BoutiquePb], preferring first-class fields with legacy [BoutiquePb.additionalAttributes] fallback.
({bool dualEnabled, String secondaryUpper}) readDualCurrencyFromBoutiquePb(
  BoutiquePb boutique,
) {
  final fromProtoDual =
      boutique.hasIsDualCurrencyEnabled() && boutique.isDualCurrencyEnabled;
  final attrs = boutique.additionalAttributes;
  final fromAttrDual = attrs[kAttrDualCurrencyEnabled] == 'true';
  final dualEnabled = fromProtoDual || fromAttrDual;

  var sec = '';
  if (boutique.hasSecondaryDisplayCurrency() &&
      boutique.secondaryDisplayCurrency.trim().isNotEmpty) {
    sec = boutique.secondaryDisplayCurrency.trim().toUpperCase();
  } else {
    sec = (attrs[kAttrSecondaryDisplayCurrency] ?? '').trim().toUpperCase();
  }

  return (dualEnabled: dualEnabled, secondaryUpper: sec);
}
