# users_weebi

A comprehensive user management package for Weebi with protobuf mirroring capabilities and comprehensive UI components. Now uses the shared `auth_weebi` package for authentication.


The new `ElegantPermissionsWidget` provides a beautiful, inline permission editing experience with:

- **Inline Editing**: Toggle permissions directly without dialogs
- **Visual Feedback**: Color-coded sections and smooth animations
- **Organized Layout**: Grouped by permission types (Articles, Contacts, Tickets, etc.)
- **Flexible Usage**: Works both as a standalone widget or embedded component
- **Enhanced UX**: Switch between edit and view modes seamlessly

Perfect for admin panels and user management interfaces where you need to quickly update user permissions!

### 🔒 Security Feature: Hide Current User

The `UserListWidget` now supports hiding the current user from the list to prevent self-permission editing:

```dart
UserListWidget(
  currentUserId: cloudHub.userId, // Required: Hide current user from list
  showPermissions: true,
)
```

**Benefits:**
- ✅ Prevents users from editing their own permissions
- ✅ Maintains clean separation between user management and self-management
- ✅ Reduces UI complexity and potential security issues
- ✅ Perfect for mobile apps where self-permission editing isn't desired
- ✅ **Dual Protection**: Hides current user AND disables permission buttons as fallback

**How it works:**
1. **Primary Protection**: The `currentUserId` parameter is required and the current user is always filtered out of the list
2. **Fallback Protection**: If current user is somehow visible, their permission edit button is disabled with a helpful tooltip: "Cannot edit your own permissions"

### 🔄 **Provider-Based Routes**

For apps using static route maps where CloudHub is available after MaterialApp initialization:

```dart
// In your MaterialApp
MaterialApp(
  routes: {
    '/': (context) => const MainScreen(),
    ...UserRoutes.getProviderRoutes(
      getUserId: (context) => context.read<Gatekeeper>().userId, // Lazy evaluation!
    ),
  },
)

// The callback is called when the route is accessed, not when MaterialApp is created
// Perfect for when userId is only available after app initialization
```

### 📋 Enhanced User List Widget

The `UserListWidget` has been upgraded with powerful new capabilities:

- **Expandable User Details**: Each user card can expand to show detailed information
- **Inline Permission Previews**: See user permissions at a glance with compact chips
- **One-Click Permission Editing**: Security icon opens a beautiful modal editor
- **Color-Coded Avatars**: Automatic color assignment based on user ID
- **Modern Card Design**: Enhanced visual hierarchy with cards and better spacing
- **Flexible Configuration**: Toggle permission display and handle changes with callbacks

Experience the most intuitive user management interface yet!

### 🔧 Recent Fixes & Improvements

- **Fixed SnackBar Layout Conflicts**: Changed from floating to fixed behavior to prevent off-screen rendering issues
- **Dual Feedback System**: Immediate inline feedback in modal + delayed SnackBar confirmation  
- **Improved Service Integration**: Direct calls to `updateUserPermissions` with proper error handling
- **Enhanced User Display**: UserID now visible in each user card for easy identification
- **Simplified Interface**: Removed confusing expand functionality for cleaner UX

## 🔌 Simple User Permission Management

The `users_weebi` package provides clean, focused user permission management without duplicating your existing CloudHub logic.

### ✅ Key Benefits

- **Simple & Focused**: Only handles user permission fetching and updating
- **No Duplication**: Doesn't interfere with your existing CloudHub for device/session management
- **Caching**: Built-in permission caching for performance
- **Service Ready**: Clear integration points for your `FenceServiceClient`
- **Clean Architecture**: Separates user management from device/session concerns

### 🚀 Quick Setup

