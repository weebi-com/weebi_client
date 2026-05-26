import 'package:protos_weebi/protos_weebi_io.dart';

/// Applies [rules] to form state used by create/edit screens.
void applyBusinessRulesToForm({
  required BusinessRules rules,
  required void Function(bool negativeStockGuard) setNegativeStockGuard,
  required void Function(bool recentTicketEdit) setRecentTicketEdit,
  required void Function(String windowMinutesText) setWindowMinutesText,
}) {
  setNegativeStockGuard(rules.isNegativeStockGuardEnabled);
  setRecentTicketEdit(rules.isRecentTicketEditEnabled);
  final minutes = rules.recentTicketEditWindowMinutes;
  setWindowMinutesText(minutes > 0 ? minutes.toString() : '');
}

BusinessRules buildBusinessRulesFromForm({
  required bool negativeStockGuardEnabled,
  required bool recentTicketEditEnabled,
  required String recentTicketEditWindowMinutesText,
}) {
  final minutes = int.tryParse(recentTicketEditWindowMinutesText.trim()) ?? 0;
  return BusinessRules()
    ..isNegativeStockGuardEnabled = negativeStockGuardEnabled
    ..isRecentTicketEditEnabled = recentTicketEditEnabled
    ..recentTicketEditWindowMinutes = minutes;
}
