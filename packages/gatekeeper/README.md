# Gatekeeper 🛡️

**Session coordination and current user roles for Weebi client applications**

Gatekeeper handles the **current logged-in user**: their session, identity, and **roles/permissions derived from their JWT**. It is a client-side coordinator—not an access control authority.



## Key Features:
✅ Token management (`setTokens`, `clearAllTokens`, `restoreAllTokens`)
✅ Permission checks from JWT (offline-first)
✅ Device enrollment & identity
✅ User session caching
✅ Mail management
✅ Type-safe with generics
✅ Well-documented

## Gatekeeper depends on:
- `auth_weebi` (path: ../auth) - Token & permission utilities
- `models_weebi` ^1.1.16 - Data models
- `services_weebi` ^1.1.16 - Service abstractions
- `protos_weebi` ^1.0.16 - Protocol buffers


## How Gatekeeper Differs From Related Packages

| Package | Responsibility |
|---------|----------------|
| **gatekeeper** | Current user session, tokens, and **roles** (from JWT). Used to drive UI (e.g. `canCreateArticle`) and client behavior for the logged-in user. |
| **accesses_weebi** | Manages **user access permissions** to boutiques/chains (who can access what). Admin/CRUD of access rules, not the current session. |
| **Server** | The **real guardian**. Enforces access control. Client-side checks are for UX only; the server is the source of truth. |

---

Gatekeeper manages:
- Device enrollment and identity
- User session management
- Token coordination (access + refresh)
- **Current user roles and permissions** (from JWT tokens)
- Mail management

## Architecture

```
Gatekeeper Package
├── Gatekeeper - Main coordinator class
├── Gatekeeper - Abstract base class
├── DeviceManager - Device enrollment & identity
├── UserSession - User info cache
├── MailManager - User mail operations
└── Integrates with auth_weebi for token & permission handling
```

## Quick Start

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  gatekeeper_weebi:
    path: ../gatekeeper  # or version from registry
```

### Usage

```dart
import 'package:gatekeeper_weebi/gatekeeper_weebi.dart';
import 'package:auth_weebi/auth_weebi.dart';

// Create gatekeeper
final gatekeeper = Gatekeeper(
  deviceService,
  accessTokenProvider,
  persistedTokenProvider,
);

// Restore tokens on startup
await gatekeeper.restoreAllTokens();

// Login
await gatekeeper.setTokens(
  accessToken: response.accessToken,
  refreshToken: response.refreshToken,
);
gatekeeper.setUserInfo(response.user);

// Check permissions
if (gatekeeper.canCreateArticle) {
  // User can create articles
}

// Logout
await gatekeeper.clearSession();
```

## Documentation

See [GATEKEEPER_INTEGRATION_GUIDE.md](GATEKEEPER_INTEGRATION_GUIDE.md) for complete integration guide with:
- Multi Provider setup
- Login/logout flows
- Permission checks
- Token management
- API reference

## Benefits

### For Client Apps
- **Simple API**: Single class for all session management
- **Foolproof**: Can't forget to clear tokens
- **Offline-First**: Works consistently regardless of connectivity
- **Reactive**: Integrates with Provider/Riverpod patterns

### For Architecture
- **Separation of Concerns**: Infrastructure separate from app logic
- **Single Responsibility**: Each service has one job
- **Clean Dependencies**: Auth utilities → Gatekeeper → App logic
- **Reusable**: Use in multiple apps (POS, admin, web, etc.)

## Package Dependencies

- `auth_weebi` - Token storage and JWT parsing
- `models_weebi` - Data models
- `services_weebi` - Service abstractions
- `protos_weebi` - Protocol buffers

## License

Proprietary - Weebi SAS

## Support

For issues and questions, contact the Weebi team.
