// Flutter imports:
import 'package:auth_weebi/auth_weebi.dart';
import 'package:flutter/material.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Package imports:
import 'package:protos_weebi/protos_weebi_io.dart';

/// Example showing how to integrate auth_weebi with your existing app
class IntegrationExample extends StatelessWidget {
  const IntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = const FlutterSecureStorage( mOptions: MacOsOptions(
                    accessibility:
                        KeychainAccessibility.first_unlock_this_device,
                    useDataProtectionKeyChain: true,
                  ),);
    return MultiProvider(
      providers: [
        // 1. Auth service backed by secure storage
        Provider<AuthService>(
          create: (_) => AuthService(
            UpsertRefreshTokenRpc(storage),
            ReadRefreshTokenRpc(storage),
            UpsertAccessTokenRpc(storage),
            ReadAccessTokenRpc(storage),
          ),
        ),
        // 2. Persisted token provider using service
        ProxyProvider<AuthService, PersistedTokenProvider>(
          update: (c, service, store) => store ?? PersistedTokenProvider(service),
        ),
        
        // 3. Access token object and provider
        Provider<AccessTokenObject>(create: (_) => AccessTokenObject()),
        ChangeNotifierProxyProvider<AccessTokenObject, AccessTokenProvider>(
          create: (context) => AccessTokenProvider(context.read<AccessTokenObject>()),
          update: (context, access, accessProvider) =>
              accessProvider!..accessToken = access.value,
        ),
        
        // 4. Fence service client provider (updated to use auth_weebi)
        ChangeNotifierProxyProvider<AccessTokenProvider, FenceServiceClientProviderV2>(
          create: (BuildContext context) => FenceServiceClientProviderV2(
            _createChannel(),
            context.read<AccessTokenProvider>().accessToken,
          ),
          update: (
            BuildContext context,
            AccessTokenProvider accessTokenProvider,
            FenceServiceClientProviderV2? provider,
          ) =>
              provider!..updateToken(accessTokenProvider.accessToken),
        ),
        
        // 5. Your existing providers can remain the same
        // ChangeNotifierProvider<UserProvider>(...),
      ],
      child: MaterialApp(
        home: AuthExampleScreen(),
      ),
    );
  }

  ClientChannel _createChannel() {
    return ClientChannel(
      'dev.weebi.com',
      port: 443,
      options: const ChannelOptions(credentials: ChannelCredentials.secure()),
    );
  }
}

/// Updated FenceServiceClientProviderV2 using auth_weebi
class FenceServiceClientProviderV2 extends ChangeNotifier {
  final ClientChannel clientChannel;
  FenceServiceClient _fenceServiceClient;
  
  FenceServiceClientProviderV2(this.clientChannel, String accessToken)
      : _fenceServiceClient = FenceServiceClient(
          clientChannel,
          options: CallOptions(timeout: const Duration(seconds: 30)),
          interceptors: [
            AuthInterceptor(accessToken), // Using auth_weebi interceptor
          ],
        );
  
  FenceServiceClient get fenceServiceClient => _fenceServiceClient;

  void updateToken(String accessToken) {
    _fenceServiceClient = FenceServiceClient(
      clientChannel,
      options: CallOptions(timeout: const Duration(seconds: 30)),
      interceptors: [
        AuthInterceptor(accessToken), // Using auth_weebi interceptor
      ],
    );
    notifyListeners();
  }
}

/// Example screen showing auth functionality
class AuthExampleScreen extends StatefulWidget {
  @override
  _AuthExampleScreenState createState() => _AuthExampleScreenState();
}

class _AuthExampleScreenState extends State<AuthExampleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weebi Auth Example')),
      body: Consumer<AccessTokenProvider>(
        builder: (context, accessTokenProvider, child) {
          return Column(
            children: [
              // Token status
              Card(
                child: ListTile(
                  title: Text('Token Status'),
                  subtitle: Text(
                    accessTokenProvider.isEmptyOrExpired 
                        ? 'No valid token' 
                        : 'Token valid'
                  ),
                  trailing: accessTokenProvider.isEmptyOrExpired
                      ? Icon(Icons.error, color: Colors.red)
                      : Icon(Icons.check, color: Colors.green),
                ),
              ),
              
              // Permissions display
              if (!accessTokenProvider.isEmptyOrExpired) ...[
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Permissions'),
                        subtitle: Text('Current user permissions'),
                      ),
                      PermissionWidget(
                        icon: Icon(Icons.people),
                        permissionIcon: Icon(Icons.add),
                        permissionName: Text('Create Users'),
                        hasPermission: PermissionsHelper.hasPermission(
                          accessTokenProvider.accessToken,
                          'userManagement_create',
                        ),
                      ),
                      PermissionWidget(
                        icon: Icon(Icons.analytics),
                        permissionIcon: Icon(Icons.visibility),
                        permissionName: Text('View Statistics'),
                        hasPermission: PermissionsHelper.hasPermission(
                          accessTokenProvider.accessToken,
                          'canSeeStats',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Actions
              ElevatedButton(
                onPressed: () => _loadTokenFromStorage(context),
                child: Text('Load Token from Storage'),
              ),
              ElevatedButton(
                onPressed: () => _clearTokens(context),
                child: Text('Clear Tokens'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _loadTokenFromStorage(BuildContext context) async {
    final persistedTokenProvider = context.read<PersistedTokenProvider>();
    final accessTokenProvider = context.read<AccessTokenProvider>();
    
    try {
      final accessToken = await persistedTokenProvider.readAccessToken();
      if (accessToken.isNotEmpty) {
        accessTokenProvider.accessToken = accessToken;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token loaded successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No token found in storage')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading token: $e')),
      );
    }
  }

  Future<void> _clearTokens(BuildContext context) async {
    final persistedTokenProvider = context.read<PersistedTokenProvider>();
    final accessTokenProvider = context.read<AccessTokenProvider>();
    
    try {
      await persistedTokenProvider.clearAccessToken();
      await persistedTokenProvider.clearRefreshToken();
      accessTokenProvider.clearAccessToken();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tokens cleared successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing tokens: $e')),
      );
    }
  }
} 