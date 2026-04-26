import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:boutiques_weebi/boutiques_weebi.dart';

void main() {
  group('Boutiques Package Basic Tests', () {
    test('should export core classes correctly', () {
      // Test that main classes are accessible
      expect(BoutiqueMongo, isA<Type>());
      expect(Chain, isA<Type>());
      expect(BoutiquePb, isA<Type>());
    });

    test('should create basic boutique instance', () {
      final boutique = BoutiqueMongo()
        ..boutiqueId = 'test_id'
        ..name = 'Test Boutique'
        ..boutique = (BoutiquePb()
          ..name = 'Internal Name'
          ..currency = 'CDF');

      expect(boutique.boutiqueId, equals('test_id'));
      expect(boutique.name, equals('Test Boutique'));
      expect(boutique.boutique.name, equals('Internal Name'));
      expect(boutique.currencyCode, equals('CDF'));
      expect(boutique.detailsMap['Currency'], equals('CDF'));
    });

    test('should create basic chain instance', () {
      final chain = Chain()
        ..chainId = 'test_chain'
        ..name = 'Test Chain';

      expect(chain.chainId, equals('test_chain'));
      expect(chain.name, equals('Test Chain'));
      expect(chain.boutiques.length, equals(0));
    });

    test('should use extension methods correctly', () {
      final boutique = BoutiqueMongo()
        ..name = 'Display Name'
        ..boutique = (BoutiquePb()..name = 'Internal Name');

      // Test that extension method works
      expect(boutique.displayName, equals('Display Name'));
    });
  });
}
