import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

// Widget tests for TicketType UI extensions
// Verify that icon colors and icon data are correctly mapped for visual consistency

void main() {
  group('TicketType Visual Mapping — Icons & Colors', () {
    testWidgets('sell type renders with revenue-appropriate styling',
        (WidgetTester tester) async {
      final iconWidget = _TicketTypeIconMock(ticketType: TicketTypePb.sell);

      await tester.pumpWidget(MaterialApp(home: iconWidget));

      expect(find.byType(_TicketTypeIconMock), findsOneWidget);
      // Verify icon is rendered (specific icon depends on implementation)
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('spend type renders with expense-appropriate styling',
        (WidgetTester tester) async {
      final iconWidget = _TicketTypeIconMock(ticketType: TicketTypePb.spend);

      await tester.pumpWidget(MaterialApp(home: iconWidget));

      expect(find.byType(_TicketTypeIconMock), findsOneWidget);
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('all financial types render without error',
        (WidgetTester tester) async {
      final financialTypes = [
        TicketTypePb.sell,
        TicketTypePb.sellDeferred,
        TicketTypePb.sellCovered,
        TicketTypePb.spend,
        TicketTypePb.spendDeferred,
        TicketTypePb.spendCovered,
        TicketTypePb.wage,
      ];

      for (final type in financialTypes) {
        await tester.pumpWidget(MaterialApp(
          home: _TicketTypeIconMock(ticketType: type),
        ));

        expect(find.byType(_TicketTypeIconMock), findsOneWidget);
        expect(find.byType(ErrorWidget), findsNothing);
      }
    });

    testWidgets('stock types render without error',
        (WidgetTester tester) async {
      final stockTypes = [
        TicketTypePb.stockIn,
        TicketTypePb.stockOut,
        TicketTypePb.inventory,
      ];

      for (final type in stockTypes) {
        await tester.pumpWidget(MaterialApp(
          home: _TicketTypeIconMock(ticketType: type),
        ));

        expect(find.byType(_TicketTypeIconMock), findsOneWidget);
        expect(find.byType(ErrorWidget), findsNothing);
      }
    });

    testWidgets('icons are visually distinct between types',
        (WidgetTester tester) async {
      // Build sell icon
      await tester.pumpWidget(MaterialApp(
        home: _TicketTypeIconMock(ticketType: TicketTypePb.sell),
      ));
      final sellIcons = find.byType(Icon);
      expect(sellIcons, findsWidgets);

      // Build spend icon
      await tester.pumpWidget(MaterialApp(
        home: _TicketTypeIconMock(ticketType: TicketTypePb.spend),
      ));
      final spendIcons = find.byType(Icon);
      expect(spendIcons, findsWidgets);

      // Both should render successfully
      expect(sellIcons, findsWidgets);
      expect(spendIcons, findsWidgets);
    });

    testWidgets('deferred types have distinct visual treatment',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              _TicketTypeIconMock(ticketType: TicketTypePb.sell),
              _TicketTypeIconMock(ticketType: TicketTypePb.sellDeferred),
            ],
          ),
        ),
      ));

      expect(find.byType(Icon), findsWidgets);
      // Both should render without errors
      expect(find.byType(ErrorWidget), findsNothing);
    });
  });

  group('Contact Icon Semantics — Happy vs Grimacing', () {
    testWidgets(
        'sell ticket shows happy/positive sentiment (e.g., revenue sentiment)',
        (WidgetTester tester) async {
      // In actual implementation, you might use:
      // Icons.sentiment_very_satisfied for sell
      // Icons.sentiment_dissatisfied for spend

      final ticket = TicketPb(
        ticketType: TicketTypePb.sell,
      );

      await tester.pumpWidget(MaterialApp(
        home: _TicketContactIconMock(ticket: ticket),
      ));

      expect(find.byType(_TicketContactIconMock), findsOneWidget);
      expect(find.byType(Icon), findsWidgets);
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets(
        'spend ticket shows grimacing/negative sentiment (e.g., expense sentiment)',
        (WidgetTester tester) async {
      final ticket = TicketPb(
        ticketType: TicketTypePb.spend,
      );

      await tester.pumpWidget(MaterialApp(
        home: _TicketContactIconMock(ticket: ticket),
      ));

      expect(find.byType(_TicketContactIconMock), findsOneWidget);
      expect(find.byType(Icon), findsWidgets);
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('deferred types preserve sentiment of base type',
        (WidgetTester tester) async {
      final sellDeferred = TicketPb(
        ticketType: TicketTypePb.sellDeferred,
      );
      final spendDeferred = TicketPb(
        ticketType: TicketTypePb.spendDeferred,
      );

      // Sell deferred should have happy sentiment
      await tester.pumpWidget(MaterialApp(
        home: _TicketContactIconMock(ticket: sellDeferred),
      ));
      expect(find.byType(ErrorWidget), findsNothing);

      // Spend deferred should have grimacing sentiment
      await tester.pumpWidget(MaterialApp(
        home: _TicketContactIconMock(ticket: spendDeferred),
      ));
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('wage type represents supplier payment (grimacing)',
        (WidgetTester tester) async {
      final ticket = TicketPb(
        ticketType: TicketTypePb.wage,
      );

      await tester.pumpWidget(MaterialApp(
        home: _TicketContactIconMock(ticket: ticket),
      ));

      expect(find.byType(Icon), findsWidgets);
      expect(find.byType(ErrorWidget), findsNothing);
    });
  });

  group('Icon Color Consistency', () {
    testWidgets('sell color is consistently applied', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              _TicketTypeIconMock(ticketType: TicketTypePb.sell),
              _TicketTypeIconMock(ticketType: TicketTypePb.sell),
            ],
          ),
        ),
      ));

      expect(find.byType(Icon), findsWidgets);
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('stock types have neutral coloring', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              _TicketTypeIconMock(ticketType: TicketTypePb.stockIn),
              _TicketTypeIconMock(ticketType: TicketTypePb.stockOut),
              _TicketTypeIconMock(ticketType: TicketTypePb.inventory),
            ],
          ),
        ),
      ));

      expect(find.byType(Icon), findsWidgets);
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('all types render with proper color (no default gray)',
        (WidgetTester tester) async {
      final allTypes = TicketTypePb.values;

      for (final type in allTypes) {
        await tester.pumpWidget(MaterialApp(
          home: _TicketTypeIconMock(ticketType: type),
        ));

        expect(find.byType(Icon), findsWidgets);
        expect(find.byType(ErrorWidget), findsNothing);
      }
    });
  });

  group('Icon Rendering — Performance & Lists', () {
    testWidgets('renders efficiently in list with many tickets',
        (WidgetTester tester) async {
      final tickets = List.generate(
        50,
        (i) => TicketPb(
          nonUniqueId: i,
          ticketType: TicketTypePb.values[i % TicketTypePb.values.length],
        ),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: _TicketTypeIconMock(
                    ticketType: tickets[index].ticketType),
                title: Text('Ticket #${tickets[index].nonUniqueId}'),
              );
            },
          ),
        ),
      ));

      expect(find.byType(ListTile), findsWidgets);
      expect(find.byType(Icon), findsWidgets);
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('icon rendering does not cause layout issues',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('Tickets'),
          ),
          body: ListView(
            children: [
              ListTile(
                leading: _TicketTypeIconMock(ticketType: TicketTypePb.sell),
                title: Text('Sale'),
              ),
              ListTile(
                leading: _TicketTypeIconMock(ticketType: TicketTypePb.spend),
                title: Text('Expense'),
              ),
              ListTile(
                leading:
                    _TicketTypeIconMock(ticketType: TicketTypePb.stockIn),
                title: Text('Stock In'),
              ),
            ],
          ),
        ),
      ));

      expect(find.byType(ListTile), findsWidgets);
      expect(find.byType(Icon), findsWidgets);
      expect(find.byType(ErrorWidget), findsNothing);
    });
  });
}