```dart
// Step 1: Create UserProvider with your FenceServiceClient
final userProvider = UserProvider(
  yourFenceServiceClient, // Your existing FenceServiceClient
);

// Step 2: Use in your UI

// Option A: Direct usage (when you have CloudHub instance)
UserListWidget(
  currentUserId: cloudHub.userId, // Required: Hide current user from list (prevents self-editing)
  showPermissions: true,
  onPermissionsChanged: (user, permissions) async {
    // Permissions are automatically updated via your service!
    print('✅ Updated permissions for ${user.firstname}');
  },
)

// Option B: Provider usage (with lazy evaluation)
UserRoutes.buildProviderUserList(
  getUserId: (context) => context.read<Gatekeeper>().userId,
)
```

### 🎯 How It Works

The `UserProvider` uses your **existing user operations**:

1. **Read user**: `fenceServiceClient.readOneUser()` - gets UserPublic with permissions
2. **Update user**: `fenceServiceClient.updateOneUser()` - saves UserPublic with updated permissions  
3. **Cache permissions** for performance
4. **Manage UI state** for permission widgets

**No new service methods needed!** It leverages your existing user CRUD operations.

### 🔧 Service Integration

✅ **Already works with your existing service:**

```dart
// ✅ Loading permissions (already implemented)
final userResponse = await fenceServiceClient.readOneUser(UserId()..userId = userId);
final permissions = userResponse.user.permissions; // UserPublic.permissions

// ✅ Updating permissions (already implemented)  
final user = userResponse.user;
final updatedUser = user..permissions = newPermissions;
await fenceServiceClient.updateOneUser(updatedUser); // Existing method!
```

**Requirements:**
- `UserPublic` proto must have a `permissions` field
- Your `readOneUser` and `updateOneUser` methods must work (they probably already do!)

That's it! No additional protobuf service methods needed.

### 🎨 User Creation View

The `UserCreateView` provides a beautiful, comprehensive user creation experience:

- **Modern Form Design**: Card-based layout with clear sections
- **Form Validation**: Real-time validation for all fields
- **Country Code Picker**: Integrated phone number with country selection
- **Permission Setup**: Comprehensive permission configuration during creation
- **Route Factory Pattern**: Clean route integration with `UserRoutes.getMaterialRoutes()`
- **Backend Integration**: User IDs generated by backend for proper uniqueness
- **Error Handling**: Graceful error handling with user feedback

### 🎨 Permission Display

The permission widgets automatically handle:

- **Permission Categories**: Articles, Contacts, Tickets, etc.
- **CRUD Rights**: Create, Read, Update, Delete for each category
- **Bool Rights**: Stats, Discounts, Export permissions
- **Visual Indicators**: Color-coded switches and status displays
- **Inline Editing**: Direct permission modification in the UI

### 📖 Complete Example

See `simple_navigation_example.dart` for a complete working example that demonstrates:
- Setting up UserProvider
- Displaying user lists with permissions  
- Creating users with callback navigation
- Integrating with existing Scaffold/Drawer structure

### 🚀 Quick User Management Integration

**Route Factory Pattern** - The cleanest integration:

```dart
// 1. Add package routes to your app
MaterialApp(
  routes: {
    '/': (context) => const MainScreen(),
    ...UserRoutes.getMaterialRoutes(), // Package provides routes!
  },
)

// 2. Navigate from anywhere (drawer, buttons, etc.)
ListTile(
  leading: const Icon(Icons.group),
  title: const Text('Users'),
  onTap: () => Navigator.pushNamed(context, '/users'), // Clean!
),

// That's it! Package handles:
// - /users → User list with beautiful FAB
// - /users/create → Comprehensive user creation
// - Automatic navigation between screens
```

## Features

