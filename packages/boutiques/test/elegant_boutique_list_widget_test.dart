import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:boutiques_weebi/src/providers/boutique_provider.dart';
import 'package:boutiques_weebi/src/widgets/boutique_list_widget.dart';

import 'package:boutiques_weebi/src/l10n/boutique_ui_strings.dart';
import 'elegant_boutique_list_widget_test.mocks.dart';

@GenerateMocks([BoutiqueProvider, FenceServiceClient])
void main() {
  group('BoutiqueListWidget Elegant Tests', () {
    late MockBoutiqueProvider mockProvider;
    //late MockFenceServiceClient mockClient;
    late UserPermissions fullPermissions;
    late UserPermissions readOnlyPermissions;
    late UserPermissions noPermissions;
    late List<Chain> testChains;
    late BoutiqueMongo testBoutique;
    late Chain testChain;

    setUp(() {
      mockProvider = MockBoutiqueProvider();
     // mockClient = MockFenceServiceClient();
      
      // Create test permissions
      fullPermissions = UserPermissions()
        ..userId = 'test_user'
        ..firmId = 'test_firm'
        ..boutiqueRights = (BoutiqueRights()
          ..rights.addAll([Right.create, Right.read, Right.update, Right.delete]))
        ..chainRights = (ChainRights()
          ..rights.addAll([Right.create, Right.read, Right.update, Right.delete]));

      readOnlyPermissions = UserPermissions()
        ..userId = 'test_user'
        ..firmId = 'test_firm'
        ..boutiqueRights = (BoutiqueRights()
          ..rights.add(Right.read))
        ..chainRights = (ChainRights()
          ..rights.add(Right.read));

      noPermissions = UserPermissions()
        ..userId = 'test_user'
        ..firmId = 'test_firm';

      // Create test data
      testBoutique = BoutiqueMongo()
        ..boutiqueId = 'boutique_1'
        ..chainId = 'chain_1'
        ..name = 'Test Boutique'
        ..boutique = (BoutiquePb()
          ..boutiqueId = 'boutique_1'
          ..name = 'Test Boutique'
          ..isDeleted = false
          ..addressFull = (Address()
            ..street = '123 Test St'
            ..city = 'Test City'
            ..code = '12345')
          ..phone = (Phone()
            ..number = '123-456-7890'));

      testChain = Chain()
        ..chainId = 'chain_1'
        ..name = 'Test Chain'
        ..boutiques.add(testBoutique);

      testChains = [testChain];

      // Setup default mock behavior
      when(mockProvider.chains).thenReturn(testChains);
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.error).thenReturn(null);
      when(mockProvider.selectedBoutique).thenReturn(null);
      when(mockProvider.selectedChain).thenReturn(null);
    });

    Widget createTestWidget({
      UserPermissions? permissions,
      Function(BoutiqueMongo)? onBoutiqueSelected,
      Function(Chain)? onChainSelected,
      Function(BoutiqueMongo)? onBoutiqueEdit,
      Function(Chain)? onChainEdit,
      Function(BoutiqueMongo)? onBoutiqueDelete,
      Function(Chain)? onChainDelete,
      Function(String?)? onCreateBoutique,
      VoidCallback? onCreateChain,
    }) {
      return ChangeNotifierProvider<BoutiqueProvider>.value(
        value: mockProvider,
        child: MaterialApp(
          home: Scaffold(
            body: BoutiqueListWidget(
              autoLoad: false,
              userPermissions: permissions,
              onBoutiqueSelected: onBoutiqueSelected,
              onChainSelected: onChainSelected,
              onBoutiqueEdit: onBoutiqueEdit,
              onChainEdit: onChainEdit,
              onBoutiqueDelete: onBoutiqueDelete,
              onChainDelete: onChainDelete,
              onCreateBoutique: onCreateBoutique,
              onCreateChain: onCreateChain,
            ),
          ),
        ),
      );
    }

    group('Permission-Based UI Tests', () {
      testWidgets('should show all CRUD buttons with full permissions', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(permissions: fullPermissions));
        await tester.pumpAndSettle();

        // Should show edit and delete buttons for boutique
        expect(find.byIcon(Icons.edit), findsAtLeastNWidgets(2)); // Chain + Boutique edit
        expect(find.byIcon(Icons.delete), findsAtLeastNWidgets(2)); // Chain + Boutique delete
        expect(find.byIcon(Icons.add_business), findsOneWidget); // Add boutique to chain
      });

      testWidgets('should hide CRUD buttons with read-only permissions', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(permissions: readOnlyPermissions));
        await tester.pumpAndSettle();

        // Should not show edit or delete buttons
        expect(find.byIcon(Icons.edit), findsNothing);
        expect(find.byIcon(Icons.delete), findsNothing);
        expect(find.byIcon(Icons.add_business), findsNothing);
      });

      testWidgets('should hide CRUD buttons with no permissions', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(permissions: noPermissions));
        await tester.pumpAndSettle();

        // Should not show any CRUD buttons
        expect(find.byIcon(Icons.edit), findsNothing);
        expect(find.byIcon(Icons.delete), findsNothing);
        expect(find.byIcon(Icons.add_business), findsNothing);
      });

      testWidgets('should show create FABs with create permissions', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          permissions: fullPermissions,
          onCreateBoutique: (_) {},
          onCreateChain: () {},
        ));
        await tester.pumpAndSettle();

        // Should show floating action buttons
        expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));
      });
    });

    group('Data Display Tests', () {
      testWidgets('should display chain and boutique information', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should display chain name
        expect(find.text('Test Chain'), findsOneWidget);
        
        // Should display boutique name
        expect(find.text('Test Boutique'), findsOneWidget);
        
        // Should display boutique address
        expect(find.text('123 Test St, Test City, 12345'), findsOneWidget);
        
        // Should display boutique phone
        expect(find.text('123-456-7890'), findsOneWidget);
        
        // Should display status
        expect(find.text('Active'), findsOneWidget);
      });

      testWidgets('should display empty state when no chains', (WidgetTester tester) async {
        when(mockProvider.chains).thenReturn([]);
        
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text(BoutiqueUiStrings.noChainsOrBoutiques), findsOneWidget);
        expect(find.byIcon(Icons.store), findsOneWidget);
      });

      testWidgets('should display loading state', (WidgetTester tester) async {
        when(mockProvider.isLoading).thenReturn(true);
        when(mockProvider.chains).thenReturn([]);
        
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should display error state', (WidgetTester tester) async {
        when(mockProvider.error).thenReturn('Test error message');
        
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text(BoutiqueUiStrings.errorPrefix('Test error message')), findsOneWidget);
        expect(find.text(BoutiqueUiStrings.retry), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);
      });
    });

    group('Search Functionality Tests', () {
      testWidgets('should display search bar', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text(BoutiqueUiStrings.searchHint), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('should filter results when searching', (WidgetTester tester) async {
        // Add another boutique for testing
        final anotherBoutique = BoutiqueMongo()
          ..boutiqueId = 'boutique_2'
          ..chainId = 'chain_1'
          ..name = 'Another Shop'
          ..boutique = (BoutiquePb()
            ..name = 'Another Shop'
            ..isDeleted = false);
        
        testChains.first.boutiques.add(anotherBoutique);
        
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Initially should see both boutiques
        expect(find.text('Test Boutique'), findsOneWidget);
        expect(find.text('Another Shop'), findsOneWidget);

        // Enter search text
        await tester.enterText(find.byType(TextField), 'Test');
        await tester.pumpAndSettle();

        // Should only see the filtered boutique
        expect(find.text('Test Boutique'), findsOneWidget);
        expect(find.text('Another Shop'), findsNothing);
      });
    });

    group('User Interaction Tests', () {
      testWidgets('should handle boutique selection', (WidgetTester tester) async {
        BoutiqueMongo? selectedBoutique;
        
        await tester.pumpWidget(createTestWidget(
          onBoutiqueSelected: (boutique) {
            selectedBoutique = boutique;
          },
        ));
        await tester.pumpAndSettle();

        // Tap on boutique item
        await tester.tap(find.text('Test Boutique'));
        await tester.pumpAndSettle();

        expect(selectedBoutique, isNotNull);
        expect(selectedBoutique!.name, equals('Test Boutique'));
      });

      testWidgets('should handle chain selection', (WidgetTester tester) async {
        Chain? selectedChain;
        
        await tester.pumpWidget(createTestWidget(
          onChainSelected: (chain) {
            selectedChain = chain;
          },
        ));
        await tester.pumpAndSettle();

        // Tap on chain header
        await tester.tap(find.text('Test Chain'));
        await tester.pumpAndSettle();

        expect(selectedChain, isNotNull);
        expect(selectedChain!.name, equals('Test Chain'));
      });

      // details dialog removed
    });

    group('CRUD Operations Tests', () {
      testWidgets('should trigger edit boutique dialog', (WidgetTester tester) async {
        // ignore: unused_local_variable
        BoutiqueMongo? editedBoutique;
        
        await tester.pumpWidget(createTestWidget(
          permissions: fullPermissions,
          onBoutiqueEdit: (boutique) {
            editedBoutique = boutique;
          },
        ));
        await tester.pumpAndSettle();

        // Find and tap edit button for boutique
        final editButtons = find.byIcon(Icons.edit);
        expect(editButtons, findsAtLeastNWidgets(1));
        
        // Tap the first edit button (should be boutique edit)
        await tester.tap(editButtons.last);
        await tester.pumpAndSettle();

        // Should show edit dialog
        expect(find.text(BoutiqueUiStrings.editBoutique), findsOneWidget);
      });

      testWidgets('should trigger edit chain dialog', (WidgetTester tester) async {
        // ignore: unused_local_variable
        Chain? editedChain;
        
        await tester.pumpWidget(createTestWidget(
          permissions: fullPermissions,
          onChainEdit: (chain) {
            editedChain = chain;
          },
        ));
        await tester.pumpAndSettle();

        // Find and tap edit button for chain
        final editButtons = find.byIcon(Icons.edit);
        expect(editButtons, findsAtLeastNWidgets(1));
        
        // Tap the first edit button (should be chain edit)
        await tester.tap(editButtons.first);
        await tester.pumpAndSettle();

        // Should show edit dialog
        expect(find.text(BoutiqueUiStrings.editChain), findsOneWidget);
      });

      testWidgets('should show delete confirmation for boutique', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          permissions: fullPermissions,
        ));
        await tester.pumpAndSettle();

        // Find and tap delete button for boutique
        final deleteButtons = find.byIcon(Icons.delete);
        expect(deleteButtons, findsAtLeastNWidgets(1));
        
        await tester.tap(deleteButtons.last);
        await tester.pumpAndSettle();

        // Should show confirmation dialog
        expect(find.text(BoutiqueUiStrings.deleteBoutiqueTitle), findsOneWidget);
        expect(find.text(BoutiqueUiStrings.deleteBoutiqueConfirm('Test Boutique')), findsOneWidget);
        expect(find.text(BoutiqueUiStrings.cancel), findsOneWidget);
        expect(find.text(BoutiqueUiStrings.deleteAction), findsOneWidget);
      });

      testWidgets('should show delete confirmation for chain', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          permissions: fullPermissions,
        ));
        await tester.pumpAndSettle();

        // Find and tap delete button for chain
        final deleteButtons = find.byIcon(Icons.delete);
        expect(deleteButtons, findsAtLeastNWidgets(1));
        
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();

        // Should show confirmation dialog with warning
        expect(find.text(BoutiqueUiStrings.deleteChainTitle), findsOneWidget);
        expect(find.text(BoutiqueUiStrings.deleteChainConfirm('Test Chain')), findsOneWidget);
        expect(find.text(BoutiqueUiStrings.warning), findsOneWidget);
        expect(find.text(BoutiqueUiStrings.deleteChainAndBoutiques), findsOneWidget);
      });

      testWidgets('should handle create boutique action', (WidgetTester tester) async {
        String? createBoutiqueChainId;
        
        await tester.pumpWidget(createTestWidget(
          permissions: fullPermissions,
          onCreateBoutique: (chainId) {
            createBoutiqueChainId = chainId;
          },
        ));
        await tester.pumpAndSettle();

        // Find and tap add boutique button
        await tester.tap(find.byIcon(Icons.add_business));
        await tester.pumpAndSettle();

        expect(createBoutiqueChainId, equals('chain_1'));
      });
    });

    group('Provider Integration Tests', () {
      testWidgets('should call provider methods on delete operations', (WidgetTester tester) async {
        when(mockProvider.deleteBoutique(any, any)).thenAnswer((_) async => true);
        when(mockProvider.deleteChain(any)).thenAnswer((_) async => true);
        
        await tester.pumpWidget(createTestWidget(
          permissions: fullPermissions,
        ));
        await tester.pumpAndSettle();

        // Test boutique deletion
        final deleteButtons = find.byIcon(Icons.delete);
        await tester.tap(deleteButtons.last);
        await tester.pumpAndSettle();
        
        // Confirm deletion
        await tester.tap(find.text(BoutiqueUiStrings.deleteAction));
        await tester.pumpAndSettle();

        // Verify provider method was called
        verify(mockProvider.deleteBoutique('chain_1', 'boutique_1')).called(1);
      });

      testWidgets('should handle provider errors gracefully', (WidgetTester tester) async {
        when(mockProvider.deleteBoutique(any, any)).thenAnswer((_) async => false);
        when(mockProvider.error).thenReturn('Delete failed');
        
        await tester.pumpWidget(createTestWidget(
          permissions: fullPermissions,
        ));
        await tester.pumpAndSettle();

        // Test boutique deletion
        final deleteButtons = find.byIcon(Icons.delete);
        await tester.tap(deleteButtons.last);
        await tester.pumpAndSettle();
        
        // Confirm deletion
        await tester.tap(find.text(BoutiqueUiStrings.deleteAction));
        await tester.pumpAndSettle();

        // Should show error message
        expect(find.text(BoutiqueUiStrings.errorPrefix('Delete failed')), findsOneWidget);
      });
    });

    group('Edge Cases Tests', () {
      testWidgets('should handle empty boutique list in chain', (WidgetTester tester) async {
        final emptyChain = Chain()
          ..chainId = 'empty_chain'
          ..name = 'Empty Chain';
        
        when(mockProvider.chains).thenReturn([emptyChain]);
        
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should show chain but no boutiques
        expect(find.text('Empty Chain'), findsOneWidget);
        expect(find.text('Test Boutique'), findsNothing);
      });

      testWidgets('should handle boutique with missing data', (WidgetTester tester) async {
        final incompleteBoutique = BoutiqueMongo()
          ..boutiqueId = 'incomplete'
          ..chainId = 'chain_1'
          ..name = 'Incomplete Boutique'
          ..boutique = (BoutiquePb()
            ..name = 'Incomplete Boutique'
            ..isDeleted = true);
        
        testChains.first.boutiques.clear();
        testChains.first.boutiques.add(incompleteBoutique);
        
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should display boutique with available data
        expect(find.text('Incomplete Boutique'), findsOneWidget);
        expect(find.text('Supprimée'), findsOneWidget);
      });
    });
  });
}
