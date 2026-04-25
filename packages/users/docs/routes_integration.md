# UserManagement Integration Guide

**Route Factory Pattern 🔥** - The cleanest way to integrate user management routes into your Flutter app.

## 🎯 Why Route Factory Pattern?

- **🎨 Clean**: No messy callbacks or complex navigation logic
- **📦 Package-friendly**: Routes are provided by the package, organized by you
- **🔧 Flexible**: Works with MaterialApp routes, onGenerateRoute, or Go Router
- **🚀 Simple**: Just add routes to your app and navigate with `Navigator.pushNamed()`

## ⚡ Quick Setup

### 1. Add Package Routes to Your App

```dart
MaterialApp(
  routes: {
    '/': (context) => const MainScreen(),
    // Add user management routes - that's it!
    ...UserRoutes.getMaterialRoutes(),
  },
)
```

### 2. Navigate Like Normal

```dart
// In your drawer or anywhere
ListTile(
  leading: const Icon(Icons.group),
  title: const Text('Users'),
  onTap: () => Navigator.pushNamed(context, '/users'), // Clean!
),
```

## 🎉 That's It!

Your app now has:
- `/users` → Beautiful user list with FAB
- `/users/create` → Comprehensive user creation
- Automatic navigation between screens
- Your drawer/scaffold structure preserved

## 🔧 Available Routes

The package provides these routes:

| Route | Widget | Description |
|-------|---------|-------------|
| `/users` | `UserListWidget` | User list with create FAB |
| `/users/create` | `UserCreateView` | User creation form |

## 📱 Integration Examples

### Option 1: Simple Route Integration (Recommended)

```dart
import 'package:users_weebi/weebi_users.dart';

// Option A: Direct parameter approach (for go_router migration)
MaterialApp(
  routes: {
    '/': (context) => const MainScreen(),
    ...UserRoutes.getMaterialRoutes(
      currentUserId: cloudHub.userId, // Required for security
    ),
  },
)

// Option B: Provider-based approach (current rcRouter)
MaterialApp(
  routes: {
    '/': (context) => const MainScreen(),
    ...UserRoutes.getProviderRoutes(
      getUserId: (context) => context.read<Gatekeeper>().userId, // Lazy evaluation
    ),
  },
)

// Navigate anywhere in your app
Navigator.pushNamed(context, '/users');
```

### Option 2: Custom Route Generation

```dart
MaterialApp(
  onGenerateRoute: (settings) {
    // Try user routes first (for go_router migration)
    final userRoute = UserRoutes.onGenerateRoute(
      settings,
      currentUserId: cloudHub.userId, // Required for security
    );
    if (userRoute != null) return userRoute;
    
    // Handle your other routes
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(builder: (_) => const NotFoundScreen());
    }
  },
)
```

### Option 3: Custom Scaffold Integration

If you want to customize the AppBar, Drawer, etc.:

```dart
// Use route factory with your custom scaffold
MaterialApp(
  routes: {
    '/': (context) => const MainScreen(),
    '/users': (context) => UserRoutes.buildUserListWithCustomScaffold(
      appBar: AppBar(
        title: const Text('My Users'),
        backgroundColor: Colors.purple,
      ),
      drawer: const MyCustomDrawer(),
      endDrawer: null,
    ),
    '/users/create': (context) => UserRoutes.buildCreateUserWithCustomScaffold(
      appBar: AppBar(
        title: const Text('Add New User'),
        backgroundColor: Colors.green,
      ),
      drawer: const MyCustomDrawer(),
      endDrawer: null,
    ),
  },
)
```

## 🧩 Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_weebi/weebi_users.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(yourFenceServiceClient),
        ),
      ],
      child: MaterialApp(
        title: 'My App',
        
        // Clean route integration
        routes: {
          '/': (context) => const MainScreen(),
          ...UserRoutes.getMaterialRoutes(), // Done!
        },
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My App')),
      drawer: AppDrawer(),
      body: const Center(child: Text('Welcome!')),
    );
  }
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text('Menu')),
          
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          
          // Super clean user management navigation
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Users'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/users'); // Package handles it!
            },
          ),
        ],
      ),
    );
  }
}
```

## 🌟 Benefits

### For Your Codebase:
- **Clean navigation**: Just use `Navigator.pushNamed()`
- **No callbacks**: No messy callback chains
- **Organized routes**: All user routes provided by package
- **Your structure**: Keep your drawer, AppBar, styling

### For the Package:
- **Self-contained**: Package owns its navigation
- **Flexible**: Works with any routing setup
- **Maintainable**: Easy to add new routes
- **Standard**: Follows Flutter routing conventions

## 🔧 Provider Setup

Don't forget to provide `UserProvider` in your widget tree:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider<UserProvider>(
      create: (_) => UserProvider(yourFenceServiceClient),
    ),
    // ... your other providers
  ],
  child: MyApp(),
)
```

## 🎯 Next Steps

1. Add `...UserRoutes.getMaterialRoutes()` to your app routes
2. Navigate with `Navigator.pushNamed(context, '/users')`
3. Customize the scaffolds if needed
4. Test the flow in your app

## 💡 Why This Pattern Rocks

- **🎯 Simple**: Two lines of code to integrate
- **🔧 Flexible**: Customize as much or as little as you want
- **📦 Package-friendly**: Works perfectly for package distribution
- **🌐 Universal**: Works with MaterialApp, Go Router, or custom routing
- **✨ Clean**: No callback hell or complex navigation logic

The Route Factory Pattern gives you the **best of both worlds**: package convenience with full client control! 🚀 