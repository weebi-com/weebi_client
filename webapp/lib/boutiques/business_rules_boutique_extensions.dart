import 'package:boutiques_weebi/boutiques_weebi.dart';
import 'package:entitlements_weebi/entitlements_weebi.dart';
import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

/// Wires [BusinessRulesSettingsSection] into boutique package forms and detail.
class BusinessRulesBoutiqueIntegration {
  BusinessRulesBoutiqueIntegration({required this.canEditBusinessRules});

  final bool canEditBusinessRules;

  static BusinessRules? _rulesFromChain(Chain chain) =>
      chain.hasBusinessRules() ? chain.businessRules : null;

  static BusinessRules? _rulesFromBoutique(BoutiqueMongo boutique) =>
      boutique.boutique.hasBusinessRules()
          ? boutique.boutique.businessRules
          : null;

  BoutiqueFormExtensions extensionsFor({
    Chain? editingChain,
    BoutiqueMongo? editingBoutique,
    Chain? parentChain,
  }) {
    final sectionKey = GlobalKey<BusinessRulesSettingsSectionState>();

    void applyRules(BusinessRules rules) {
      sectionKey.currentState?.applyRules(rules);
    }

    BusinessRules readRules() =>
        sectionKey.currentState?.buildRules() ?? BusinessRules();

    void scheduleSeed(void Function() seed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => seed());
    }

    return BoutiqueFormExtensions(
      extraFormSections: [
        BusinessRulesSettingsSection(
          key: sectionKey,
          canEditBusinessRules: canEditBusinessRules,
        ),
      ],
      augmentChain: canEditBusinessRules
          ? (chain) => chain.businessRules = readRules()
          : null,
      augmentChainRequest: canEditBusinessRules
          ? (request) => request.businessRules = readRules()
          : null,
      augmentBoutique: canEditBusinessRules
          ? (boutique) => boutique.businessRules = readRules()
          : null,
      onParentChainSelected: (chain) {
        applyRules(_rulesFromChain(chain) ?? BusinessRules());
      },
      onFormReady: ({
        Chain? editingChain,
        BoutiqueMongo? editingBoutique,
        Chain? parentChain,
      }) {
        scheduleSeed(() {
          if (editingChain != null) {
            applyRules(_rulesFromChain(editingChain) ?? BusinessRules());
          } else if (editingBoutique != null) {
            applyRules(
              _rulesFromBoutique(editingBoutique) ?? BusinessRules(),
            );
          } else if (parentChain != null) {
            applyRules(_rulesFromChain(parentChain) ?? BusinessRules());
          }
        });
      },
    );
  }

  List<Widget> detailExtras({
    BoutiqueMongo? boutique,
    Chain? chain,
  }) {
    final rules = chain != null
        ? _rulesFromChain(chain)
        : (boutique != null ? _rulesFromBoutique(boutique) : null);
    return [
      BusinessRulesSettingsSection.readOnly(rules: rules),
    ];
  }
}
