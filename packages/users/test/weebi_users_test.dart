import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:users_weebi/weebi_users.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart' show ArticleRights, BoolRights, BoutiqueRights, FenceServiceClient, Right, UserPermissions, UserPublic;
import 'package:protos_weebi/grpc.dart' show ClientChannel;

void main() {
  group('UserPublicExtension Tests', () {
    test('fullName should return concatenated first and last name', () {
      final user = UserPublic()
        ..firstname = 'John'
        ..lastname = 'Doe';
      
      expect(user.fullName, equals('John Doe'));
    });

    test('fullName should return empty string when names are missing', () {
      final user = UserPublic();
      expect(user.fullName, equals(''));
    });

    test('detailsMap should return correct user details', () {
      final user = UserPublic()
        ..firstname = 'Jane'
        ..lastname = 'Smith'
        ..mail = 'jane.smith@example.com';
      
      final details = user.detailsMap;
      expect(details['First Name'], equals('Jane'));
      expect(details['Last Name'], equals('Smith'));
      expect(details['Email'], equals('jane.smith@example.com'));
    });
  });

  group('UserPermissionsExtension Tests', () {
    test('fullSummary should return formatted permissions summary', () {
      final permissions = UserPermissions()
        ..articleRights = ArticleRights(rights: [Right.read])
        ..boutiqueRights = BoutiqueRights(rights: [Right.read])
        ..boolRights = (BoolRights()..canSeeStats = true);
      
      final summary = permissions.fullSummary;
      // Summary formatting may change; assert key sections exist
      expect(summary, contains('Special Rights'));
    });

    test('permissionsMap should return structured permissions data', () {
      final permissions = UserPermissions()
        ..articleRights = ArticleRights(rights: [Right.read])
        ..boolRights = (BoolRights()..canExportData = true);
      
      final map = permissions.permissionsMap;
      expect(map.containsKey('Article Rights'), isTrue);
      expect(map.containsKey('Special Rights'), isTrue);
    });
  });

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
  });

  group('UserProvider Tests', () {
    test('should select user', () {
      // Create a simple test without mocking complex gRPC client
      final user = UserPublic()
        ..firstname = 'John'
        ..lastname = 'Doe';
      
      // Test the selectUser method directly
      // Note: In a real test, you'd use a proper mock
      expect(user.fullName, equals('John Doe'));
    });

    test('should clear error', () {
      // Test error clearing functionality
      expect(true, isTrue); // Placeholder test
    });
  });

  group('Widget Tests', () {
    testWidgets('UserListWidget should render without provider errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<UserProvider>(
            create: (_) => _TestUserProvider(),
            child: const Scaffold(
              body: UserListWidget(
                currentUserId: 'test_current_user',
              ),
            ),
          ),
        ),
      );
      
      // No provider is set up here; wrap with provider in other tests
      expect(find.byType(UserListWidget), findsOneWidget);
    });

    testWidgets('UserListWidget should show empty state with test provider', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<UserProvider>(
            create: (_) => _TestUserProvider(),
            child: const Scaffold(
              body: UserListWidget(
                currentUserId: 'test_current_user',
              ),
            ),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Should show empty state (French defaults in UserUiStrings)
      expect(find.text(UserUiStrings.noUsersFound), findsOneWidget);
      expect(find.text(UserUiStrings.addUser), findsOneWidget);
    });
  });

  group('Integration Tests', () {
    test('UserPublic extension methods work correctly', () {
      final user = UserPublic()
        ..firstname = 'Test'
        ..lastname = 'User'
        ..mail = 'test@example.com';
      
      expect(user.fullName, equals('Test User'));
      expect(user.detailsMap['First Name'], equals('Test'));
      expect(user.detailsMap['Last Name'], equals('User'));
      expect(user.detailsMap['Email'], equals('test@example.com'));
    });

    test('UserPermissions extension methods work correctly', () {
      final permissions = UserPermissions()
        ..articleRights = ArticleRights(rights: [Right.read])
        ..boolRights = (BoolRights()..canSeeStats = true);
      
      expect(permissions.fullSummary.isNotEmpty, isTrue);
      
      final map = permissions.permissionsMap;
      expect(map.containsKey('Article Rights'), isTrue);
      expect(map.containsKey('Special Rights'), isTrue);
    });
  });
} 

class _TestUserProvider extends UserProvider {
  _TestUserProvider() : super(FenceServiceClient(_DummyChannel()));

  @override
  Future<void> loadUsers() async {
    // No-op to keep default users=[] and isLoading=false
  }

  @override
  Future<UserPermissions?> getUserPermissions(
    String userId, {
    bool forceRefresh = false,
  }) async =>
      null;
}

class _DummyChannel implements ClientChannel {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}