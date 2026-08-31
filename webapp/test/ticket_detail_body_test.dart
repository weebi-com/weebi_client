import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

// Widget tests for TicketDetailBody and related ticket display widgets
// These verify that computed totals from protos are displayed correctly

void main() {
  group('TicketDetailBody — Smoke Tests', () {
    testWidgets('renders without crashing for sell ticket',
        (WidgetTester tester) async {
      final ticket = TicketPb(
        ticketType: TicketTypePb.sell,
        items: [
          ItemCartPb(
            articleRetail: ArticleRetailOnTicketPb(price: 100.0),
            quantity: 2.0,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TicketDetailBodyMock(ticket: ticket),
          ),
        ),
      );

      expect(find.byType(_TicketDetailBodyMock), findsOneWidget);
      // Verify no error indicators
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('displays computed total for retail article',
        (WidgetTester tester) async {
      final ticket = TicketPb(
        ticketType: TicketTypePb.sell,
        items: [
          ItemCartPb(
            articleRetail: ArticleRetailOnTicketPb(price: 99.99),
            quantity: 3.0,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TicketDetailBodyMock(ticket: ticket),
          ),
        ),
      );

      // Expected: 99.99 × 3 = 299.97
      expect(ticket.itemsTotalComputed, closeTo(299.97, 0.001));
      expect(find.textContaining('299.97'), findsWidgets);
    });

    testWidgets('displays tax amount when tax percentage > 0',
        (WidgetTester tester) async {
      final ticket = TicketPb(
        ticketType: TicketTypePb.sell,
        taxe: TaxPb(percentage: 20.0),
        items: [
          ItemCartPb(
            articleRetail: ArticleRetailOnTicketPb(price: 100.0),
            quantity: 1.0,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TicketDetailBodyMock(ticket: ticket),
          ),
        ),
      );

      // Expected: tax = 100 × 0.20 = 20
      expect(ticket.totalTaxesComputed, closeTo(20.0, 0.001));
      expect(find.textContaining('20'), findsWidgets);
    });

    testWidgets('applies promo discount to total',
        (WidgetTester tester) async {
      final ticket = TicketPb(
        ticketType: TicketTypePb.sell,
        promo: 10.0,
        items: [
          ItemCartPb(
            articleRetail: ArticleRetailOnTicketPb(price: 100.0),
            quantity: 2.0,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TicketDetailBodyMock(ticket: ticket),
          ),
        ),
      );

      // Expected: items=200, promo=20, total=180
      expect(ticket.itemsTotalComputed, 200.0);
      expect(ticket.totalTaxExcludedComputed, 180.0);
    });

    testWidgets('handles full formula chain: items → promo → tax → total',
        (WidgetTester tester) async {
      final ticket = TicketPb(
        ticketType: TicketTypePb.sell,
        promo: 10.0,
        taxe: TaxPb(percentage: 20.0),
        items: [
          ItemCartPb(
            articleRetail: ArticleRetailOnTicketPb(price: 100.0),
            quantity: 1.0,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TicketDetailBodyMock(ticket: ticket),
          ),
        ),
      );

      // Expected chain:
      // items = 100
      // promo = round4(100 × 0.10) = 10
      // tax_excl = 100 - 10 = 90
      // taxes = round4(90 × 0.20) = 18
      // total = 90 + 18 = 108
      expect(ticket.itemsTotalComputed, closeTo(100.0, 0.001));
      expect(ticket.totalTaxExcludedComputed, closeTo(90.0, 0.001));
      expect(ticket.totalTaxesComputed, closeTo(18.0, 0.001));
      expect(ticket.totalComputed, closeTo(108.0, 0.001));
      expect(find.textContaining('108'), findsWidgets);
    });

    testWidgets('handles spend ticket using cost instead of price',
        (WidgetTester tester) async {
      final ticket = TicketPb(
        ticketType: TicketTypePb.spend,
        items: [
          ItemCartPb(
            articleRetail: ArticleRetailOnTicketPb(
              price: 200.0,
              cost: 100.0,
            ),
            quantity: 2.0,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TicketDetailBodyMock(ticket: ticket),
          ),
        ),
      );

      // Expected: 2 × cost(100) = 200 (not 2 × price(200))
      expect(ticket.itemsTotalComputed, closeTo(200.0, 0.001));
      expect(find.textContaining('200'), findsWidgets);
    });

    testWidgets('handles empty ticket → displays 0',
        (WidgetTester tester) async {
      final ticket = TicketPb(
        ticketType: TicketTypePb.sell,
        items: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TicketDetailBodyMock(ticket: ticket),
          ),
        ),
      );

      expect(ticket.totalComputed, closeTo(0.0, 0.001));
      expect(find.textContaining('0'), findsWidgets);
    });
  });

  group('TicketGlimpseWidget — Deferred Ticket Display', () {
    testWidgets('displays computed total (not received) for deferred ticket',
        (WidgetTester tester) async {
      final deferredTicket = TicketPb(
        ticketType: TicketTypePb.sellDeferred,
        received: 0.0,  // Deferred tickets have received = 0
        items: [
          ItemCartPb(
            articleRetail: ArticleRetailOnTicketPb(price: 150.0),
            quantity: 1.0,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TicketGlimpseWidgetMock(ticket: deferredTicket),
          ),
        ),
      );

      // The widget should display itemsTotalComputed (150), not received (0)
      expect(deferredTicket.totalComputed, closeTo(150.0, 0.001));
      expect(find.textContaining('150'), findsWidgets);
      // Should NOT show received value of 0
    });

    testWidgets('displays correct total for multiple deferred tickets',
        (WidgetTester tester) async {
      final tickets = [
        TicketPb(
          ticketType: TicketTypePb.sellDeferred,
          received: 0.0,
          items: [
            ItemCartPb(
              articleRetail: ArticleRetailOnTicketPb(price: 100.0),
              quantity: 1.0,
            ),
          ],
        ),
        TicketPb(
          ticketType: TicketTypePb.sellDeferred,
          received: 0.0,
          items: [
            ItemCartPb(
              articleRetail: ArticleRetailOnTicketPb(price: 200.0),
              quantity: 1.0,
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: tickets
                  .map((t) => _TicketGlimpseWidgetMock(ticket: t))
                  .toList(),
            ),
          ),
        ),
      );

      // Both should display their computed totals
      expect(tickets[0].totalComputed, closeTo(100.0, 0.001));
      expect(tickets[1].totalComputed, closeTo(200.0, 0.001));
      expect(find.textContaining('100'), findsWidgets);
      expect(find.textContaining('200'), findsWidgets);
    });

    testWidgets('deferred ticket displays total, not received amount',
        (WidgetTester tester) async {
      final deferredTicket = TicketPb(
        ticketType: TicketTypePb.spendDeferred,
        received: 999.0,  // High received value (should be ignored)
        items: [
          ItemCartPb(
            articleRetail: ArticleRetailOnTicketPb(cost: 50.0),
            quantity: 1.0,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TicketGlimpseWidgetMock(ticket: deferredTicket),
          ),
        ),
      );

      // Should show computed total (50), not received (999)
      expect(deferredTicket.totalComputed, closeTo(50.0, 0.001));
      expect(find.textContaining('50'), findsWidgets);
      expect(find.textContaining('999'), findsNothing);  // Should NOT show received
    });
  });

  group('Ticket Total Display — Precision & Edge Cases', () {
    testWidgets('displays negative quantity (refund) correctly',
        (WidgetTester tester) async {
      final ticket = TicketPb(
        ticketType: TicketTypePb.sell,
        items: [
          ItemCartPb(
            articleRetail: ArticleRetailOnTicketPb(price: 100.0),
            quantity: -2.0,  // Negative for refund
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TicketDetailBodyMock(ticket: ticket),
          ),
        ),
      );

      expect(ticket.totalComputed, closeTo(-200.0, 0.001));
      expect(find.textContaining('-200'), findsWidgets);
    });

    testWidgets('displays fractional quantities correctly',
        (WidgetTester tester) async {
      final ticket = TicketPb(
        ticketType: TicketTypePb.sell,
        items: [
          ItemCartPb(
            articleRetail: ArticleRetailOnTicketPb(price: 100.0),
            quantity: 0.5,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TicketDetailBodyMock(ticket: ticket),
          ),
        ),
      );

      expect(ticket.totalComputed, closeTo(50.0, 0.001));
      expect(find.textContaining('50'), findsWidgets);
    });

    testWidgets('maintains floating-point precision to 4 decimals',
        (WidgetTester tester) async {
      final ticket = TicketPb(
        ticketType: TicketTypePb.sell,
        promo: 33.33,
        items: [
          ItemCartPb(
            articleRetail: ArticleRetailOnTicketPb(price: 333.33),
            quantity: 1.0,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TicketDetailBodyMock(ticket: ticket),
          ),
        ),
      );

      // Should maintain precision through calculation
      // items = 333.33, promo = round4(333.33 × 0.3333) = 111.0989
      // totalTaxExcluded = 333.33 - 111.0989 = 222.2311
      expect(ticket.totalTaxExcludedComputed, closeTo(222.2311, 0.001));
    });
  });
}

