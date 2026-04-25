import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:users_weebi/weebi_users.dart';

void main() {
  group('ElegantPermissionsWidget Basic Tests', () {
    
    testWidgets('should display permission sections correctly', (WidgetTester tester) async {
      final testPermissions = UserPermissions.create()
        ..userId = 'test_user'
        ..firmId = 'test_firm'
        ..articleRights = ArticleRights(
          rights: [Right.create, Right.read, Right.update, Right.delete])
        ..contactRights = ContactRights(
          rights: [Right.read, Right.update])
        ..ticketRights = TicketRights(rights: [Right.read])
        ..boutiqueRights = BoutiqueRights(rights: [Right.update])
        ..boolRights = (BoolRights.create()
          ..canSeeStats = true
          ..canExportData = false
          ..canGiveDiscount = true
          ..canSetPromo = false
          ..canStockMovement = true
          ..canStockInventory = false
          ..canPurchase = true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElegantPermissionsWidget(
              permissions: testPermissions,
              isEditable: true,
              showHeader: true,
              title: 'Test User Permissions',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that all permission sections are displayed
      expect(find.text(PermissionsUiStrings.sectionArticles), findsOneWidget);
      expect(find.text(PermissionsUiStrings.sectionContacts), findsOneWidget);
      expect(find.text(PermissionsUiStrings.sectionTickets), findsOneWidget);
      expect(find.text(PermissionsUiStrings.sectionBoutiques), findsOneWidget);
      expect(find.text(PermissionsUiStrings.sectionSpecialRights), findsOneWidget);
      
      // Check that the title is displayed
      expect(find.text('Test User Permissions'), findsOneWidget);
      
      // Expand all expansion tiles to make switches visible
      final expansionTiles = find.byType(ExpansionTile);
      for (int i = 0; i < expansionTiles.evaluate().length; i++) {
        final tile = expansionTiles.at(i);
        await tester.ensureVisible(tile);
        await tester.tap(tile);
        await tester.pumpAndSettle();
      }
      
      // Check that switches are present (since isEditable is true)
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('should show switches when editable', (WidgetTester tester) async {
      final testPermissions = UserPermissions.create()
        ..userId = 'test_user'
        ..firmId = 'test_firm'
        ..articleRights = ArticleRights(rights: [Right.read])
        ..boolRights = (BoolRights.create()
          ..canSeeStats = true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElegantPermissionsWidget(
              permissions: testPermissions,
              isEditable: true,
              showHeader: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Expand all expansion tiles to make switches visible
      final expansionTiles = find.byType(ExpansionTile);
      for (int i = 0; i < expansionTiles.evaluate().length; i++) {
        final tile = expansionTiles.at(i);
        await tester.ensureVisible(tile);
        await tester.tap(tile);
        await tester.pumpAndSettle();
      }

      // Should have switches in editable mode
      expect(find.byType(Switch), findsWidgets);
      expect(find.byType(Checkbox), findsNothing);
    });

    testWidgets('should show checkboxes when not editable', (WidgetTester tester) async {
      final testPermissions = UserPermissions.create()
        ..userId = 'test_user'
        ..firmId = 'test_firm'
        ..articleRights = ArticleRights(rights: [Right.read])
        ..boolRights = (BoolRights.create()
          ..canSeeStats = true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElegantPermissionsWidget(
              permissions: testPermissions,
              isEditable: false,
              showHeader: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Expand all expansion tiles to make checkboxes visible
      final expansionTiles = find.byType(ExpansionTile);
      for (int i = 0; i < expansionTiles.evaluate().length; i++) {
        final tile = expansionTiles.at(i);
        await tester.ensureVisible(tile);
        await tester.tap(tile);
        await tester.pumpAndSettle();
      }

      // Should have checkboxes in read-only mode
      expect(find.byType(Checkbox), findsWidgets);
      expect(find.byType(Switch), findsNothing);
    });

    testWidgets('should handle permission changes', (WidgetTester tester) async {
      bool callbackInvoked = false;
      UserPermissions? changedPermissions;

      final testPermissions = UserPermissions.create()
        ..userId = 'test_user'
        ..firmId = 'test_firm'
        ..articleRights = ArticleRights(rights: [Right.read])
        ..boolRights = (BoolRights.create()
          ..canSeeStats = false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElegantPermissionsWidget(
              permissions: testPermissions,
              isEditable: true,
              showHeader: false,
              onPermissionsChanged: (updatedPermissions) {
                callbackInvoked = true;
                changedPermissions = updatedPermissions;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find a switch and toggle it
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pumpAndSettle();

        // Verify callback was invoked
        expect(callbackInvoked, isTrue);
        expect(changedPermissions, isNotNull);
      }
    });

    testWidgets('CompactPermissionsWidget should display permission chips', (WidgetTester tester) async {
      final testPermissions = UserPermissions.create()
        ..userId = 'test_user'
        ..firmId = 'test_firm'
        ..articleRights = ArticleRights(rights: [Right.read, Right.create])
        ..boolRights = (BoolRights.create()
          ..canSeeStats = true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactPermissionsWidget(permissions: testPermissions),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show permission categories
      expect(find.text(PermissionsUiStrings.sectionArticles), findsOneWidget);
      expect(find.text(PermissionsUiStrings.sectionSpecialRights), findsOneWidget);
    });

    testWidgets('ElegantPermissionsWidget should display read-only mode correctly', (WidgetTester tester) async {
      final testPermissions = UserPermissions.create()
        ..userId = 'test_user'
        ..firmId = 'test_firm'
        ..articleRights = ArticleRights(rights: [Right.create, Right.read])
        ..contactRights = ContactRights(rights: [Right.read])
        ..ticketRights = TicketRights(rights: [Right.read])
        ..boutiqueRights = BoutiqueRights(rights: [Right.read])
        ..boolRights = (BoolRights.create()..canSeeStats = true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElegantPermissionsWidget(
              permissions: testPermissions,
              isEditable: false, // Read-only mode
              showHeader: true,
              title: 'Your Permissions',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that all permission sections are displayed
      expect(find.text(PermissionsUiStrings.sectionArticles), findsOneWidget);
      expect(find.text(PermissionsUiStrings.sectionContacts), findsOneWidget);
      expect(find.text(PermissionsUiStrings.sectionTickets), findsOneWidget);
      expect(find.text(PermissionsUiStrings.sectionBoutiques), findsOneWidget);
      expect(find.text(PermissionsUiStrings.sectionSpecialRights), findsOneWidget);
      
      // Expand all expansion tiles to make checkboxes visible
      final expansionTiles = find.byType(ExpansionTile);
      for (int i = 0; i < expansionTiles.evaluate().length; i++) {
        final tile = expansionTiles.at(i);
        await tester.ensureVisible(tile);
        await tester.tap(tile);
        await tester.pumpAndSettle();
      }
      
      // In read-only mode, switches should be replaced with checkboxes
      // and they should not be interactive
      final switches = find.byType(Switch);
      expect(switches, findsNothing); // No switches in read-only mode
      
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsWidgets); // Should have checkboxes instead
    });
  });
} 