import 'package:flutter/material.dart';
import 'package:auth_weebi/auth_weebi.dart';
import 'package:provider/provider.dart';
import 'package:users_weebi/src/fence_client_provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import '../l10n/user_ui_strings.dart';
import '../providers/user_provider.dart';
import '../widgets/user_create_view.dart';
import '../widgets/user_detail_widget.dart';
import '../widgets/user_list_widget.dart';

/// Route factory for user management
/// Provides clean route builders that client apps can integrate
class UserRoutes {
  /// Standard Material App routes (English defaults - override for localization)
  /// Requires currentUserId to be passed for security (prevents self-permission editing)
  /// 
  /// Optional onUserCreated callback to link user creation with access management.
  /// Example: onUserCreated: (context, user) => Navigator.push(context, ...UserAccessWidget...)
  static Map<String, WidgetBuilder> getMaterialRoutes({
    required String currentUserId,
    void Function(BuildContext, UserPublic)? onUserCreated,
    Iterable<License>? firmLicenses,
    Iterable<License>? firmLicensesForCreate,
    bool showLicenseReminderOnCreate = true,
  }) =>
      {
        '/users': (context) => buildUserListWithCustomScaffold(
              currentUserId: currentUserId,
              appBar: AppBar(title: const Text(UserUiStrings.appBarUsers)),
              drawer: null,
              endDrawer: null,
              firmLicenses: firmLicenses,
            ),
        '/users/create': (context) => buildCreateUserWithCustomScaffold(
              appBar:
                  AppBar(title: const Text(UserUiStrings.appBarCreateUser)),
              drawer: null,
              endDrawer: null,
              onUserCreated: onUserCreated,
              firmLicenses: firmLicensesForCreate,
              showLicenseReminder: showLicenseReminderOnCreate,
            ),
      };

  /// Route builders for custom integration
  /// Requires currentUserId to be passed for security (prevents self-permission editing)
  /// 
  /// Optional onUserCreated callback to link user creation with access management.
  /// Example: onUserCreated: (context, user) => Navigator.push(context, ...UserAccessWidget...)
  static Route<dynamic>? onGenerateRoute(
    RouteSettings settings, {
    required String currentUserId,
    void Function(BuildContext, UserPublic)? onUserCreated,
    Iterable<License>? firmLicenses,
    Iterable<License>? firmLicensesForCreate,
    bool showLicenseReminderOnCreate = true,
  }) {
    switch (settings.name) {
      case '/users':
        return MaterialPageRoute(
          builder: (context) => buildUserListWithCustomScaffold(
            currentUserId: currentUserId,
            appBar: AppBar(title: const Text(UserUiStrings.appBarUsers)),
            drawer: null,
            endDrawer: null,
            firmLicenses: firmLicenses,
          ),
          settings: settings,
        );
      case '/users/create':
        return MaterialPageRoute(
          builder: (context) => buildCreateUserWithCustomScaffold(
            appBar:
                AppBar(title: const Text(UserUiStrings.appBarCreateUser)),
            drawer: null,
            endDrawer: null,
            onUserCreated: onUserCreated,
            firmLicenses: firmLicensesForCreate,
            showLicenseReminder: showLicenseReminderOnCreate,
          ),
          settings: settings,
        );
      default:
        return null;
    }
  }

  /// Widget builders (can be used standalone)
  /// Requires currentUserId to be passed for security (prevents self-permission editing)
  static Widget buildUserList(BuildContext context, {
    required String currentUserId,
  }) => UserListWidget(currentUserId: currentUserId);
  
  static Widget buildCreateUser(
    BuildContext context, {
    void Function(BuildContext, UserPublic)? onUserCreated,
    Iterable<License>? firmLicenses,
    bool showLicenseReminder = true,
  }) =>
      UserCreateView(
        onUserCreated: onUserCreated,
        firmLicenses: firmLicenses,
        showLicenseReminder: showLicenseReminder,
      );
  
