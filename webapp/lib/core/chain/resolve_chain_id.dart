import 'package:boutiques_weebi/boutiques_weebi.dart' show BoutiqueProvider;
import 'package:web_admin/core/money/money_formatting.dart';

Future<String?> resolveSelectedChainId(
  BoutiqueProvider boutiqueProvider, {
  String? firmIdFallback,
}) async {
  if (boutiqueProvider.chains.isEmpty) {
    await boutiqueProvider.loadChains();
  }
  final chains = boutiqueProvider.chains;
  if (chains.isNotEmpty) {
    return (boutiqueProvider.selectedChain ?? chains.first).chainId;
  }
  if (firmIdFallback != null && firmIdFallback.isNotEmpty) {
    return firmIdFallback;
  }
  return null;
}

/// ISO 4217 from the selected boutique, else the chain, else EUR.
String resolveSelectedCurrency(BoutiqueProvider boutiqueProvider) {
  final boutique = boutiqueProvider.selectedBoutique;
  if (boutique != null &&
      boutique.boutique.hasCurrency() &&
      boutique.boutique.currency.trim().isNotEmpty) {
    return boutique.boutique.currency.trim().toUpperCase();
  }
  final chain = boutiqueProvider.selectedChain ??
      (boutiqueProvider.chains.isEmpty ? null : boutiqueProvider.chains.first);
  if (chain != null &&
      chain.hasCurrency() &&
      chain.currency.trim().isNotEmpty) {
    return chain.currency.trim().toUpperCase();
  }
  return MoneyFormatting.fallbackIso;
}
