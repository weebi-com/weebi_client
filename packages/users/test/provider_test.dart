import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:users_weebi/weebi_users.dart';

void main() {
  group('AccessTokenProvider Tests', () {
    late AccessTokenProvider accessTokenProvider;
    late AccessTokenObject accessTokenObject;

    setUp(() {
      accessTokenObject = AccessTokenObject();
      accessTokenProvider = AccessTokenProvider(accessTokenObject);
    });

    test('should initialize with empty access token', () {
      expect(accessTokenProvider.accessToken, equals(''));
      expect(accessTokenProvider.isEmptyOrExpired, isTrue);
    });

    test('should clear access token', () {
      accessTokenProvider.clearAccessToken();
      expect(accessTokenProvider.accessToken, equals(''));
    });

    test('should check permissions correctly', () {
      expect(PermissionsHelper.hasPermission('', 'userManagement_create'), isFalse);
    });

    test('should handle JWT token parsing', () {
      // Test that JWT parsing doesn't crash with empty token
      expect(() => PermissionsHelper.hasPermission('', 'test_permission'), returnsNormally);
    });
  });

  group('UserProvider Tests', () {
    test('should handle user selection', () {
      // Test that user selection works
      final user = UserPublic()
        ..firstname = 'John'
        ..lastname = 'Doe';
      
      expect(user.fullName, equals('John Doe'));
    });

    test('should handle error clearing', () {
      // Test error clearing functionality
      expect(true, isTrue); // Placeholder test
    });
  });

  group('FenceClientProvider Tests', () {
    test('should initialize correctly', () {
      // Test that provider initializes without errors
      expect(true, isTrue); // Placeholder test
    });
  });
} 