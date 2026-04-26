import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:users_weebi/permissions.dart';

void main() {
  print('=== Dynamic Permissions Demo ===\n');
  
  // Create a UserPermissions object with various permissions
  final permissions = UserPermissions()
    ..userId = 'demo-user-123'
    ..firmId = 'demo-firm-456'
    ..articleRights = (ArticleRights()..rights.addAll([Right.create, Right.read, Right.update]))
    ..boutiqueRights = (BoutiqueRights()..rights.addAll([Right.read]))
    ..ticketRights = (TicketRights()..rights.addAll([Right.create, Right.read, Right.update, Right.delete]))
    ..boolRights = (BoolRights()
      ..canSeeStats = true
      ..canExportData = true
      ..canGiveDiscount = false
      ..canSetPromo = true
      ..canStockMovement = false
      ..canStockInventory = true
      ..canSpendOutOfCatalog = false
      ..canPurchase = true
      ..canImportTickets = false
      ..canSellOutOfCatalog = true
      ..canUpdateContactBalanceOffline = false);

  print('1. Boolean Rights Summary (Dynamic):');
  print('   ${permissions.boolRightsSummary}');
  print('');

  print('2. Full Summary (Dynamic):');
  print('   ${permissions.fullSummary}');
  print('');

  print('3. Permissions Map (Dynamic):');
  final permissionsMap = permissions.permissionsMap;
  for (final entry in permissionsMap.entries) {
    print('   ${entry.key}:');
    for (final right in entry.value.entries) {
      final status = right.value ? '✓' : '✗';
      print('     $status ${right.key}');
    }
    print('');
  }

  print('4. Adding a new boolean right (future addition):');
  print('   If we add a new field like "canManageUsers" to BoolRights protobuf,');
  print('   it will be automatically discovered at runtime!');
  print('   No code changes needed - completely dynamic discovery.');
  print('');

  print('5. Benefits of Dynamic Boolean Rights Discovery:');
  print('   ✓ Zero hardcoded field lists for boolean rights');
  print('   ✓ New boolean permissions auto-discovered at runtime');
  print('   ✓ Uses protobuf byIndex reflection');
  print('   ✓ Future-proof and maintainable');
}
