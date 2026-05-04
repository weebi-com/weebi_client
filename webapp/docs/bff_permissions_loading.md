## Permission Handling Patterns

### BFF Mode Race Condition Prevention

When building screens that require specific permissions (e.g., billing, user management), be aware of a potential race condition in **BFF mode** where the `CurrentUserProvider` loads session-based permissions asynchronously:

**Problem:** If your screen checks permissions immediately during `build()`, the user data may not be loaded yet, causing a false "no access" message to briefly appear even for authorized users.

**Solution:** Before showing an error message, check if the user data is still loading. If it is, display a loading spinner instead of an error:

```dart
@override
Widget build(BuildContext context) {
  final hasPermission = _hasReadBillingPermission(context);
  
  if (!hasPermission) {
    if (Config.isBffMode) {
      final currentUser = context.read<CurrentUserProvider>();
      if (currentUser.user == null) {
        // User data still loading; show spinner instead of "no access"
        return PortalMasterLayout(
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    }
    
    // User data loaded and confirmed no access
    return _buildAccessDeniedScreen(context);
  }
  
  // User has permission; show normal screen
  return _buildScreenContent(context);
}
```

**Why this matters:** In BFF mode, the session data is fetched from the backend after the initial render, causing a temporary state where `currentUser.user == null` even though the user is logged in and authorized. This pattern ensures we don't show false errors during this loading window.
