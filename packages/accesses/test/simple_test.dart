import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:users_weebi/weebi_users.dart';
import 'package:boutiques_weebi/boutiques_weebi.dart';
import 'package:accesses_weebi/src/providers/access_provider.dart';

// Simple mock for testing
class MockFenceServiceClient implements FenceServiceClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Simple Access Tests', () {
    test('should create AccessProvider', () {
      // Arrange
      final userProvider = UserProvider(MockFenceServiceClient());
      final boutiqueProvider = BoutiqueProvider(MockFenceServiceClient());

      // Act
      final accessProvider = AccessProvider(
        userProvider: userProvider,
        boutiqueProvider: boutiqueProvider,
      );

      // Assert
      expect(accessProvider, isNotNull);
      expect(accessProvider.isLoading, false);
      expect(accessProvider.error, null);
    });

    test('should validate full access permissions', () {
      // Arrange
      final userProvider = UserProvider(MockFenceServiceClient());
      final boutiqueProvider = BoutiqueProvider(MockFenceServiceClient());
      final accessProvider = AccessProvider(
        userProvider: userProvider,
        boutiqueProvider: boutiqueProvider,
      );

      final permissions = UserPermissions.create();
      final fullAccess = AccessFull.create()..hasFullAccess = true;
      permissions.fullAccess = fullAccess;

      // Act & Assert
      expect(accessProvider.userHasChainAccess(permissions, 'any-chain'), true);
      expect(accessProvider.userHasBoutiqueAccess(permissions, 'any-boutique'), true);
    });

    test('should validate limited access permissions', () {
      // Arrange
      final userProvider = UserProvider(MockFenceServiceClient());
      final boutiqueProvider = BoutiqueProvider(MockFenceServiceClient());
      final accessProvider = AccessProvider(
        userProvider: userProvider,
        boutiqueProvider: boutiqueProvider,
      );

      final permissions = UserPermissions.create();
      final limitedAccess = AccessLimited.create();
      limitedAccess.chainIds = ChainIds.create()..ids.add('chain1');
      limitedAccess.boutiqueIds = BoutiqueIds.create()..ids.add('boutique1');
      permissions.limitedAccess = limitedAccess;

      // Act & Assert
      expect(accessProvider.userHasChainAccess(permissions, 'chain1'), true);
      expect(accessProvider.userHasChainAccess(permissions, 'chain2'), false);
      expect(accessProvider.userHasBoutiqueAccess(permissions, 'boutique1'), true);
      expect(accessProvider.userHasBoutiqueAccess(permissions, 'boutique2'), false);
    });

    test('should handle no access permissions', () {
      // Arrange
      final userProvider = UserProvider(MockFenceServiceClient());
      final boutiqueProvider = BoutiqueProvider(MockFenceServiceClient());
      final accessProvider = AccessProvider(
        userProvider: userProvider,
        boutiqueProvider: boutiqueProvider,
      );

      final permissions = UserPermissions.create();
      // No access set

      // Act & Assert
      expect(accessProvider.userHasChainAccess(permissions, 'any-chain'), false);
      expect(accessProvider.userHasBoutiqueAccess(permissions, 'any-boutique'), false);
    });

    test('should clear permissions cache', () {
      // Arrange
      final userProvider = UserProvider(MockFenceServiceClient());
      final boutiqueProvider = BoutiqueProvider(MockFenceServiceClient());
      final accessProvider = AccessProvider(
        userProvider: userProvider,
        boutiqueProvider: boutiqueProvider,
      );

      // Act
      accessProvider.clearUserPermissionsCache('user1');
      accessProvider.clearAllPermissionsCache();

      // Assert - Should not throw
      expect(accessProvider, isNotNull);
    });
  });
}
