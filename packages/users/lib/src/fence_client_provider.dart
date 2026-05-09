import 'package:auth_weebi/auth_weebi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:protos_weebi/protos_weebi_io.dart' show FenceServiceClient;
import 'package:provider/provider.dart';
import 'package:users_weebi/src/providers/user_provider.dart';

/// Callback that creates a [FenceServiceClient] with the given access token.
/// The host app provides this so it can use its own channel (e.g. GrpcWebClientChannel for web).
typedef FenceServiceClientFactory = FenceServiceClient Function(
    String accessToken);

/// Provides a [FenceServiceClient] that is recreated when the access token changes.
/// Uses a factory so the host app can supply its own channel (grpc or grpc_web).
///
/// The host app owns [callOptions] and interceptors (e.g. [AuthInterceptor], log interceptor).
class FenceServiceClientProviderV2 extends ChangeNotifier {
  final FenceServiceClientFactory createClient;
  late FenceServiceClient _fenceServiceClient;

  FenceServiceClientProviderV2(this.createClient, String initialAccessToken)
      : _fenceServiceClient = createClient(initialAccessToken);

  FenceServiceClient get fenceServiceClient => _fenceServiceClient;

  void updateToken(String accessToken) {
    _fenceServiceClient = createClient(accessToken);
    notifyListeners();
  }
}

/// Demo/test helper: builds a provider tree with auth + fence + user providers.
/// The host app must supply [createFenceClient] (e.g. using GrpcWebClientChannel for web).
///
/// Prefer declaring [FenceServiceClientProviderV2] lower in your app's dependency tree
/// rather than using this helper in production.
MultiProvider initCrossRoutesTestV2(
  Widget home, {
  required FenceServiceClientFactory createFenceClient,
  required String initialAccessToken,
}) {
  final storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: false,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      useDataProtectionKeyChain: true,
    ),
  );
  return MultiProvider(
    providers: [
      Provider<AuthService>(
        create: (_) => AuthService(
          UpsertRefreshTokenRpc(storage),
          ReadRefreshTokenRpc(storage),
          UpsertAccessTokenRpc(storage),
          ReadAccessTokenRpc(storage),
        ),
      ),
      ProxyProvider<AuthService, PersistedTokenProvider>(
        update: (c, service, store) => store ?? PersistedTokenProvider(service),
      ),
      Provider<AccessTokenObject>(create: (_) => AccessTokenObject()),
      ChangeNotifierProxyProvider<AccessTokenObject, AccessTokenProvider>(
        create: (context) =>
            AccessTokenProvider(context.read<AccessTokenObject>()),
        update: (context, access, accessProvider) =>
            accessProvider!..accessToken = access.value,
      ),
      ChangeNotifierProxyProvider<AccessTokenProvider,
          FenceServiceClientProviderV2>(
        create: (context) => FenceServiceClientProviderV2(
          createFenceClient,
          initialAccessToken,
        ),
        update: (
          context,
          accessTokenProvider,
          provider,
        ) =>
            provider!..updateToken(accessTokenProvider.accessToken),
      ),
      ChangeNotifierProvider<UserProvider>(
        create: (context) => UserProvider(
          context.read<FenceServiceClientProviderV2>().fenceServiceClient,
        ),
      ),
    ],
    child: home,
  );
}
