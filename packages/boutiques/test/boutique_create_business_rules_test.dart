import 'package:boutiques_weebi/src/l10n/boutique_ui_strings.dart';
import 'package:boutiques_weebi/src/providers/boutique_provider.dart';
import 'package:boutiques_weebi/src/widgets/boutique_create_view.dart';
import 'package:boutiques_weebi/src/widgets/boutique_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

import 'elegant_boutique_list_widget_test.mocks.dart';

void main() {
  group('BoutiqueCreateView business rules', () {
    late MockBoutiqueProvider provider;

    setUp(() {
      provider = MockBoutiqueProvider();
    });

    Widget buildCreateBoutiqueView() {
      return ChangeNotifierProvider<BoutiqueProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: BoutiqueCreateView.createBoutique(chainId: 'chain_1'),
        ),
      );
    }

    testWidgets(
      'defaults new boutique business rules from selected chain',
      (tester) async {
        final chain = Chain()
          ..chainId = 'chain_1'
          ..name = 'Réseau test'
          ..businessRules = (BusinessRules()
            ..isNegativeStockGuardEnabled = true
            ..isRecentTicketEditEnabled = true
            ..recentTicketEditWindowMinutes = 7);

        when(provider.chains).thenReturn([chain]);

        await tester.pumpWidget(buildCreateBoutiqueView());
        await tester.pump();

        final negativeStockSwitch = tester.widget<SwitchListTile>(
          find.byKey(const ValueKey('negative-stock-guard-switch')),
        );
        final recentTicketEditSwitch = tester.widget<SwitchListTile>(
          find.byKey(const ValueKey('recent-ticket-edit-switch')),
        );

        expect(negativeStockSwitch.value, isTrue);
        expect(recentTicketEditSwitch.value, isTrue);
        expect(
          find.widgetWithText(
            TextFormField,
            BoutiqueUiStrings.recentTicketEditWindowMinutesLabel,
          ),
          findsOneWidget,
        );
        expect(find.text('7'), findsOneWidget);
      },
    );

    testWidgets(
      'populates boutique edit business rules from current boutique',
      (tester) async {
        final boutique = BoutiqueMongo()
          ..chainId = 'chain_1'
          ..boutiqueId = 'boutique_1'
          ..boutique = (BoutiquePb()
            ..boutiqueId = 'boutique_1'
            ..name = 'Boutique test'
            ..addressFull = (Address()
              ..street = 'Rue test'
              ..city = 'Kinshasa'
              ..code = '123'
              ..country = (Country()
                ..code2Letters = 'CD'
                ..namel10n = 'Congo'))
            ..businessRules = (BusinessRules()
              ..isNegativeStockGuardEnabled = true
              ..isRecentTicketEditEnabled = true
              ..recentTicketEditWindowMinutes = 12));

        when(provider.chains).thenReturn([]);

        await tester.pumpWidget(
          ChangeNotifierProvider<BoutiqueProvider>.value(
            value: provider,
            child: MaterialApp(
              home: Scaffold(
                body: BoutiqueFormWidget(boutique: boutique),
              ),
            ),
          ),
        );

        final negativeStockSwitch = tester.widget<SwitchListTile>(
          find.byKey(const ValueKey('negative-stock-guard-switch')),
        );
        final recentTicketEditSwitch = tester.widget<SwitchListTile>(
          find.byKey(const ValueKey('recent-ticket-edit-switch')),
        );

        expect(negativeStockSwitch.value, isTrue);
        expect(recentTicketEditSwitch.value, isTrue);
        expect(
          find.widgetWithText(
            TextFormField,
            BoutiqueUiStrings.recentTicketEditWindowMinutesLabel,
          ),
          findsOneWidget,
        );
        expect(find.text('12'), findsOneWidget);
      },
    );
  });
}
