import 'package:flutter/widgets.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

/// Optional host-provided sections and proto augmenters for boutique/chain forms.
///
/// Keeps licence-gated features (e.g. business rules) out of [boutiques_weebi];
/// the app shell supplies this from `entitlements_weebi` + webapp glue.
class BoutiqueFormExtensions {
  const BoutiqueFormExtensions({
    this.extraFormSections = const [],
    this.augmentChain,
    this.augmentChainRequest,
    this.augmentBoutique,
    this.onParentChainSelected,
    this.onFormReady,
  });

  /// Widgets inserted after currency / chain sections on create & edit forms.
  final List<Widget> extraFormSections;

  final void Function(Chain chain)? augmentChain;
  final void Function(ChainRequest request)? augmentChainRequest;
  final void Function(BoutiquePb boutique)? augmentBoutique;

  /// When the user picks a parent chain while creating a boutique.
  final void Function(Chain chain)? onParentChainSelected;

  /// Called once after the first frame so the host can seed extension state.
  final void Function({
    Chain? editingChain,
    BoutiqueMongo? editingBoutique,
    Chain? parentChain,
  })? onFormReady;
}

/// Builds [BoutiqueFormExtensions] for a specific form instance (e.g. webapp).
typedef BoutiqueFormExtensionsFactory = BoutiqueFormExtensions Function({
  Chain? editingChain,
  BoutiqueMongo? editingBoutique,
  Chain? parentChain,
});

/// Extra blocks on boutique/chain detail screens (e.g. read-only business rules).
typedef BoutiqueDetailExtrasFactory = List<Widget> Function({
  BoutiqueMongo? boutique,
  Chain? chain,
});
