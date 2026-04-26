import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:boutiques_weebi/boutique.dart';
import 'package:protos_weebi/fixnum.dart'; 

void main() {
  group('Boutique Extensions Elegant Tests', () {
    late BoutiqueMongo testBoutique;
    late Chain testChain;

    setUp(() {
      // Create comprehensive test data
      testBoutique = BoutiqueMongo()
        ..boutiqueId = 'boutique_1'
        ..chainId = 'chain_1'
        ..firmId = 'firm_1'
        ..name = 'Test Boutique Display Name'
        ..logo = [1, 2, 3, 4] // Some mock logo data
        ..logoExtension = 'png'
        ..creationTimestampUTC = (Timestamp()
          ..seconds = Int64(1640995200) // 2022-01-01
          ..nanos = 0)
        ..lastTouchTimestampUTC = (Timestamp()
          ..seconds = Int64(1640995200)
          ..nanos = 0)
        ..boutique = (BoutiquePb()
          ..boutiqueId = 'boutique_1'
          ..name = 'Test Boutique Internal Name'
          ..isDeleted = false
          ..addressFull = (Address()
            ..street = '123 Test Street'
            ..city = 'Test City'
            ..code = '12345')
          ..phone = (Phone()
            ..countryCode = 1
            ..number = '555-123-4567')
          ..promo = 10.0
          ..promoStart = '2022-01-01'
          ..promoEnd = '2022-12-31')
        ..devices.addAll([
          Device()
            ..deviceId = 'device_1'
            ..chainId = 'chain_1'
            ..boutiqueId = 'boutique_1'
            ..status = true
            ..hardwareInfo = (HardwareInfo()..name = 'Test Device'),
          Device()
            ..deviceId = 'device_2'
            ..chainId = 'chain_1'
            ..boutiqueId = 'boutique_1'
            ..status = true
            ..hardwareInfo = (HardwareInfo()..name = 'Another Device'),
        ]);

      testChain = Chain()
        ..chainId = 'chain_1'
        ..firmId = 'firm_1'
        ..name = 'Test Chain'
        ..creationDateUTC = (Timestamp()
          ..seconds = Int64(1640995200)
          ..nanos = 0)
        ..lastUpdateTimestampUTC = (Timestamp()
          ..seconds = Int64(1640995200)
          ..nanos = 0)
        ..lastUpdatedByuserId = 'user_1'
        ..boutiques.add(testBoutique);
    });

    group('BoutiqueMongoExtension Tests', () {
      test('should return correct display name', () {
        // When name is set, should use name
        expect(testBoutique.displayName, equals('Test Boutique Display Name'));
        
        // When name is empty, should fallback to boutique.name
        final boutiqueWithoutName = BoutiqueMongo()
          ..boutique = (BoutiquePb()..name = 'Internal Name');
        expect(boutiqueWithoutName.displayName, equals('Internal Name'));
        
        // When both are empty, should return empty string
        final emptyBoutique = BoutiqueMongo()..boutique = BoutiquePb();
        expect(emptyBoutique.displayName, equals(''));
      });

      test('should format creation date correctly', () {
        expect(testBoutique.formattedCreatedAt, equals('2022-01-01'));
        
        // Test boutique without creation date
        final boutiqueWithoutDate = BoutiqueMongo()..boutique = BoutiquePb();
        expect(boutiqueWithoutDate.formattedCreatedAt, equals(''));
      });

      test('should format last update date correctly', () {
        expect(testBoutique.formattedLastUpdate, equals('2022-01-01'));
        
        // Test boutique without last update date
        final boutiqueWithoutDate = BoutiqueMongo()..boutique = BoutiquePb();
        expect(boutiqueWithoutDate.formattedLastUpdate, equals(''));
      });


      test('should format address correctly', () {
        expect(testBoutique.formattedAddress, equals('123 Test Street, Test City, 12345'));
        
        // Test partial address
        final partialAddressBoutique = BoutiqueMongo()
          ..boutique = (BoutiquePb()
            ..addressFull = (Address()
              ..street = 'Main St'
              ..city = 'City'));
        expect(partialAddressBoutique.formattedAddress, equals('Main St, City'));
        
        // Test empty address
        final emptyAddressBoutique = BoutiqueMongo()
          ..boutique = (BoutiquePb()..addressFull = Address());
        expect(emptyAddressBoutique.formattedAddress, equals(''));
      });

      test('should format phone correctly', () {
        expect(testBoutique.formattedPhone, equals('+1 555-123-4567'));
        
        // Test boutique without phone
        final boutiqueWithoutPhone = BoutiqueMongo()
          ..boutique = (BoutiquePb()..phone = Phone());
        expect(boutiqueWithoutPhone.formattedPhone, equals(''));
      });

      test('should create correct details map', () {
        final details = testBoutique.detailsMap;
        
        expect(details['Name'], equals('Test Boutique Display Name'));
        expect(details['Status'], equals('Active'));
        expect(details['Address'], equals('123 Test Street, Test City, 12345'));
        expect(details['Phone'], equals('+1 555-123-4567'));
        expect(details['Created'], equals('2022-01-01'));
        expect(details['Last Update'], equals('2022-01-01'));
        expect(details['Device Count'], equals('2'));
      });

      test('should detect logo correctly', () {
        expect(testBoutique.hasLogo(), isTrue);
        
        // Test boutique without logo
        final boutiqueWithoutLogo = BoutiqueMongo()..boutique = BoutiquePb();
        expect(boutiqueWithoutLogo.hasLogo(), isFalse);
      });

      test('should maintain data integrity when accessing properties', () {
        // Test that accessing properties doesn't modify the original data
        final originalName = testBoutique.name;
        final displayName = testBoutique.displayName;
        final deviceCount = testBoutique.devices.length;
        
        expect(originalName, equals('Test Boutique Display Name'));
        expect(displayName, equals('Test Boutique Display Name'));
        expect(deviceCount, equals(2));
        
        // Accessing properties should not change the original
        expect(testBoutique.name, equals(originalName));
        expect(testBoutique.devices.length, equals(deviceCount));
      });
    });

    group('ChainExtension Tests', () {
      test('should return correct boutique count', () {
        expect(testChain.boutiqueCount, equals(1));
        
        // Test chain with multiple boutiques
        testChain.boutiques.add(BoutiqueMongo()
          ..boutiqueId = 'boutique_2'
          ..name = 'Second Boutique');
        expect(testChain.boutiqueCount, equals(2));
        
        // Test empty chain
        final emptyChain = Chain();
        expect(emptyChain.boutiqueCount, equals(0));
      });

      test('should format creation date correctly', () {
        expect(testChain.formattedCreatedAt, equals('2022-01-01'));
        
        // Test chain without creation date
        final chainWithoutDate = Chain();
        expect(chainWithoutDate.formattedCreatedAt, equals(''));
      });

      test('should format last update date correctly', () {
        expect(testChain.formattedLastUpdate, equals('2022-01-01'));
        
        // Test chain without last update date
        final chainWithoutDate = Chain();
        expect(chainWithoutDate.formattedLastUpdate, equals(''));
      });

      test('should return active boutiques only', () {
        // Add inactive boutique
        final inactiveBoutique = BoutiqueMongo()
          ..boutiqueId = 'inactive_boutique'
          ..boutique = (BoutiquePb()
            ..isDeleted = true
            ..name = 'Inactive Boutique');
        testChain.boutiques.add(inactiveBoutique);
        
        final activeBoutiques = testChain.activeBoutiques;
        expect(activeBoutiques.length, equals(1));
        expect(activeBoutiques.first.boutiqueId, equals('boutique_1'));
      });

      test('should return inactive boutiques only', () {
        // Add inactive boutique
        final inactiveBoutique = BoutiqueMongo()
          ..boutiqueId = 'inactive_boutique'
          ..boutique = (BoutiquePb()
            ..isDeleted = true
            ..name = 'Inactive Boutique');
        testChain.boutiques.add(inactiveBoutique);
        
        final inactiveBoutiques = testChain.deletedBoutiques;
        expect(inactiveBoutiques.length, equals(1));
        expect(inactiveBoutiques.first.boutiqueId, equals('inactive_boutique'));
      });

      test('should return correct summary', () {
        expect(testChain.summary, equals('Test Chain (1 boutiques)'));
        
        // Test with multiple boutiques
        testChain.boutiques.add(BoutiqueMongo()..boutiqueId = 'boutique_2');
        expect(testChain.summary, equals('Test Chain (2 boutiques)'));
      });

      test('should maintain data integrity when accessing properties', () {
        // Test that accessing properties doesn't modify the original data
        final originalName = testChain.name;
        final boutiqueCount = testChain.boutiqueCount;
        final summary = testChain.summary;
        
        expect(originalName, equals('Test Chain'));
        expect(boutiqueCount, equals(1));
        expect(summary, equals('Test Chain (1 boutiques)'));
        
        // Accessing properties should not change the original
        expect(testChain.name, equals(originalName));
        expect(testChain.boutiques.length, equals(boutiqueCount));
      });
    });

    group('Permission Helper Tests', () {
      late UserPermissions fullPermissions;
      late UserPermissions readOnlyPermissions;
      late UserPermissions noPermissions;

      setUp(() {
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
      });

      test('should detect boutique permissions correctly', () {
        // Full permissions
        expect(fullPermissions.hasBoutiqueRights(), isTrue);
        expect(fullPermissions.boutiqueRights.rights.contains(Right.create), isTrue);
        expect(fullPermissions.boutiqueRights.rights.contains(Right.read), isTrue);
        expect(fullPermissions.boutiqueRights.rights.contains(Right.update), isTrue);
        expect(fullPermissions.boutiqueRights.rights.contains(Right.delete), isTrue);

        // Read-only permissions
        expect(readOnlyPermissions.hasBoutiqueRights(), isTrue);
        expect(readOnlyPermissions.boutiqueRights.rights.contains(Right.read), isTrue);
        expect(readOnlyPermissions.boutiqueRights.rights.contains(Right.create), isFalse);

        // No permissions
        expect(noPermissions.hasBoutiqueRights(), isFalse);
      });

      test('should detect chain permissions correctly', () {
        // Full permissions
        expect(fullPermissions.hasChainRights(), isTrue);
        expect(fullPermissions.chainRights.rights.contains(Right.create), isTrue);
        expect(fullPermissions.chainRights.rights.contains(Right.read), isTrue);
        expect(fullPermissions.chainRights.rights.contains(Right.update), isTrue);
        expect(fullPermissions.chainRights.rights.contains(Right.delete), isTrue);

        // Read-only permissions
        expect(readOnlyPermissions.hasChainRights(), isTrue);
        expect(readOnlyPermissions.chainRights.rights.contains(Right.read), isTrue);
        expect(readOnlyPermissions.chainRights.rights.contains(Right.create), isFalse);

        // No permissions
        expect(noPermissions.hasChainRights(), isFalse);
      });
    });

    group('Edge Cases Tests', () {
      test('should handle null and empty values gracefully', () {
        final emptyBoutique = BoutiqueMongo()..boutique = BoutiquePb();
        
        expect(emptyBoutique.displayName, equals(''));
        expect(emptyBoutique.formattedCreatedAt, equals(''));
        expect(emptyBoutique.formattedLastUpdate, equals(''));
        expect(emptyBoutique.formattedAddress, equals(''));
        expect(emptyBoutique.formattedPhone, equals(''));
        expect(emptyBoutique.hasLogo(), isFalse);
        expect(emptyBoutique.devices.length, equals(0));
      });

      test('should handle partial data correctly', () {
        final partialBoutique = BoutiqueMongo()
          ..name = 'Partial Boutique'
          ..boutique = (BoutiquePb()
            ..isDeleted = false
            ..addressFull = (Address()..street = 'Incomplete Address'));
        
        expect(partialBoutique.displayName, equals('Partial Boutique'));
        
        expect(partialBoutique.formattedAddress, equals('Incomplete Address'));
        expect(partialBoutique.formattedPhone, equals(''));
      });

      test('should handle date edge cases', () {
        // Test with zero timestamp
        final boutiqueWithZeroDate = BoutiqueMongo()
          ..creationTimestampUTC = (Timestamp()
            ..seconds = Int64(0)
            ..nanos = 0)
          ..boutique = BoutiquePb();
        
        expect(boutiqueWithZeroDate.formattedCreatedAt, equals('1970-01-01'));
      });

      test('should handle large device counts', () {
        final boutiqueWithManyDevices = BoutiqueMongo()
          ..boutique = BoutiquePb();
        
        // Add 100 devices
        for (int i = 0; i < 100; i++) {
          boutiqueWithManyDevices.devices.add(
            Device()
              ..deviceId = 'device_$i'
              ..chainId = 'test_chain'
              ..boutiqueId = 'test_boutique'
          );
        }
        
        final details = boutiqueWithManyDevices.detailsMap;
        expect(details['Device Count'], equals('100'));
      });
    });

    group('Integration Tests', () {
      test('should work correctly with complex chain structure', () {
        final complexChain = Chain()
          ..chainId = 'complex_chain'
          ..name = 'Complex Chain';

        // Add multiple boutiques with different statuses
        for (int i = 0; i < 5; i++) {
          final boutique = BoutiqueMongo()
            ..boutiqueId = 'boutique_$i'
            ..name = 'Boutique $i'
            ..boutique = (BoutiquePb()
              ..isDeleted = i % 2 != 0 // Even indices active, odd inactive
              ..name = 'Internal Boutique $i');
          
          // Add varying number of devices
          for (int j = 0; j < i; j++) {
            boutique.devices.add(Device()
              ..deviceId = 'device_${i}_$j'
              ..chainId = 'complex_chain'
              ..boutiqueId = 'boutique_$i');
          }
          
          complexChain.boutiques.add(boutique);
        }

        expect(complexChain.boutiqueCount, equals(5));
        expect(complexChain.activeBoutiques.length, equals(3)); // 0, 2, 4
        expect(complexChain.deletedBoutiques.length, equals(2)); // 1, 3
        
        // Check device counts
        expect(complexChain.boutiques[0].devices.length, equals(0));
        expect(complexChain.boutiques[4].devices.length, equals(4));
      });

      test('should maintain data integrity through property access', () {
        final originalBoutique = testBoutique;
        
        // Access various properties multiple times
        final name1 = originalBoutique.displayName;
        final name2 = originalBoutique.displayName;
        final details1 = originalBoutique.detailsMap;
        final details2 = originalBoutique.detailsMap;
        
        // Properties should be consistent
        expect(name1, equals(name2));
        expect(details1['Name'], equals(details2['Name']));
        expect(details1['Device Count'], equals(details2['Device Count']));
        
        // Original should be unchanged
        expect(originalBoutique.name, equals('Test Boutique Display Name'));
        expect(originalBoutique.devices.length, equals(2));
      });
    });
  });
}
