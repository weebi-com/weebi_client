import 'package:auth_weebi/auth_weebi.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/values.dart';

/// [AuthServiceAbstract] using the same SharedPreferences keys as [UserDataProvider]
/// and `lib/core/services/auth_service.dart`, so `users_weebi` can use
/// [PersistedTokenProvider] without FlutterSecureStorage.
class SharedPrefsAuthService extends AuthServiceAbstract {
  SharedPrefsAuthService()
      : super(
          const _UpsertRefreshPrefsRpc(),
          const _ReadRefreshPrefsRpc(),
          const _UpsertAccessPrefsRpc(),
          const _ReadAccessPrefsRpc(),
        );
}

class _UpsertRefreshPrefsRpc extends UpsertRefreshTokenAbstractRpc {
  const _UpsertRefreshPrefsRpc();

  @override
  Future<String> request(String data) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(SharePrefKeys.refreshToken, data);
    return data;
  }
}

class _ReadRefreshPrefsRpc extends ReadRefreshTokenAbstractRpc {
  const _ReadRefreshPrefsRpc();

  @override
  Future<String> request(void data) async {
    final p = await SharedPreferences.getInstance();
    return p.getString(SharePrefKeys.refreshToken) ?? '';
  }
}

class _UpsertAccessPrefsRpc extends UpsertAccessTokenAbstractRpc {
  const _UpsertAccessPrefsRpc();

  @override
  Future<String> request(String data) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(SharePrefKeys.accessToken, data);
    return data;
  }
}

class _ReadAccessPrefsRpc extends ReadAccessTokenAbstractRpc {
  const _ReadAccessPrefsRpc();

  @override
  Future<String> request(void data) async {
    final p = await SharedPreferences.getInstance();
    return p.getString(SharePrefKeys.accessToken) ?? '';
  }
}
