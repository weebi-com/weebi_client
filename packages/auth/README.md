# auth_weebi

A shared authentication package for Weebi applications with JWT token management, persistence, and permissions.

Auth Package:
├── AuthTokenManager (NEW - orchestrates everything)
│   ├── clearAllTokens()
│   ├── setTokens()
│   └── restoreAllTokens()
├── PersistedTokenProvider (secure storage)
├── AccessTokenProvider (in-memory + parsing)
└── PermissionProvider (NEW - read-only permissions from token)

## Features

- **JWT Token Management**: Parse and validate JWT tokens with expiration checking
- **Token Persistence**: Abstract service layer for token storage and retrieval
- **Access Token Provider**: ChangeNotifier-based state management for access tokens
- **Permissions System**: Comprehensive permission checking for boolean and CRUD rights
- **gRPC Integration**: Auth interceptor for automatic JWT header injection
- **Flexible Architecture**: Abstract interfaces for easy testing and different storage backends

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  auth_weebi: ^1.0.0
```

## Usage

### Basic Setup with Provider

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_weebi/auth_weebi.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPrefs = await SharedPreferences.getInstance();
  
  runApp(MyApp(sharedPrefs: sharedPrefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPrefs;
  
  const MyApp({required this.sharedPrefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth service for token persistence
        Provider<AuthService>(
          create: (_) => AuthService(
            UpsertRefreshTokenRpc(sharedPrefs),
            ReadRefreshTokenRpc(sharedPrefs),
            UpsertAccessTokenRpc(sharedPrefs),
            ReadAccessTokenRpc(sharedPrefs),
          ),
        ),
        
        // Auth service backed by secure storage
        Provider<AuthService>(
          create: (_) => AuthService(
            UpsertRefreshTokenRpc(const FlutterSecureStorage()),
            ReadRefreshTokenRpc(const FlutterSecureStorage()),
            UpsertAccessTokenRpc(const FlutterSecureStorage()),
            ReadAccessTokenRpc(const FlutterSecureStorage()),
          ),
        ),
        // Persisted token provider using service
        ProxyProvider<AuthService, PersistedTokenProvider>(
          update: (c, service, store) => store ?? PersistedTokenProvider(service),
        ),
        
        // Access token object and provider
        Provider<AccessTokenObject>(create: (_) => AccessTokenObject()),
        ChangeNotifierProxyProvider<AccessTokenObject, AccessTokenProvider>(
          create: (context) => AccessTokenProvider(context.read<AccessTokenObject>()),
          update: (context, access, accessProvider) =>
              accessProvider!..accessToken = access.value,
        ),
      ],
      child: MaterialApp(
        home: MyHomePage(),
      ),
    );
  }
}
```

### Token Management

```dart
// Access the providers
final persistedTokenProvider = context.read<PersistedTokenProvider>();
final accessTokenProvider = context.read<AccessTokenProvider>();

// Read tokens from storage
final accessToken = await persistedTokenProvider.readAccessToken();
final refreshToken = await persistedTokenProvider.readAndSetRefreshToken();

// Set access token
accessTokenProvider.accessToken = accessToken;

// Check if token is expired
if (accessTokenProvider.isEmptyOrExpired) {
  // Handle token refresh
}

// Clear tokens
await persistedTokenProvider.clearAccessToken();
await persistedTokenProvider.clearRefreshToken();
```

### Permission Checking

```dart
// Using the permissions helper
final hasPermission = PermissionsHelper.hasPermission(
  accessToken, 
  'userManagement_create'
);

// Using the access token provider
final permissions = accessTokenProvider.permissions;
final canSeeStats = permissions.boolRights.canSeeStats;
```

### Convenience getters and token usability

```dart
// Quick token usability check for views/guards
if (accessTokenProvider.isUsable) {
  // Use extension getters on UserPermissions
  final p = accessTokenProvider.permissions;
  if (p.canReadArticle) {
    // show articles list
  }
  if (p.canCreateTicket) {
    // show create ticket button
  }
  if (p.canDeleteFirm) {
    // enable destructive firm action
  }
  // Boolean rights are also exposed
  final showStats = p.canSeeStats;
}
```

### Offline permissions with secure storage (optional)

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final persisted = context.read<PersistedTokenProvider>();
final enabled = await persisted.enableSecureAccessTokenStorage(
  const FlutterSecureStorage(),
);

// If enabled == true, access token will persist in secure storage; otherwise it stays in memory.

// Store refresh token in secure storage as well (more sensitive)
final refreshEnabled = await persisted.enableSecureRefreshTokenStorage(
  const FlutterSecureStorage(),
);
// If refreshEnabled == true, refresh token will be stored in secure storage; otherwise SharedPreferences is used.
```

Notes:
- Refresh token remains persisted in SharedPreferences.
- No migration required; users may need to re-login once after this change.

### gRPC Integration

```dart
import 'package:grpc/grpc.dart';
import 'package:auth_weebi/auth_weebi.dart';

// Create gRPC client with auth interceptor
final channel = ClientChannel('your-server.com', port: 443);
final client = YourServiceClient(
  channel,
  interceptors: [
    AuthInterceptor(accessToken),
  ],
);
```

### Testing with Fake Services

```dart
// Use the no-persistence service for testing
final authService = AuthServiceNoPersistence('fake-refresh', 'fake-access');
final provider = PersistedTokenProvider(authService);

// All operations will work with fake data
await provider.setAndUpsertAccessToken('test-token');
```

## Architecture

The package follows a clean architecture pattern:

- **Models**: Simple data classes for token management
- **Services**: Abstract interfaces for token persistence with concrete implementations
- **Providers**: State management using Provider pattern
- **Utils**: Helper functions for permission checking
- **Interceptors**: gRPC interceptors for authentication
- **Widgets**: UI components for permission display

## Dependencies

- `flutter`: UI framework
- `provider`: State management
- `protos_weebi`: Protobuf definitions for permissions
- `grpc`: gRPC communication
- `shared_preferences`: Token storage
- `collection`: Utility collections

## Testing

The package includes abstract interfaces that make testing easy:

```dart
// Create mock implementations for testing
class MockAuthService implements AuthServiceAbstract {
  // Implement mock behavior
}

// Use in tests
final mockService = MockAuthService();
final provider = PersistedTokenProvider(mockService);
```

## License

This package is proprietary to Weebi. 