import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:users_weebi/weebi_users.dart' show DynamicPermissionsAnalyzer, UserPermissionsExtension;

void main() {
  group('Dynamic Permissions Tests', () {
    test('should dynamically discover boolean rights', () {
      // Create a BoolRights object with some permissions set
      final boolRights = BoolRights()
        ..canSeeStats = true
        ..canExportData = false
        ..canGiveDiscount = true
        ..canSetPromo = false
        ..canStockMovement = true
        ..canStockInventory = false
        ..canSpendOutOfCatalog = true
        ..canPurchase = false
        ..canImportTickets = true
        ..canSellOutOfCatalog = false
        ..canUpdateContactBalanceOffline = true;

      // Test dynamic discovery
      final discoveredRights = DynamicPermissionsAnalyzer.getBoolRights(boolRights);
      
      // Verify that all boolean fields were discovered
      expect(discoveredRights['canSeeStats'], isTrue);
      expect(discoveredRights['canExportData'], isFalse);
      expect(discoveredRights['canGiveDiscount'], isTrue);
      expect(discoveredRights['canSetPromo'], isFalse);
      expect(discoveredRights['canStockMovement'], isTrue);
      expect(discoveredRights['canStockInventory'], isFalse);
      expect(discoveredRights['canSpendOutOfCatalog'], isTrue);
      expect(discoveredRights['canPurchase'], isFalse);
      expect(discoveredRights['canImportTickets'], isTrue);
      expect(discoveredRights['canSellOutOfCatalog'], isFalse);
      expect(discoveredRights['canUpdateContactBalanceOffline'], isTrue);
      
      // Verify we don't have internal fields
      expect(discoveredRights.containsKey('runtimeType'), isFalse);
      expect(discoveredRights.containsKey('hashCode'), isFalse);
      expect(discoveredRights.containsKey('toString'), isFalse);
    });

    test('should format field names correctly', () {
      expect(DynamicPermissionsAnalyzer.formatFieldName('canSeeStats'), 'Can See Stats');
      expect(DynamicPermissionsAnalyzer.formatFieldName('canExportData'), 'Can Export Data');
      expect(DynamicPermissionsAnalyzer.formatFieldName('canGiveDiscount'), 'Can Give Discount');
      expect(DynamicPermissionsAnalyzer.formatFieldName('canUpdateContactBalanceOffline'), 'Can Update Contact Balance Offline');
    });

    test('should generate correct boolRightsSummary', () {
      // Create UserPermissions with some boolean rights
      final permissions = UserPermissions()
        ..userId = 'test-user'
        ..firmId = 'test-firm'
        ..boolRights = (BoolRights()
          ..canSeeStats = true
          ..canExportData = false
          ..canGiveDiscount = true
          ..canStockMovement = true
          ..canImportTickets = true);

      final summary = permissions.boolRightsSummary;
      
      // Should contain the active rights
      expect(summary, contains('Special Rights:'));
      expect(summary, contains('Can See Stats'));
      expect(summary, contains('Can Give Discount'));
      expect(summary, contains('Can Stock Movement'));
      expect(summary, contains('Can Import Tickets'));
      
      // Should not contain inactive rights
      expect(summary, isNot(contains('Can Export Data')));
    });

    test('should generate full summary dynamically', () {
      // Create UserPermissions with various rights
      final permissions = UserPermissions()
        ..userId = 'test-user'
        ..firmId = 'test-firm'
        ..articleRights = (ArticleRights()..rights.addAll([Right.create, Right.read]))
        ..boutiqueRights = (BoutiqueRights()..rights.addAll([Right.read, Right.update]))
        ..boolRights = (BoolRights()
          ..canSeeStats = true
          ..canExportData = true
          ..canGiveDiscount = false);

      final summary = permissions.fullSummary;
      
      // Should contain all active permissions
      expect(summary, contains('Article Rights'));
      expect(summary, contains('Boutique Rights'));
      expect(summary, contains('Special Rights'));
      expect(summary, contains('Can See Stats'));
      expect(summary, contains('Can Export Data'));
      
      // Should not contain inactive permissions
      expect(summary, isNot(contains('Can Give Discount')));
    });

    test('should generate permissions map dynamically', () {
      // Create UserPermissions with various rights
      final permissions = UserPermissions()
        ..userId = 'test-user'
        ..firmId = 'test-firm'
        ..articleRights = (ArticleRights()..rights.addAll([Right.create, Right.read]))
        ..boolRights = (BoolRights()
          ..canSeeStats = true
          ..canExportData = false);

      final permissionsMap = permissions.permissionsMap;
      
      // Should contain all permission categories
      expect(permissionsMap.containsKey('Article Rights'), isTrue);
      expect(permissionsMap.containsKey('Special Rights'), isTrue);
      
      // Should contain correct boolean rights
      final specialRights = permissionsMap['Special Rights']!;
      expect(specialRights['canSeeStats'], isTrue);
      expect(specialRights['canExportData'], isFalse);
      
      // Should contain correct article rights
      final articleRights = permissionsMap['Article Rights']!;
      expect(articleRights['rights'], isTrue); // List is not empty
    });

    test('should handle empty permissions gracefully', () {
      final permissions = UserPermissions()
        ..userId = 'test-user'
        ..firmId = 'test-firm';

      expect(permissions.boolRightsSummary, isEmpty);
      expect(permissions.fullSummary, 'No permissions');
      expect(permissions.permissionsMap, isEmpty);
    });

    test('should handle permissions without boolRights', () {
      final permissions = UserPermissions()
        ..userId = 'test-user'
        ..firmId = 'test-firm'
        ..articleRights = (ArticleRights()..rights.addAll([Right.create]));

      expect(permissions.boolRightsSummary, isEmpty);
      expect(permissions.fullSummary, contains('Article Rights'));
    });
  });
}
