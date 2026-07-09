import 'package:flutter/foundation.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

/// Provider class for managing user state and permissions
class UserProvider extends ChangeNotifier {
  final FenceServiceClient _fenceServiceClient;

  /// Simple cache for user permissions to avoid repeated service calls
  final Map<String, UserPermissions> _permissionsCache = {};
  List<UserPublic> _users = [];
  UserPublic? _selectedUser;
  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;

  UserProvider(this._fenceServiceClient);

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  // Getters
  List<UserPublic> get users => _users;
  UserPublic? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  FenceServiceClient get fenceServiceClient => _fenceServiceClient;

  /// Clears any error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Generates a secure random password for new users
  /// Password will be encrypted by server and user must change on first login
  String _generateSecureRandomPassword() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#&*';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(6, (index) => chars[(random + index) % chars.length])
        .join();
  }

  /// Loads all users
  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _fenceServiceClient.readAllUsers(Empty());
      _users = response.users;
    } on GrpcError catch (e) {
      _error = '${e.code} ${e.message}';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads a specific user by ID
  Future<void> loadUser(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await _fenceServiceClient.readOneUser(UserId()..userId = id);
      _selectedUser = response.user;
    } on GrpcError catch (e) {
      _error = '${e.code} ${e.message}';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new user
  Future<UserPublic> createUser(UserPublic user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create user with temporary password or email verification
      final pendingUser = PendingUserRequest();
      pendingUser
        ..firstname = user.firstname
        ..lastname = user.lastname
        ..mail = user.mail
        ..permissions = user.permissions
        ..phone = user.phone
        ..password = _generateSecureRandomPassword();

      final response = await _fenceServiceClient.createPendingUser(pendingUser);

      // Get the complete user from the server response (includes userId)
      final createdUser = response.userPublic;
      print('UserProvider: Created user with userId: ${createdUser.userId}');

      // Add to local list with the userId
      _users = [..._users, createdUser];

      // Refresh the full list to ensure backend sync
      await loadUsers();

      return createdUser; // Return the user with userId
    } on GrpcError catch (e) {
      _error = '${e.code} ${e.message}';
      _isLoading = false;
      notifyListeners();
      rethrow; // Propagate error to caller so they know creation failed
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow; // Propagate error to caller so they know creation failed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates an existing user
  Future<void> updateUser(UserPublic user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _fenceServiceClient.updateOneUser(user);
      _users = _users.map((u) => u.userId == user.userId ? user : u).toList();
      if (_selectedUser?.userId == user.userId) {
        _selectedUser = user;
      }
    } on GrpcError catch (e) {
      _error = '${e.code} ${e.message}';
      _isLoading = false;
      notifyListeners();
      rethrow; // Propagate error to caller so they know update failed
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow; // Propagate error to caller so they know update failed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a user by ID
  Future<void> deleteUser(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _fenceServiceClient.deleteOneUser(UserId()..userId = id);
      _users = _users.where((u) => u.userId != id).toList();
      if (_selectedUser?.userId == id) {
        _selectedUser = null;
      }
    } on GrpcError catch (e) {
      _error = '${e.code} ${e.message}';
      _isLoading = false;
      notifyListeners();
      rethrow; // Propagate error to caller so they know deletion failed
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow; // Propagate error to caller so they know deletion failed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Searches for users by query
  Future<void> searchUsers(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Note: searchUsers method may not exist, filtering locally for now
      _users = _users
          .where((user) =>
              user.firstname.toLowerCase().contains(query.toLowerCase()) ||
              user.lastname.toLowerCase().contains(query.toLowerCase()) ||
              user.mail.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } on GrpcError catch (e) {
      _error = '${e.code} ${e.message}';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gets permissions for a user.
  ///
  /// When [forceRefresh] is true, calls the server even if a cache entry exists
  /// (use when opening user detail so flags like [UserManagementRights.canUpdateUserPassword]
  /// match the backend after edits or first paint).
  Future<UserPermissions?> getUserPermissions(
    String userId, {
    bool forceRefresh = false,
  }) async {
    try {
      print('UserProvider: Attempting to load permissions for user $userId');

      if (!forceRefresh && _permissionsCache.containsKey(userId)) {
        print('UserProvider: Found permissions in cache for user $userId');
        return _permissionsCache[userId];
      }

      if (forceRefresh && _permissionsCache.containsKey(userId)) {
        print('UserProvider: Bypassing cache (forceRefresh) for user $userId');
      }

      // Try to load from service
      final permissions = await _loadUserPermissionsFromService(userId);
      if (permissions != null) {
        _permissionsCache[userId] = permissions;
        print(
            'UserProvider: Successfully loaded and cached permissions for user $userId');
        return permissions;
      }

      print('UserProvider: No permissions found, will use fallback');
      return null; // This will trigger fallback to minimal permissions
    } on GrpcError catch (e) {
      print('UserProvider: Error loading permissions for user $userId: $e');
      _error = '${e.code} ${e.message}';
      notifyListeners();
      return null;
    } catch (e) {
      print('UserProvider: Error loading permissions for user $userId: $e');
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Updates permissions for a user
  Future<bool> updateUserPermissions(
      String userId, UserPermissions permissions) async {
    try {
      print('UserProvider: Attempting to update permissions for user $userId');
      print(
          'UserProvider: New permissions - Articles: ${permissions.articleRights.rights.map((r) => r.name).join(", ")}');

      // Update via service
      final success =
          await _updateUserPermissionsViaService(userId, permissions);

      if (success) {
        // Update cache
        _permissionsCache[userId] = permissions;
        print(
            'UserProvider: Successfully updated permissions for user $userId');
        notifyListeners(); // Notify UI to refresh
        return true;
      } else {
        print('UserProvider: Failed to update permissions for user $userId');
        _error = 'Failed to update permissions';
        notifyListeners();
        return false;
      }
    } on GrpcError catch (e) {
      print('UserProvider: Error updating user permissions: $e');
      _error = '${e.code} ${e.message}';
      notifyListeners();
      return false;
    } catch (e) {
      print('UserProvider: Error updating user permissions: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clears cached permissions for a user
  void clearUserPermissionsCache(String userId) {
    _permissionsCache.remove(userId);
    print('UserProvider: Cleared permissions cache for user $userId');
  }

  /// Clears all cached permissions
  void clearAllPermissionsCache() {
    _permissionsCache.clear();
    print('UserProvider: Cleared all permissions cache');
  }

  // === Private Methods ===

  Future<UserPermissions?> _loadUserPermissionsFromService(
      String userId) async {
    try {
      print('UserProvider: Loading user with permissions for userId: $userId');

      // Simply read the user - UserPublic already contains permissions!
      final userRequest = UserId()..userId = userId;
      final userResponse = await _fenceServiceClient.readOneUser(userRequest);

      if (userResponse.hasUser()) {
        final user = userResponse.user;
        print('UserProvider: Found user ${user.firstname} ${user.lastname}');

        // Check if user has permissions field
        if (user.hasPermissions()) {
          print('UserProvider: User has permissions - loading them');
          return UserPermissions.create()
            ..mergeFromMessage(user.permissions)
            ..ensureBoolRights();
        } else {
          print('UserProvider: User has no permissions field - using fallback');
          return null;
        }
      } else {
        print('UserProvider: User not found for userId: $userId');
        return null;
      }
    } catch (e) {
      print('UserProvider: Service call failed: $e');
      return null;
    }
  }

  Future<bool> _updateUserPermissionsViaService(
      String userId, UserPermissions permissions) async {
    try {
      print('UserProvider: Updating permissions for userId: $userId');

      // First, get the current user data
      final userRequest = UserId()..userId = userId;
      final userResponse = await _fenceServiceClient.readOneUser(userRequest);

      if (userResponse.hasUser()) {
        final user = userResponse.user;
        print('UserProvider: Found user ${user.firstname} ${user.lastname}');

        // Update the permissions field and send the whole user object back
        final updatedUser = user..permissions = permissions;

        await _fenceServiceClient.updateOneUser(updatedUser);
        print('UserProvider: Successfully updated user with new permissions');
        return true;
      } else {
        print('UserProvider: User not found for update: $userId');
        return false;
      }
    } catch (e) {
      print('UserProvider: Service update failed: $e');
      return false;
    }
  }

  /// Selects a user for detailed view
  void selectUser(UserPublic user) {
    _selectedUser = user;
    notifyListeners();
  }
}
