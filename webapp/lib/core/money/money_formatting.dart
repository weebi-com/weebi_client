import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:protos_weebi/protos_weebi_io.dart' show TicketPb;

/// Locale-aware money display without the `money2` package.
class MoneyFormatting {
  static const String fallbackIso = 'EUR';

  static String formatAmount(double amount, String iso4217, Locale locale) {
    final code = iso4217.trim().toUpperCase();
    final safeCode = code.length == 3 ? code : fallbackIso;
    return NumberFormat.currency(
      locale: locale.toString(),
      name: safeCode,
    ).format(amount);
  }

  /// Single-line primary amount; optional parenthetical secondary from ticket FX snapshot.
  static String formatTicketAmountLine({
    required double localAmount,
    required String? boutiqueIso4217,
    required TicketPb ticket,
    required Locale locale,
  }) {
    final iso = (boutiqueIso4217 != null && boutiqueIso4217.trim().length == 3)
        ? boutiqueIso4217.trim().toUpperCase()
        : fallbackIso;
    final primary = formatAmount(localAmount, iso, locale);
    final secondary =
        _formatSecondaryApprox(localAmount, ticket, locale);
    if (secondary == null) return primary;
    return '$primary ($secondary)';
  }

  /// True when the ticket carries a usable FX snapshot (local per 1 unit of
  /// [snapshotSecondaryCurrency]). Prefers concrete values over proto `has*`
  /// so generated payloads still render if presence flags are missing.
  static bool ticketHasFxSnapshot(TicketPb ticket) {
    final rate = ticket.snapshotLocalPerSecondary;
    final sec = ticket.snapshotSecondaryCurrency.trim().toUpperCase();
    return sec.length == 3 && rate > 0 && rate <= 1e12;
  }

  static String? _formatSecondaryApprox(
    double localAmount,
    TicketPb ticket,
    Locale locale,
  ) {
    if (!ticketHasFxSnapshot(ticket)) return null;
    final rate = ticket.snapshotLocalPerSecondary;
    final sec = ticket.snapshotSecondaryCurrency.trim().toUpperCase();
    final converted = localAmount / rate;
    return '≈ ${formatAmount(converted, sec, locale)}';
  }

  static ({String sec, String local, String rateFormatted})?
      _fxSnapshotParts({
    required TicketPb ticket,
    required String? boutiqueIso4217,
    required Locale locale,
  }) {
    if (!ticketHasFxSnapshot(ticket)) return null;
    final rate = ticket.snapshotLocalPerSecondary;
    final sec = ticket.snapshotSecondaryCurrency.trim().toUpperCase();
    final local = (boutiqueIso4217 != null && boutiqueIso4217.trim().length == 3)
        ? boutiqueIso4217.trim().toUpperCase()
        : fallbackIso;
    final nf = NumberFormat.decimalPattern(locale.toString());
    if (rate == rate.roundToDouble()) {
      nf.maximumFractionDigits = 0;
    } else {
      nf.maximumFractionDigits = 4;
    }
    nf.minimumFractionDigits = 0;
    return (sec: sec, local: local, rateFormatted: nf.format(rate));
  }

  /// Rate captured at ticket creation: one unit of secondary currency equals
  /// this many units of boutique (local) currency — see ticket.proto.
  static String? formatFxSnapshotCaption({
    required TicketPb ticket,
    required String? boutiqueIso4217,
    required Locale locale,
  }) {
    final p = _fxSnapshotParts(
      ticket: ticket,
      boutiqueIso4217: boutiqueIso4217,
      locale: locale,
    );
    if (p == null) return null;
    return '1 ${p.sec} = ${p.rateFormatted} ${p.local}';
  }

  /// Wording for UI: what one unit of the snapshot foreign currency was worth
  /// in local (boutique) money at ticket time, e.g. `1 USD valait 2 000 CDF`.
  static String? formatFxSnapshotWorthPhrase({
    required TicketPb ticket,
    required String? boutiqueIso4217,
    required Locale locale,
  }) {
    final p = _fxSnapshotParts(
      ticket: ticket,
      boutiqueIso4217: boutiqueIso4217,
      locale: locale,
    );
    if (p == null) return null;
    return '1 ${p.sec} valait ${p.rateFormatted} ${p.local}';
  }
}
