# Accesses Weebi Package

A Flutter package for managing user access permissions to boutiques and chains in the Weebi ecosystem. This package provides a comprehensive interface for administrators to control which users have access to specific chains and boutiques.

## Features

- **User Access Management**: View and edit user permissions for boutiques and chains
- **Hierarchical Access Control**: Support for both full access and limited access models
- **Chain-Based Organization**: Manage access at the chain level with automatic boutique inclusion
- **Real-time Updates**: Live permission updates with provider-based state management
- **Beautiful UI**: Modern Material Design 3 interface with intuitive controls

## Architecture

The `accesses` package depends on both `users_weebi` and `boutiques_weebi` packages:

```
accesses_weebi
├── users_weebi (for user management)
├── boutiques_weebi (for boutique/chain data)
└── protos_weebi (for UserPermissions protobuf)
```

This separation ensures:
- `users_weebi`: Handles user CRUD operations
- `boutiques_weebi`: Handles boutique/chain CRUD operations  
- `accesses_weebi`: Manages user access permissions (depends on both)

## Core Components

### AccessProvider
Central state management for user access operations:
- Loads users and boutiques/chains
- Manages UserPermissions cache
- Handles permission updates
- Provides access validation methods

### AccessListWidget
Displays a searchable list of users for access management:
- Search functionality
- Current user identification
- **Access level indicators** - Shows at-a-glance whether users have full access, limited access, or no access
- Navigation to individual user access

### UserAccessWidget
Comprehensive interface for managing individual user access:
- Full access vs. limited access toggle
- Hierarchical chain/boutique selection
- Visual access summary
- Save/update permissions

## Usage

### Basic Integration

```dart
import 'package:accesses_weebi/accesses_weebi.dart';

// Add to your MaterialApp routes
MaterialApp(
  routes: {
    ...AccessRoutes.getProviderRoutes(
      getCurrentUserId: (context) => context.read<PermissionProvider>().userId,
    ),
  },
)

// Setup providers
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => BoutiqueProvider()),
    ChangeNotifierProxyProvider2<UserProvider, BoutiqueProvider, AccessProvider>(
      create: (context) => AccessProvider(
        userProvider: context.read<UserProvider>(),
        boutiqueProvider: context.read<BoutiqueProvider>(),
      ),
      update: (context, userProvider, boutiqueProvider, previous) =>
          previous ?? AccessProvider(
            userProvider: userProvider,
            boutiqueProvider: boutiqueProvider,
          ),
    ),
  ],
  child: YourApp(),
)
```

### Standalone Access Management

```dart
// Create a complete standalone access management app
AccessRoutes.createStandaloneAccessApp(
  currentUserId: 'admin-user-id',
  title: 'User Access Management',
)
```

### Navigation

```dart
// Navigate to access management list
AccessRoutes.navigateToAccessList(context);

// Navigate to specific user access
AccessRoutes.navigateToUserAccess(context, userObject);

// Show user access as modal
AccessRoutes.showUserAccessModal(context, userObject);
```

### Direct Widget Usage

```dart
// Access list widget
AccessListWidget(
  currentUserId: 'admin-user-id',
  onRefresh: () => print('Refreshed'),
)

// User access widget
UserAccessWidget(
  user: userObject,
)
```

## Permission Model

The package works with the `UserPermissions` protobuf model:

### Full Access
```dart
// User has access to all chains and boutiques
UserPermissions with AccessFull(hasFullAccess: true)
```

### Limited Access
```dart
// User has access to specific chains and boutiques
UserPermissions with AccessLimited(
  chainIds: ['chain1', 'chain2'],
  boutiqueIds: ['boutique1', 'boutique3']
)
```

## Key Features

### Hierarchical Selection
- Selecting a chain automatically selects all its boutiques
- Deselecting a boutique automatically deselects its parent chain
- Visual indicators show partial vs. full chain selection

### Access Summary
Real-time summary showing:
- Number of accessible chains
- Number of accessible boutiques  
- Access level (Full/Limited)

### Search & Filter
- Search users by name or email
- Real-time filtering
- Empty state handling

### Visual Access Indicators
The user list now displays compact access level indicators:
- **🟢 Full Access**: Green badge with checkmark icon
- **🟠 Limited Access**: Orange badge showing chain/boutique counts
- **🔴 No Access**: Red badge with block icon
- **⚪ Unknown**: Gray badge for loading/error states

### Error Handling
- Graceful error handling for network failures
- Retry mechanisms
- User-friendly error messages

## Example

See `example/access_example.dart` for complete implementation examples including:
- Standalone access management app
- Integrated access management
- Modal access management
- Provider setup patterns