- **User Management**: Complete CRUD operations for users
- **Authentication**: JWT token handling via shared `auth_weebi` package
- **Permissions**: Granular permission system with boolean and CRUD rights
- **gRPC Integration**: Full integration with Weebi's gRPC services
- **UI Components**: Ready-to-use widgets for user management
- **State Management**: Provider-based state management for clean architecture
- **Interceptors**: Auth and logging interceptors for gRPC calls
- **Protobuf Extensions**: Convenient extensions for UserPublic and UserPermissions

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  users_weebi: ^1.0.0
```

## Usage

### Basic Setup (New - Using auth_weebi)

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:users_weebi/users_weebi.dart';

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
    return MaterialApp(
      home: initCrossRoutesTestV2(
        Scaffold(
          appBar: AppBar(title: Text('User Management')),
          body: UserListWidget(),
        ),
        sharedPrefs: sharedPrefs,
      ),
    );
  }
}
```

### Authentication (New - Using auth_weebi)

```dart
// Access the providers
final persistedTokenProvider = context.read<PersistedTokenProvider>();
final accessTokenProvider = context.read<AccessTokenProvider>();

// Read and set access token
final accessToken = await persistedTokenProvider.readAccessToken();
accessTokenProvider.accessToken = accessToken;

// Check authentication status
if (!accessTokenProvider.isEmptyOrExpired) {
  // User is authenticated
}

// Check permissions using the helper
if (PermissionsHelper.hasPermission(
    accessTokenProvider.accessToken, 
    'userManagement_create')) {
  // User can create users
}

// Or check permissions using the provider
final permissions = accessTokenProvider.permissions;
if (permissions.boolRights.canSeeStats) {
  // User can see statistics
}
```

### User Management

```dart
// Load users
final userProvider = context.read<UserProvider>();
await userProvider.loadUsers();

// Create user
final newUser = UserPublic()
  ..firstname = 'John'
  ..lastname = 'Doe'
  ..mail = 'john.doe@example.com';
await userProvider.createUser(newUser);

// Update user
user.firstname = 'Jane';
await userProvider.updateUser(user);

// Delete user
await userProvider.deleteUser(userId);
```

### Using Widgets

```dart
// Beautiful user creation view with permissions setup
UserCreateView()

// Enhanced user list with permission editing
UserListWidget(
  currentUserId: cloudHub.userId, // Required for security
  showPermissions: true,
  onPermissionsChanged: (user, permissions) {
    // Handle permission changes
    saveUserPermissions(user, permissions);
  },
)

// User form for creating/editing
UserFormWidget(user: existingUser)

// User details view
UserDetailWidget(user: user)

// User permissions management (original dialog-based)
UserPermissionsWidget(userId: userId)

// Elegant inline permissions editing
ElegantPermissionsWidget(
  permissions: userPermissions,
  isEditable: true,
  onPermissionsChanged: (updatedPermissions) {
    // Handle permission changes
    saveUserPermissions(updatedPermissions);
  },
)

// Enhanced permission widget (drop-in replacement for PermissionWidget)
EditablePermissionWidget(
  icon: Icon(Icons.article),
  permissionIcon: Icon(Icons.create),
  permissionName: Text('Create Articles'),
  hasPermission: hasCreatePermission,
  isEditable: true,
  onChanged: (value) => updatePermission('create', value),
)

// User search
UserSearchWidget()
```

### Legacy Setup (Deprecated)

The old `initCrossRoutesTest` function has been removed as it used the deprecated internal `AuthProvider`. For new implementations, use `initCrossRoutesTestV2` with `auth_weebi` as shown above.

## Architecture

The package follows a clean architecture pattern:

- **Services**: Handle gRPC communication and business logic
- **Providers**: Manage state using Provider pattern
- **Widgets**: UI components for user interaction
- **Interceptors**: Handle authentication and logging for gRPC calls
- **Utils**: JWT parsing and utility functions

## Dependencies

- `provider`: State management
- `protos_weebi`: Protobuf definitions
- `grpc`: gRPC communication
- `shared_preferences`: Token storage
- `auth_weebi`: Shared authentication package (local dependency)
- `flutter`: UI framework

## Additional Information

This package is the result of merging the best features from `weebi_user` and `users_weebi` packages, providing a comprehensive solution for user management in Weebi applications.
