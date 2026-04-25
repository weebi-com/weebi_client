// Package imports:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Base interface for RPC endpoints
abstract class EndpointBase<T, R> {
  Future<T> request(R data);
}

/// Abstract class for upserting refresh tokens
abstract class UpsertRefreshTokenAbstractRpc
    implements EndpointBase<String, String> {
  const UpsertRefreshTokenAbstractRpc();

  @override
  Future<String> request(String data);
}

/// Concrete implementation for upserting refresh tokens using secure storage
class UpsertRefreshTokenRpc extends UpsertRefreshTokenAbstractRpc {
  final FlutterSecureStorage storage;
  const UpsertRefreshTokenRpc(this.storage);

  @override
  Future<String> request(String data) async {
    await storage.write(key: 'refresh', value: data);
    return data;
  }
}

/// Fake implementation for testing
class UpsertRefreshTokenFakeRpc extends UpsertRefreshTokenAbstractRpc {
  const UpsertRefreshTokenFakeRpc();

  @override
  Future<String> request(String data) async => data;
}

/// Abstract class for reading refresh tokens
abstract class ReadRefreshTokenAbstractRpc
    implements EndpointBase<String, void> {
  const ReadRefreshTokenAbstractRpc();

  @override
  Future<String> request(void data);
}

/// Concrete implementation for reading refresh tokens using secure storage
class ReadRefreshTokenRpc extends ReadRefreshTokenAbstractRpc {
  final FlutterSecureStorage storage;
  const ReadRefreshTokenRpc(this.storage);

  @override
  Future<String> request(void data) async =>
      await storage.read(key: 'refresh') ?? '';
}

/// Fake implementation for testing
class ReadRefreshTokenFakeRpc extends ReadRefreshTokenAbstractRpc {
  final String fake;
  const ReadRefreshTokenFakeRpc(this.fake);

  @override
  Future<String> request(void data) async => fake;
}

/// Abstract class for upserting access tokens
abstract class UpsertAccessTokenAbstractRpc
    implements EndpointBase<String, String> {
  const UpsertAccessTokenAbstractRpc();

  @override
  Future<String> request(String data);
}

/// Concrete implementation for upserting access tokens using secure storage
class UpsertAccessTokenRpc extends UpsertAccessTokenAbstractRpc {
  final FlutterSecureStorage storage;
  const UpsertAccessTokenRpc(this.storage);

  @override
  Future<String> request(String data) async {
    await storage.write(key: 'access', value: data);
    return data;
  }
}

/// Fake implementation for testing
class UpsertAccessTokenFakeRpc extends UpsertAccessTokenAbstractRpc {
  const UpsertAccessTokenFakeRpc();

  @override
  Future<String> request(String data) async => data;
}

/// Abstract class for reading access tokens
abstract class ReadAccessTokenAbstractRpc
    implements EndpointBase<String, void> {
  const ReadAccessTokenAbstractRpc();

  @override
  Future<String> request(void data);
}

/// Concrete implementation for reading access tokens using secure storage
class ReadAccessTokenRpc extends ReadAccessTokenAbstractRpc {
  final FlutterSecureStorage storage;
  const ReadAccessTokenRpc(this.storage);

  @override
  Future<String> request(void data) async =>
      await storage.read(key: 'access') ?? '';
}

/// Fake implementation for testing
class ReadAccessTokenFakeRpc extends ReadAccessTokenAbstractRpc {
  final String fake;
  const ReadAccessTokenFakeRpc(this.fake);

  @override
  Future<String> request(void data) async => fake;
}

/// Abstract auth service class (kept for backward compatibility)
abstract class AuthServiceAbstract {
  final UpsertRefreshTokenAbstractRpc upsertRefreshTokenRpc;
  final ReadRefreshTokenAbstractRpc readRefreshTokenRpc;
  final UpsertAccessTokenAbstractRpc upsertAccessTokenRpc;
  final ReadAccessTokenAbstractRpc readAccessTokenRpc;

  AuthServiceAbstract(
    this.upsertRefreshTokenRpc,
    this.readRefreshTokenRpc,
    this.upsertAccessTokenRpc,
    this.readAccessTokenRpc,
  );

  static const count = 4;
}

/// Concrete auth service implementation using secure storage
class AuthService extends AuthServiceAbstract {
  static const count = AuthServiceAbstract.count;

  AuthService(
    UpsertRefreshTokenRpc super.upsertRefreshTokenRpc,
    ReadRefreshTokenRpc super.readRefreshTokenRpc,
    UpsertAccessTokenRpc super.upsertAccessTokenRpc,
    ReadAccessTokenRpc super.readAccessTokenRpc,
  );
}

/// No-persistence auth service for testing
class AuthServiceNoPersistence implements AuthServiceAbstract {
  final String fakeRefresh;
  final String fakeAccess;

  const AuthServiceNoPersistence(this.fakeRefresh, this.fakeAccess);

  @override
  get upsertRefreshTokenRpc => const UpsertRefreshTokenFakeRpc();

  @override
  get readRefreshTokenRpc => ReadRefreshTokenFakeRpc(fakeRefresh);

  @override
  get readAccessTokenRpc => ReadAccessTokenFakeRpc(fakeAccess);

  @override
  get upsertAccessTokenRpc => const UpsertAccessTokenFakeRpc();
}
// This file intentionally left minimal. Previous SharedPreferences-backed
// RPC storage has been removed to keep the package lightweight and avoid
// persisting tokens via prefs. Token persistence is handled by
// PersistedTokenProvider using secure storage (or memory) directly.