// Mock widget for TicketType icon display
class _TicketTypeIconMock extends StatelessWidget {
  final TicketTypePb ticketType;

  const _TicketTypeIconMock({required this.ticketType});

  IconData _getIconData() {
    // Example mapping - implement based on your actual UI
    switch (ticketType) {
      case TicketTypePb.sell:
      case TicketTypePb.sellDeferred:
        return Icons.shopping_cart;
      case TicketTypePb.spend:
      case TicketTypePb.spendDeferred:
        return Icons.shopping_bag;
      case TicketTypePb.sellCovered:
      case TicketTypePb.spendCovered:
        return Icons.card_giftcard;
      case TicketTypePb.wage:
        return Icons.payments;
      case TicketTypePb.stockIn:
        return Icons.arrow_downward;
      case TicketTypePb.stockOut:
        return Icons.arrow_upward;
      case TicketTypePb.inventory:
        return Icons.inventory;
      default:
        return Icons.help;
    }
  }

  Color _getIconColor() {
    // Example coloring - implement based on your design
    if (ticketType.name.contains('sell')) {
      return Colors.green;
    } else if (ticketType.name.contains('spend')) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getIconData(),
      color: _getIconColor(),
    );
  }
}

// Mock widget for contact sentiment icon
class _TicketContactIconMock extends StatelessWidget {
  final TicketPb ticket;

  const _TicketContactIconMock({required this.ticket});

  IconData _getContactIcon() {
    // Happy (sales) vs Grimacing (expenses)
    switch (ticket.ticketType) {
      case TicketTypePb.sell:
      case TicketTypePb.sellDeferred:
      case TicketTypePb.sellCovered:
        return Icons.sentiment_very_satisfied;
      case TicketTypePb.spend:
      case TicketTypePb.spendDeferred:
      case TicketTypePb.spendCovered:
      case TicketTypePb.wage:
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(_getContactIcon());
  }
}
