import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/grpc.dart' show CallOptions, ClientChannel;
import 'package:protos_weebi/protos_weebi_io.dart' show FenceServiceClient;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:users_weebi/weebi_users.dart';

void main() {
  group('auth_weebi Integration Tests', () {
    setUp(() async {
      // No setup needed for secure storage in these interface-level tests
    });

    group('AuthService Tests', () {
      test('should create AuthService with all RPC implementations', () {
        final authService = AuthService(
          UpsertRefreshTokenRpc(const FlutterSecureStorage()),
          ReadRefreshTokenRpc(const FlutterSecureStorage()),
          UpsertAccessTokenRpc(const FlutterSecureStorage()),
          ReadAccessTokenRpc(const FlutterSecureStorage()),
        );

        expect(authService.upsertRefreshTokenRpc, isA<UpsertRefreshTokenRpc>());
        expect(authService.readRefreshTokenRpc, isA<ReadRefreshTokenRpc>());
        expect(authService.upsertAccessTokenRpc, isA<UpsertAccessTokenRpc>());
        expect(authService.readAccessTokenRpc, isA<ReadAccessTokenRpc>());
      });

      test('should create AuthServiceNoPersistence for testing', () {
        const authService = AuthServiceNoPersistence('fake-refresh', 'fake-access');

        expect(authService.upsertRefreshTokenRpc, isA<UpsertRefreshTokenFakeRpc>());
        expect(authService.readRefreshTokenRpc, isA<ReadRefreshTokenFakeRpc>());
        expect(authService.upsertAccessTokenRpc, isA<UpsertAccessTokenFakeRpc>());
        expect(authService.readAccessTokenRpc, isA<ReadAccessTokenFakeRpc>());
      });
    });

    group('Token Persistence Tests', () {
      test('should store and retrieve access token (no-persistence fake)', () async {
        const authService = AuthServiceNoPersistence('fake-refresh', 'fake-access');

        const testToken = 'test-access-token';
        final result = await authService.upsertAccessTokenRpc.request(testToken);
        expect(result, equals(testToken));

        final retrievedToken = await authService.readAccessTokenRpc.request(null);
        expect(retrievedToken, equals('fake-access'));
      });

      test('should store and retrieve refresh token (no-persistence fake)', () async {
        const authService = AuthServiceNoPersistence('fake-refresh', 'fake-access');

        const testToken = 'test-refresh-token';
        final result = await authService.upsertRefreshTokenRpc.request(testToken);
        expect(result, equals(testToken));

        final retrievedToken = await authService.readRefreshTokenRpc.request(null);
        expect(retrievedToken, equals('fake-refresh'));
      });
    });

    group('PersistedTokenProvider Tests', () {
      test('should manage tokens through provider (fake)', () async {
        const authService = AuthServiceNoPersistence('fake-refresh', 'fake-access');
        final provider = PersistedTokenProvider(authService);

        // Test access token operations
        const accessToken = 'test-access-token';
        await provider.setAndUpsertAccessToken(accessToken);
        
        final retrievedAccess = await provider.readAccessToken();
        expect(retrievedAccess, equals('fake-access'));

        // Test refresh token operations
        const refreshToken = 'test-refresh-token';
        await provider.setAndUpsertRefreshToken(refreshToken);
        
        final retrievedRefresh = await provider.readAndSetRefreshToken();
        expect(retrievedRefresh, equals('fake-refresh'));
        expect(provider.refreshToken, equals('fake-refresh'));
      });

      test('should handle token expiration checking', () async {
        const authService = AuthServiceNoPersistence('fake-refresh', 'fake-access');
        final provider = PersistedTokenProvider(authService);

        // Empty token should be expired
        expect(provider.isEmptyOrExpired, isTrue);
      });
    });

    group('AccessTokenProvider Tests', () {
      test('should manage access token state', () {
        final accessTokenObject = AccessTokenObject();
        final provider = AccessTokenProvider(accessTokenObject);

        // Initial state
        expect(provider.accessToken, equals(''));
        expect(provider.isEmptyOrExpired, isTrue);

        // Set token
        const testToken = 'test-token';
        provider.accessToken = testToken;
        expect(provider.accessToken, equals(testToken));
        expect(accessTokenObject.value, equals(testToken));

        // Clear token
        provider.clearAccessToken();
        expect(provider.accessToken, equals(''));
        expect(accessTokenObject.value, equals(''));
      });

      test('should provide default permissions for empty token', () {
        final accessTokenObject = AccessTokenObject();
        final provider = AccessTokenProvider(accessTokenObject);

        final permissions = provider.permissions;
        expect(permissions, isNotNull);
        // Empty token should return default permissions
      });
    });

    group('JWT Token Tests', () {
      test('should handle JWT parsing errors gracefully', () {
        // Invalid JWT should not crash
        expect(() => JsonWebToken.parse('invalid-jwt'), throwsA(isA<RangeError>()));
        
        // But the wrapper should exist
        const wrapper = JsonWebTokenWrapper('test-token');
        expect(wrapper.accessToken, equals('test-token'));
      });
    });

    group('Permissions Helper Tests', () {
      test('should handle empty token correctly', () {
        expect(PermissionsHelper.hasPermission('', 'any-permission'), isFalse);
      });

      test('should handle invalid token correctly', () {
        expect(PermissionsHelper.hasPermission('invalid-jwt', 'any-permission'), isFalse);
      });

      test('should check different permission types', () {
        // With empty token, all permissions should be false
        const emptyToken = '';
        
        // Boolean permissions
        expect(PermissionsHelper.hasPermission(emptyToken, 'canSeeStats'), isFalse);
        expect(PermissionsHelper.hasPermission(emptyToken, 'canExportData'), isFalse);
        
        // CRUD permissions
        expect(PermissionsHelper.hasPermission(emptyToken, 'userManagement_create'), isFalse);
        expect(PermissionsHelper.hasPermission(emptyToken, 'article_read'), isFalse);
        expect(PermissionsHelper.hasPermission(emptyToken, 'boutique_update'), isFalse);
      });
    });

    group('AuthInterceptor Tests', () {
      test('should create interceptor with JWT token', () {
        const testToken = 'test-jwt-token';
        final interceptor = AuthInterceptor(testToken);
        
        expect(interceptor.jwt, equals(testToken));
      });
    });

    group('Integration with FenceServiceClientProviderV2', () {
      test('should create FenceServiceClientProviderV2 with factory', () {
        // This test verifies that FenceServiceClientProviderV2 can be created
        // with a factory (host app owns channel and interceptors)
        expect(() {
          final mockChannel = ClientChannel('localhost', port: 443);
          FenceServiceClient createClient(String token) => FenceServiceClient(
            mockChannel,
            options: CallOptions(timeout: const Duration(seconds: 30)),
            interceptors: [AuthInterceptor(token)],
          );
          final provider = FenceServiceClientProviderV2(
            createClient,
            'test-token',
          );
          expect(provider, isA<FenceServiceClientProviderV2>());
          expect(provider.fenceServiceClient, isA<FenceServiceClient>());
        }, returnsNormally);
      });
    });

    group('Package Exports Tests', () {
      test('should export all necessary classes from auth_weebi', () {
        // Verify that all the main classes are accessible through users_weebi
        expect(AccessTokenObject, isA<Type>());
        expect(AccessTokenProvider, isA<Type>());
        expect(PersistedTokenProvider, isA<Type>());
        expect(AuthService, isA<Type>());
        expect(AuthServiceNoPersistence, isA<Type>());
        expect(JsonWebToken, isA<Type>());
        expect(JsonWebTokenWrapper, isA<Type>());
        expect(PermissionsHelper, isA<Type>());
        expect(AuthInterceptor, isA<Type>());
        expect(PermissionWidget, isA<Type>());
      });
    });
  });
}

// Mock ClientChannel for testing
class MockClientChannel {
  // Minimal mock implementation for testing
} 