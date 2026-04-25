import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/core/money/money_formatting.dart';

void main() {
  group('MoneyFormatting', () {
    test('formats primary amount only when no snapshot is present', () {
      final ticket = TicketPb.create();
      const locale = ui.Locale('fr', 'FR');

      const iso = 'XOF';
      const localAmount = 5600.0;

      final formatted = MoneyFormatting.formatTicketAmountLine(
        localAmount: localAmount,
        boutiqueIso4217: iso,
        ticket: ticket,
        locale: locale,
      );

      final expectedPrimary =
          MoneyFormatting.formatAmount(localAmount, iso, locale);
      expect(formatted, expectedPrimary);
    });

    test('uses localAmount / snapshotLocalPerSecondary conversion', () {
      final ticket = TicketPb.create()
        ..snapshotSecondaryCurrency = 'USD'
        ..snapshotLocalPerSecondary = 2800.0; // 1 USD = 2800 local

      const locale = ui.Locale('fr', 'FR');

      const iso = 'XOF';
      const localAmount = 5600.0;
      const rate = 2800.0;

      final formatted = MoneyFormatting.formatTicketAmountLine(
        localAmount: localAmount,
        boutiqueIso4217: iso,
        ticket: ticket,
        locale: locale,
      );

      final expectedPrimary =
          MoneyFormatting.formatAmount(localAmount, iso, locale);
      final expectedSecondary =
          '≈ ${MoneyFormatting.formatAmount(localAmount / rate, 'USD', locale)}';
      expect(formatted, '$expectedPrimary ($expectedSecondary)');
    });

    test('formatFxSnapshotCaption spells saved rate local per secondary', () {
      final ticket = TicketPb.create()
        ..snapshotSecondaryCurrency = 'USD'
        ..snapshotLocalPerSecondary = 2000.0;

      final caption = MoneyFormatting.formatFxSnapshotCaption(
        ticket: ticket,
        boutiqueIso4217: 'CDF',
        locale: const ui.Locale('en', 'US'),
      );

      expect(caption, '1 USD = 2,000 CDF');
    });

    test('formatFxSnapshotWorthPhrase: explicit worth in local currency', () {
      final ticket = TicketPb.create()
        ..snapshotSecondaryCurrency = 'USD'
        ..snapshotLocalPerSecondary = 2000.0;

      final phrase = MoneyFormatting.formatFxSnapshotWorthPhrase(
        ticket: ticket,
        boutiqueIso4217: 'CDF',
        locale: const ui.Locale('en', 'US'),
      );

      expect(phrase, '1 USD valait 2,000 CDF');
    });

    test('ticketHasFxSnapshot follows stored currency and rate', () {
      expect(MoneyFormatting.ticketHasFxSnapshot(TicketPb.create()), isFalse);
      final ticket = TicketPb.create()
        ..snapshotSecondaryCurrency = 'USD'
        ..snapshotLocalPerSecondary = 2800.0;
      expect(MoneyFormatting.ticketHasFxSnapshot(ticket), isTrue);
    });
  });
}