  /// Build user detail view with proper scaffold and navigation
  static Widget buildUserDetailView(
    BuildContext context,
    UserPublic user,
    UserProvider userProvider, {
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    String? currentUserId,
    void Function(UserPublic, UserPermissions)? onPermissionsChanged,
    Iterable<License>? firmLicenses,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${user.firstname} ${user.lastname}'),
        actions: [
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: UserUiStrings.tooltipEditUser,
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              tooltip: UserUiStrings.tooltipDeleteUser,
            ),
          if (currentUserId != null && user.userId == currentUserId)
            Builder(
              builder: (context) {
                return IconButton(
                  tooltip: UserUiStrings.refreshPermissionsTooltip,
                  icon: const Icon(Icons.refresh),
                  onPressed: () async {
                    try {
                      final persisted = context.read<PersistedTokenProvider>();
                      final access = context.read<AccessTokenProvider>();
                      final fence =
                          context.read<FenceServiceClientProviderV2>();

                      final refresh = persisted.refreshToken.isEmpty
                          ? await persisted.readAndSetRefreshToken()
                          : persisted.refreshToken;

                      if (refresh.isEmpty || persisted.isEmptyOrExpired) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(UserUiStrings.sessionExpired)),
                        );
                        return;
                      }

                      final tokens = await fence.fenceServiceClient
                          .authenticateWithRefreshToken(
                              RefreshToken()..refreshToken = refresh);

                      access.accessToken = tokens.accessToken;

                      if (tokens.refreshToken.isNotEmpty &&
                          tokens.refreshToken != persisted.refreshToken) {
                        await persisted.setAndUpsertRefreshToken(
                            tokens.refreshToken);
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text(UserUiStrings.permissionsRefreshed)),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(UserUiStrings
                                .refreshPermissionsFailed('$e'))),
                      );
                    }
                  },
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: UserDetailWidget(
          user: user,
          userProvider: userProvider,
          currentUserId: currentUserId,
          onPermissionsChanged: onPermissionsChanged,
          firmLicenses: firmLicenses,
        ),
      ),
    );
  }

  /// Custom scaffold builders where client provides the scaffold structure
  /// Requires currentUserId to be passed for security (prevents self-permission editing)
  static Widget buildUserListWithCustomScaffold({
    required String currentUserId,
    required PreferredSizeWidget? appBar,
    required Widget? drawer,
    required Widget? endDrawer,
    Widget? floatingActionButton,
    VoidCallback? onCreateUser,
    void Function(UserPublic, UserPermissions)? onPermissionsChanged,
    Iterable<License>? firmLicenses,
  }) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      body: UserListWidget(
        currentUserId: currentUserId,
        onCreateUser: onCreateUser,
        onPermissionsChanged: onPermissionsChanged,
        firmLicenses: firmLicenses,
      ),
    );
  }

  static Widget buildCreateUserWithCustomScaffold({
    required PreferredSizeWidget? appBar,
    required Widget? drawer,
    required Widget? endDrawer,
    void Function(BuildContext, UserPublic)? onUserCreated,
    Iterable<License>? firmLicenses,
    bool showLicenseReminder = true,
  }) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      body: UserCreateView(
        showFloatingActionButton: false,
        onUserCreated: onUserCreated,
        firmLicenses: firmLicenses,
        showLicenseReminder: showLicenseReminder,
      ),
    );
  }

  // === PROVIDER-BASED ROUTES ===
  
  /// Route map that handles user ID retrieval via callback
  /// Perfect for apps where userId is available after MaterialApp initialization
  /// 
  /// Optional onUserCreated callback to link user creation with access management.
  /// 
  /// Usage:
  /// ```dart
  /// MaterialApp(
  ///   routes: {
  ///     '/': (context) => const MainScreen(),
  ///     ...UserRoutes.getProviderRoutes(
  ///       getUserId: (context) => context.read<Gatekeeper>().userId,
  ///       onUserCreated: (context, user) => Navigator.push(context, MaterialPageRoute(
  ///         builder: (_) => UserAccessWidget(user: user),
  ///       )),
  ///     ),
  ///   },
  /// )
  /// ```
  static Map<String, WidgetBuilder> getProviderRoutes({
    required String Function(BuildContext) getUserId,
    void Function(BuildContext, UserPublic)? onUserCreated,
  }) => {
        '/users': (context) => _buildAuthenticatedUserList(context, getUserId),
        '/users/create': (context) => buildCreateUserWithCustomScaffold(
          appBar:
              AppBar(title: const Text(UserUiStrings.appBarCreateUser)),
          drawer: null,
          endDrawer: null,
          onUserCreated: onUserCreated,
        ),
      };

  /// Internal wrapper that uses callback to get currentUserId
  static Widget _buildAuthenticatedUserList(
    BuildContext context, 
    String Function(BuildContext) getUserId,
  ) {
    final currentUserId = getUserId(context);
    
    return buildUserListWithCustomScaffold(
      currentUserId: currentUserId,
      appBar: AppBar(title: const Text(UserUiStrings.appBarUsers)),
      drawer: null,
      endDrawer: null,
    );
  }

  /// Standalone widget that uses callback to get currentUserId
  /// Use this if you want to embed the user list directly in your widget tree
  /// 
  /// Usage:
  /// ```dart
  /// body: UserRoutes.buildProviderUserList(
  ///   getUserId: (context) => context.read<Gatekeeper>().userId,
  /// ),
  /// ```
  static Widget buildProviderUserList({
    required String Function(BuildContext) getUserId,
  }) {
    return Builder(
      builder: (context) {
        final currentUserId = getUserId(context);
        return UserListWidget(currentUserId: currentUserId);
      },
    );
  }

  /// Navigation helper for user detail view
  static void navigateToUserDetailView(
    BuildContext context,
    UserPublic user,
    UserProvider userProvider, {
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    String? currentUserId,
    void Function(UserPublic, UserPermissions)? onPermissionsChanged,
    Iterable<License>? firmLicenses,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => buildUserDetailView(
          context,
          user,
          userProvider,
          onEdit: onEdit,
          onDelete: onDelete,
          currentUserId: currentUserId,
          onPermissionsChanged: onPermissionsChanged,
          firmLicenses: firmLicenses,
        ),
      ),
    );
  }
} 