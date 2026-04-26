// Project imports:
import '../models/jwt_token.dart';
import '../services/auth_service_abstract.dart';

/// Provider for managing persisted tokens using AuthService
class PersistedTokenProvider<A extends AuthServiceAbstract> {
  PersistedTokenProvider(this.authService);
  final A authService;
  String _refreshToken = '';
  
  String get refreshToken => _refreshToken;
  
  bool get isEmptyOrExpired => _refreshToken.isEmpty
      ? true
      : JsonWebToken.parse(_refreshToken).isTokenExpired;
  
  /// Set and persist refresh token
  Future<String> setAndUpsertRefreshToken(String val) async {
    _refreshToken = val;
    return await authService.upsertRefreshTokenRpc.request(val);
  }
  
  /// Set and persist access token
  Future<String> setAndUpsertAccessToken(String val) async {
    return await authService.upsertAccessTokenRpc.request(val);
  }

  /// Read access token from storage
  Future<String> readAccessToken() async {
    final temp = await authService.readAccessTokenRpc.request(null);
    return temp;
  }
  
  /// Read and set refresh token from storage
  Future<String> readAndSetRefreshToken() async {
    final temp = await authService.readRefreshTokenRpc.request(null);
    _refreshToken = temp;
    return temp;
  }

  /// Clear refresh token
  Future<String> clearRefreshToken() async {
    _refreshToken = '';
    return await authService.upsertRefreshTokenRpc.request('');
  }
  
  /// Clear access token
  Future<String> clearAccessToken() async {
    return await authService.upsertAccessTokenRpc.request('');
  }
} 