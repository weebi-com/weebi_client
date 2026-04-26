import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart'
    show FenceServiceClient, License, UserPublic;
import 'package:provider/provider.dart';
import 'package:users_weebi/weebi_users.dart';
import 'package:boutiques_weebi/boutiques_weebi.dart';
import '../l10n/access_ui_strings.dart';
import '../providers/access_provider.dart';
import '../widgets/access_list_widget.dart';
import '../widgets/user_access_widget.dart';

/// Routes and navigation helpers for the accesses package
class AccessRoutes {
  static const String accessList = '/accesses';
  static const String userAccess = '/accesses/user';

  /// Get material routes that require providers to be available in context
  static Map<String, WidgetBuilder> getMaterialRoutes({
    required String currentUserId,
  }) => {
        accessList: (context) => _buildAccessList(context, currentUserId),
        userAccess: (context) => _buildUserAccess(context),
      };

  /// Get provider-based routes that lazily fetch currentUserId
  static Map<String, WidgetBuilder> getProviderRoutes({
    required String Function(BuildContext) getCurrentUserId,
  }) => {
        accessList: (context) => _buildAuthenticatedAccessList(context, getCurrentUserId),
        userAccess: (context) => _buildUserAccess(context),
      };

  /// Build access list widget wrapped in Scaffold
  static Widget _buildAccessList(BuildContext context, String currentUserId) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AccessUiStrings.accessManagementTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AccessProvider>().initialize();
            },
          ),
        ],
      ),
      body: AccessListWidget(currentUserId: currentUserId),
    );
  }

  /// Build authenticated access list using provider to get currentUserId
  static Widget _buildAuthenticatedAccessList(
    BuildContext context,
    String Function(BuildContext) getCurrentUserId,
  ) {
    final currentUserId = getCurrentUserId(context);
    return _buildAccessList(context, currentUserId);
  }

  /// Build user access widget wrapped in Scaffold
  static Widget _buildUserAccess(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    UserPublic? user;
    String? currentUserId;
    Iterable<License>? firmLicenses;
    if (args is UserPublic) {
      user = args;
    } else if (args is Map) {
      user = args['user'] as UserPublic?;
      currentUserId = args['currentUserId'] as String?;
      firmLicenses = args['firmLicenses'] as Iterable<License>?;
    }
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AccessUiStrings.userAccessTitle)),
        body: const Center(
          child: Text(AccessUiStrings.noUserDataError),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AccessUiStrings.userAccessAppBarTitle(
            user.firstname, user.lastname)),
      ),
      body: UserAccessWidget(
        user: user,
        currentUserId: currentUserId,
        firmLicenses: firmLicenses,
      ),
    );
  }

  /// Navigate to user access management
  static Future<void> navigateToUserAccess(
    BuildContext context,
    UserPublic user, {
    String? currentUserId,
    Iterable<License>? firmLicenses,
  }) {
    if (currentUserId == null && firmLicenses == null) {
      return Navigator.pushNamed(context, userAccess, arguments: user);
    }
    return Navigator.pushNamed(
      context,
      userAccess,
      arguments: {
        'user': user,
        if (currentUserId != null) 'currentUserId': currentUserId,
        if (firmLicenses != null) 'firmLicenses': firmLicenses,
      },
    );
  }

  /// Navigate to access list
  static Future<void> navigateToAccessList(BuildContext context) {
    return Navigator.pushNamed(context, accessList);
  }

  /// Show user access as modal bottom sheet
  static Future<void> showUserAccessModal(
    BuildContext context,
    UserPublic user, {
    Iterable<License>? firmLicenses,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AccessUiStrings.userAccessModalTitle(
                            user.firstname, user.lastname),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: UserAccessWidget(
                  user: user,
                  firmLicenses: firmLicenses,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Create MultiProvider with all necessary providers for access management
  static Widget createAccessProvider({
    required UserProvider userProvider,
    required BoutiqueProvider boutiqueProvider,
    required Widget child,
  }) {
    return ChangeNotifierProvider(
      create: (context) => AccessProvider(
        userProvider: userProvider,
        boutiqueProvider: boutiqueProvider,
      ),
      child: child,
    );
  }

  /// Create complete provider hierarchy for standalone access management
  static Widget createStandaloneAccessApp({
    required String currentUserId,
    String title = AccessUiStrings.standaloneAppTitle,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(_MockFenceServiceClient())),
        ChangeNotifierProvider(create: (_) => BoutiqueProvider(_MockFenceServiceClient())),
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
      child: MaterialApp(
        title: title,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        routes: getMaterialRoutes(currentUserId: currentUserId),
        initialRoute: accessList,
      ),
    );
  }
}

// Mock FenceServiceClient for standalone demo purposes
class _MockFenceServiceClient implements FenceServiceClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