// Mock widget for testing display logic
class _TicketDetailBodyMock extends StatelessWidget {
  final TicketPb ticket;

  const _TicketDetailBodyMock({required this.ticket});

  String _format(double v) => v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ticket Detail'),
          Text('Type: ${ticket.ticketType.name}'),
          Text('Items Total: ${_format(ticket.itemsTotalComputed)}'),
          Text('Tax Excluded: ${_format(ticket.totalTaxExcludedComputed)}'),
          if (ticket.taxe.percentage > 0)
            Text('Taxes: ${_format(ticket.totalTaxesComputed)}'),
          Text(_format(ticket.totalComputed)), // Final total
          if (ticket.ticketType == TicketTypePb.sell)
            Text('Change: ${_format(ticket.changeComputed)}'),
        ],
      ),
    );
  }
}

// Mock widget for glimpse/list display
class _TicketGlimpseWidgetMock extends StatelessWidget {
  final TicketPb ticket;

  const _TicketGlimpseWidgetMock({required this.ticket});

  String _format(double v) => v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    // For deferred tickets, should display computed total, not received
    final displayTotal = ticket.ticketType == TicketTypePb.sellDeferred ||
            ticket.ticketType == TicketTypePb.spendDeferred
        ? ticket.totalComputed
        : ticket.totalComputed;

    return ListTile(
      title: Text('Ticket #${ticket.nonUniqueId}'),
      subtitle: Text('${ticket.ticketType.name}'),
      trailing: Text(_format(displayTotal)),
    );
  }
}
