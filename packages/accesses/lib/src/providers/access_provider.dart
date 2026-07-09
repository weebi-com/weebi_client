import 'package:flutter/foundation.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:users_weebi/weebi_users.dart';
import 'package:boutiques_weebi/boutiques_weebi.dart';

/// Provider for managing user access permissions to boutiques and chains
class AccessProvider extends ChangeNotifier {
  final UserProvider _userProvider;
  final BoutiqueProvider _boutiqueProvider;

  // Cache for user permissions
  final Map<String, UserPermissions> _userPermissionsCache = {};

  // Loading states
  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;

  AccessProvider({
    required UserProvider userProvider,
    required BoutiqueProvider boutiqueProvider,
  })  : _userProvider = userProvider,
        _boutiqueProvider = boutiqueProvider;

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
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserPublic> get users => _userProvider.users;
  List<Chain> get chains => _boutiqueProvider.chains;
  List<BoutiqueMongo> get allBoutiques => _boutiqueProvider.allBoutiques;
  BoutiqueProvider get boutiqueProvider => _boutiqueProvider;

  /// Initialize the provider by loading users and boutiques
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      await Future.wait([
        _userProvider.loadUsers(),
        _boutiqueProvider.loadChains(),
      ]);
    } on GrpcError catch (e) {
      _setError('Failed to initialize access data: ${e.code} ${e.message}');
    } catch (e) {
      _setError('Failed to initialize access data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get user permissions from cache or fetch from provider
  Future<UserPermissions?> getUserPermissions(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _userPermissionsCache.containsKey(userId)) {
      return _userPermissionsCache[userId];
    }
    if (forceRefresh) {
      _userPermissionsCache.remove(userId);
    }

    try {
      final permissions = await _userProvider.getUserPermissions(
        userId,
        forceRefresh: forceRefresh,
      );
      if (permissions != null) {
        _userPermissionsCache[userId] = permissions;
      }
      return permissions;
    } on GrpcError catch (e) {
      _setError('Failed to load permissions for user $userId: ${e.code} ${e.message}');
      return null;
    } catch (e) {
      _setError('Failed to load permissions for user $userId: $e');
      return null;
    }
  }

  /// Update user permissions - requires admin rights
  Future<bool> updateUserPermissions(
      String userId, UserPermissions permissions) async {
    _clearError();

    try {
      final success =
          await _userProvider.updateUserPermissions(userId, permissions);
      if (success) {
        _userPermissionsCache[userId] = permissions;
        notifyListeners();
      }
      return success;
    } on GrpcError catch (e) {
      _setError('Failed to update permissions for user $userId: ${e.code} ${e.message}');
      return false;
    } catch (e) {
      _setError('Failed to update permissions for user $userId: $e');
      return false;
    }
  }

  /// Get boutiques for a specific chain
  List<BoutiqueMongo> getBoutiquesForChain(String chainId) {
    return allBoutiques
        .where((boutique) => boutique.chainId == chainId)
        .toList();
  }

  /// Check if user has access to a specific chain
  bool userHasChainAccess(UserPermissions permissions, String chainId) {
    // Check if user has full access
    if (permissions.hasFullAccess()) {
      return permissions.fullAccess.hasFullAccess;
    }

    // Check limited access
    if (permissions.hasLimitedAccess()) {
      return permissions.limitedAccess.chainIds.ids.contains(chainId);
    }

    return false;
  }

  /// Check if user has access to a specific boutique
  bool userHasBoutiqueAccess(UserPermissions permissions, String boutiqueId) {
    // Check if user has full access
    if (permissions.hasFullAccess()) {
      return permissions.fullAccess.hasFullAccess;
    }

    // Check limited access
    if (permissions.hasLimitedAccess()) {
      return permissions.limitedAccess.boutiqueIds.ids.contains(boutiqueId);
    }

    return false;
  }

  /// Clear permissions cache for a user
  void clearUserPermissionsCache(String userId) {
    _userPermissionsCache.remove(userId);
    notifyListeners();
  }

  /// Clear all permissions cache
  void clearAllPermissionsCache() {
    _userPermissionsCache.clear();
    notifyListeners();
  }

  // ===== DEVICE CHAINING FUNCTIONALITY =====
  // Note: Server already filters chains/boutiques based on user permissions
  // No need for complex client-side filtering logic!

  // Private helpers
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
