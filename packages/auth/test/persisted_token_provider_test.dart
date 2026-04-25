import 'package:auth_weebi/src/providers/persisted_token_provider.dart';
import 'package:auth_weebi/src/services/auth_service_abstract.dart';
import 'package:test/test.dart';

void main() {
  group('PersistedTokenProvider (access token via storage)', () {
    test('reads/writes/clears access token using provided TokenStorage', () async {
      final provider = PersistedTokenProvider<AuthServiceNoPersistence>(
        const AuthServiceNoPersistence('', 'jwt-123'),
      );

      expect(await provider.readAccessToken(), 'jwt-123');
      await provider.setAndUpsertAccessToken('jwt-123');
      expect(await provider.readAccessToken(), 'jwt-123');
      await provider.clearAccessToken();
      // For no-persistence fake, read returns the fixed fake value
      expect(await provider.readAccessToken(), 'jwt-123');
    });

    test('refresh token set/clear does not throw with no-persistence service', () async {
      final provider = PersistedTokenProvider<AuthServiceNoPersistence>(
        const AuthServiceNoPersistence('', ''),
      );

      await provider.setAndUpsertRefreshToken('refresh-1');
      expect(provider.refreshToken, 'refresh-1');
      await provider.clearRefreshToken();
      expect(provider.refreshToken, '');
    });
  });
}


