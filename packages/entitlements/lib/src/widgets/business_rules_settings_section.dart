import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

import '../business_rules_form.dart';
import '../l10n/business_rules_ui_strings.dart';

/// Lifetime-licence–gated business rules block for boutique/chain forms in the portal.
///
/// Host supplies [canEditBusinessRules] (e.g. via [SeatCapability.businessRulesEditable]).
/// See `docs/commercial-model.md`.
class BusinessRulesSettingsSection extends StatefulWidget {
  final bool canEditBusinessRules;

  const BusinessRulesSettingsSection({
    super.key,
    required this.canEditBusinessRules,
  });

  /// Read-only card for detail screens.
  static Widget readOnly({BusinessRules? rules}) {
    final r = rules ?? BusinessRules();
    return _BusinessRulesCard(
      canEdit: false,
      showLockedHint: false,
      negativeStockGuardEnabled: r.isNegativeStockGuardEnabled,
      recentTicketEditEnabled: r.isRecentTicketEditEnabled,
      recentTicketEditWindowMinutesText:
          r.recentTicketEditWindowMinutes > 0
              ? r.recentTicketEditWindowMinutes.toString()
              : '',
      onNegativeStockGuardChanged: null,
    );
  }

  @override
  State<BusinessRulesSettingsSection> createState() =>
      BusinessRulesSettingsSectionState();
}

class BusinessRulesSettingsSectionState
    extends State<BusinessRulesSettingsSection> {
  bool _negativeStockGuardEnabled = false;
  bool _recentTicketEditEnabled = false;
  final _recentTicketEditWindowMinutesController = TextEditingController();

  @override
  void dispose() {
    _recentTicketEditWindowMinutesController.dispose();
    super.dispose();
  }

  void applyRules(BusinessRules rules) {
    applyBusinessRulesToForm(
      rules: rules,
      setNegativeStockGuard: (v) => _negativeStockGuardEnabled = v,
      setRecentTicketEdit: (v) => _recentTicketEditEnabled = v,
      setWindowMinutesText: (t) =>
          _recentTicketEditWindowMinutesController.text = t,
    );
    if (_recentTicketEditEnabled &&
        _recentTicketEditWindowMinutesController.text.isEmpty) {
      _recentTicketEditWindowMinutesController.text = '5';
    }
    if (mounted) setState(() {});
  }

  BusinessRules buildRules() => buildBusinessRulesFromForm(
        negativeStockGuardEnabled: _negativeStockGuardEnabled,
        recentTicketEditEnabled: _recentTicketEditEnabled,
        recentTicketEditWindowMinutesText:
            _recentTicketEditWindowMinutesController.text,
      );

  @override
  Widget build(BuildContext context) {
    return _BusinessRulesCard(
      canEdit: widget.canEditBusinessRules,
      showLockedHint: !widget.canEditBusinessRules,
      negativeStockGuardEnabled: _negativeStockGuardEnabled,
      recentTicketEditEnabled: _recentTicketEditEnabled,
      recentTicketEditWindowMinutesText:
          _recentTicketEditWindowMinutesController.text,
      onNegativeStockGuardChanged: widget.canEditBusinessRules
          ? (value) => setState(() => _negativeStockGuardEnabled = value)
          : null,
      recentTicketEditWindowMinutesController:
          _recentTicketEditWindowMinutesController,
    );
  }
}

class _BusinessRulesCard extends StatelessWidget {
  final bool canEdit;
  final bool showLockedHint;
  final bool negativeStockGuardEnabled;
  final bool recentTicketEditEnabled;
  final String recentTicketEditWindowMinutesText;
  final ValueChanged<bool>? onNegativeStockGuardChanged;
  final TextEditingController? recentTicketEditWindowMinutesController;

  const _BusinessRulesCard({
    required this.canEdit,
    required this.showLockedHint,
    required this.negativeStockGuardEnabled,
    required this.recentTicketEditEnabled,
    required this.recentTicketEditWindowMinutesText,
    required this.onNegativeStockGuardChanged,
    this.recentTicketEditWindowMinutesController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              BusinessRulesUiStrings.sectionTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (showLockedHint) ...[
              const SizedBox(height: 8),
              Text(
                BusinessRulesUiStrings.lockedSubtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
            ],
            const SizedBox(height: 8),
            SwitchListTile(
              key: const ValueKey('negative-stock-guard-switch'),
              contentPadding: EdgeInsets.zero,
              title: const Text(BusinessRulesUiStrings.negativeStockGuardTitle),
              subtitle:
                  const Text(BusinessRulesUiStrings.negativeStockGuardSubtitle),
              value: negativeStockGuardEnabled,
              onChanged: canEdit ? onNegativeStockGuardChanged : null,
            ),
            if (recentTicketEditEnabled &&
                recentTicketEditWindowMinutesController != null) ...[
              const SizedBox(height: 8),
              TextFormField(
                key: const ValueKey('recent-ticket-edit-window-field'),
                controller: recentTicketEditWindowMinutesController,
                enabled: canEdit,
                decoration: const InputDecoration(
                  labelText:
                      BusinessRulesUiStrings.recentTicketEditWindowMinutesLabel,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.schedule),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (!recentTicketEditEnabled) return null;
                  final minutes = int.tryParse((value ?? '').trim());
                  if (minutes == null || minutes <= 0) {
                    return BusinessRulesUiStrings.recentTicketEditWindowInvalid;
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
