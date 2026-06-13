import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart' show FenceServiceClient;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/grpc/auth_interceptor.dart';
import 'package:web_admin/grpc/log_interceptor.dart';
import 'package:web_admin/grpc/server.dart';
import 'package:web_admin/grpc/unauthenticated_interceptor.dart';
import 'package:web_admin/providers/app_preferences_provider.dart';
import 'package:web_admin/providers/current_user_provider.dart';
import 'package:web_admin/providers/shared_prefs_auth_service.dart';
import 'package:web_admin/providers/server.dart';
import 'package:web_admin/providers/operational_license_gate.dart';
import 'package:web_admin/providers/session_recovery.dart';
import 'package:web_admin/providers/tickets_boutique_cache.dart';
import 'package:web_admin/providers/user_data_provider.dart';
import 'package:web_admin/utils/app_focus_helper.dart';

import 'core/constants/values.dart';
import 'package:accesses_weebi/accesses_weebi.dart' show AccessProvider;
import 'package:auth_weebi/auth_weebi.dart'
    show
        AccessTokenObject,
        AccessTokenProvider,
        AuthServiceAbstract,
        PermissionProvider,
        PersistedTokenProvider;
import 'package:boutiques_weebi/boutiques_weebi.dart' show BoutiqueProvider;
import 'package:devices_weebi/devices_weebi.dart' show DeviceProvider;
import 'package:users_weebi/users_weebi.dart'
    show FenceServiceClientProviderV2, UserProvider;

import 'core/theme/themes.dart';

class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  State<RootApp> createState() => _RootAppState();
}

void _setDeviceProviderPermissions(
    BuildContext context, DeviceProvider deviceProvider) {
  try {
    final permissions = context.read<PermissionProvider>().userPermissions;
    deviceProvider.setUserPermissions(permissions);
  } catch (_) {
    // Token empty or invalid - permissions will stay unset
  }
}

class _RootAppState extends State<RootApp> {
  GoRouter? _appRouter;

  Future<bool>? _future;

  Future<bool> _getScreenDataAsync(
      AppPreferencesProvider appPreferencesProvider,
      UserDataProvider userDataProvider,
      SharedPreferences sharedPrefs) async {
    appPreferencesProvider.loadAsync(sharedPrefs);
    await userDataProvider.loadAsync(); // TODO same thig here

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // consider reviewing
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final gate = OperationalLicenseGateNotifier();
            OperationalLicenseGateBinding.instance.attach(gate);
            return gate;
          },
        ),

        /// locale and dark mode
        ChangeNotifierProvider(create: (context) => AppPreferencesProvider()),

        Provider<AuthServiceAbstract>(create: (_) => SharedPrefsAuthService()),
        ProxyProvider<AuthServiceAbstract,
            PersistedTokenProvider<AuthServiceAbstract>>(
          update: (context, auth, previous) =>
              previous ?? PersistedTokenProvider(auth),
        ),

        Provider<AccessTokenObject>(
          create: (context) {
            final access = AccessTokenObject();
            access.value = context
                    .read<SharedPreferences>()
                    .getString(SharePrefKeys.accessToken) ??
                '';
            return access;
          },
        ),
        ChangeNotifierProxyProvider<AccessTokenObject, AccessTokenProvider>(
            create: (context) =>
                AccessTokenProvider(context.read<AccessTokenObject>()),
            update: (context, access, accessProvider) =>
                accessProvider!..accessToken = access.value),

        //
        ChangeNotifierProxyProvider<AccessTokenProvider,
            ArticleServiceClientProvider>(
          create: (BuildContext context) => ArticleServiceClientProvider(
              GrpcWebClientChannelWeebi().clientChannel,
              context.read<AccessTokenProvider>().accessToken),
          update: (
            BuildContext context,
            AccessTokenProvider accessTokenProvider,
            ArticleServiceClientProvider? provider2,
          ) =>
              provider2!..serviceClient = accessTokenProvider.accessToken,
        ),
        ChangeNotifierProxyProvider<AccessTokenProvider,
            ContactServiceClientProvider>(
          create: (BuildContext context) => ContactServiceClientProvider(
              GrpcWebClientChannelWeebi().clientChannel,
              context.read<AccessTokenProvider>().accessToken),
          update: (
            BuildContext context,
            AccessTokenProvider accessTokenProvider,
            ContactServiceClientProvider? provider2,
          ) =>
              provider2!..serviceClient = accessTokenProvider.accessToken,
        ),
        ChangeNotifierProxyProvider<AccessTokenProvider,
            FenceServiceClientProviderV2>(
          create: (BuildContext context) {
            final channel = GrpcWebClientChannelWeebi().clientChannel;
            FenceServiceClient createFenceClient(String token) =>
                FenceServiceClient(
                  channel,
                  options: callOptions,
                  interceptors: [
                    AuthInterceptor(token, isBffMode: Config.isBffMode),
                    UnauthenticatedInterceptor(),
                    RequestLogInterceptor(),
                  ],
                );
            return FenceServiceClientProviderV2(
              createFenceClient,
              context.read<AccessTokenProvider>().accessToken,
            );
          },
          update: (
            BuildContext context,
            AccessTokenProvider accessTokenProvider,
            FenceServiceClientProviderV2? provider2,
          ) =>
              provider2!..updateToken(accessTokenProvider.accessToken),
        ),
        ChangeNotifierProxyProvider<AccessTokenProvider,
            TicketServiceClientProvider>(
          create: (BuildContext context) => TicketServiceClientProvider(
              GrpcWebClientChannelWeebi().clientChannel,
              context.read<AccessTokenProvider>().accessToken),
          update: (
            BuildContext context,
            AccessTokenProvider accessTokenProvider,
            TicketServiceClientProvider? provider2,
          ) =>
              provider2!..serviceClient = accessTokenProvider.accessToken,
        ),
        ChangeNotifierProxyProvider<AccessTokenProvider,
            BillingServiceClientProvider>(
          create: (BuildContext context) => BillingServiceClientProvider(
              GrpcWebClientChannelWeebi().clientChannel,
              context.read<AccessTokenProvider>().accessToken),
          update: (
            BuildContext context,
            AccessTokenProvider accessTokenProvider,
            BillingServiceClientProvider? provider2,
          ) =>
              provider2!..serviceClient = accessTokenProvider.accessToken,
        ),
        ChangeNotifierProxyProvider<AccessTokenProvider,
            StatsServiceClientProvider>(
          create: (BuildContext context) => StatsServiceClientProvider(
              GrpcWebClientChannelWeebi().clientChannel,
              context.read<AccessTokenProvider>().accessToken),
          update: (
            BuildContext context,
            AccessTokenProvider accessTokenProvider,
            StatsServiceClientProvider? provider2,
          ) =>
              provider2!..serviceClient = accessTokenProvider.accessToken,
        ),
        ChangeNotifierProxyProvider<FenceServiceClientProviderV2,
            CurrentUserProvider>(
          create: (context) => CurrentUserProvider(
            context.read<FenceServiceClientProviderV2>().fenceServiceClient,
          ),
          update: (context, fenceProvider, previous) {
            final provider = previous ??
                CurrentUserProvider(fenceProvider.fenceServiceClient);
            provider.fenceServiceClient = fenceProvider.fenceServiceClient;
            return provider;
          },
        ),
        ChangeNotifierProxyProvider2<AccessTokenProvider,
            CurrentUserProvider, PermissionProvider>(
          create: (context) => PermissionProvider(
            context.read<AccessTokenProvider>(),
          ),
          update: (context, accessToken, currentUser, permissionProvider) {
            permissionProvider!.updateBffPermissions(currentUser.permissions);
            return permissionProvider;
          },
        ),
        ChangeNotifierProxyProvider<FenceServiceClientProviderV2,
            BoutiqueProvider>(
          create: (context) => BoutiqueProvider(
            context.read<FenceServiceClientProviderV2>().fenceServiceClient,
          ),
          update: (context, fenceProvider, previous) =>
              BoutiqueProvider(fenceProvider.fenceServiceClient),
        ),
        ChangeNotifierProxyProvider<FenceServiceClientProviderV2,
            TicketsBoutiqueCache>(
          create: (context) => TicketsBoutiqueCache(
            context.read<FenceServiceClientProviderV2>().fenceServiceClient,
          ),
          update: (context, fenceProvider, previous) =>
              TicketsBoutiqueCache(fenceProvider.fenceServiceClient),
        ),
        ChangeNotifierProxyProvider<FenceServiceClientProviderV2, UserProvider>(
          create: (context) => UserProvider(
            context.read<FenceServiceClientProviderV2>().fenceServiceClient,
          ),
          update: (context, fenceProvider, previous) =>
              UserProvider(fenceProvider.fenceServiceClient),
        ),
        ChangeNotifierProxyProvider2<UserProvider, BoutiqueProvider,
            AccessProvider>(
          create: (context) => AccessProvider(
            userProvider: context.read<UserProvider>(),
            boutiqueProvider: context.read<BoutiqueProvider>(),
          ),
          update: (context, userProvider, boutiqueProvider, previous) =>
              AccessProvider(
            userProvider: userProvider,
            boutiqueProvider: boutiqueProvider,
          ),
        ),
        ChangeNotifierProxyProvider<FenceServiceClientProviderV2,
            DeviceProvider>(
          create: (context) {
            final dp = DeviceProvider(
              context.read<FenceServiceClientProviderV2>().fenceServiceClient,
              useServerPermissions: Config.isBffMode,
            );
            _setDeviceProviderPermissions(context, dp);
            return dp;
          },
          update: (context, fenceProvider, previous) {
            final dp = DeviceProvider(
              fenceProvider.fenceServiceClient,
              useServerPermissions: Config.isBffMode,
            );
            _setDeviceProviderPermissions(context, dp);
            return dp;
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          SessionRecoveryBinding.instance.attach(
            SessionRecoveryCoordinator(
              userDataProvider: context.read<UserDataProvider>(),
              accessTokenProvider: context.read<AccessTokenProvider>(),
              persistedTokenProvider:
                  context.read<PersistedTokenProvider<AuthServiceAbstract>>(),
              currentUserProvider: context.read<CurrentUserProvider>(),
              boutiqueProvider: context.read<BoutiqueProvider>(),
              ticketsBoutiqueCache: context.read<TicketsBoutiqueCache>(),
            ),
          );

          return GestureDetector(
            onTap: () {
              // Tap anywhere to dismiss soft keyboard.
              AppFocusHelper.instance.requestUnfocus();
            },
            child: FutureBuilder<bool>(
              initialData: null,
              future: (_future ??= _getScreenDataAsync(
                  context.read<AppPreferencesProvider>(),
                  context.read<UserDataProvider>(),
                  context.read<SharedPreferences>())),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!) {
                  // Sync token from SharedPreferences (UserDataProvider) to AccessTokenProvider
                  // so the boutiques/users packages use it for gRPC calls.
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    if (context.mounted) {
                      final token =
                          context.read<UserDataProvider>().accessToken;
                      if (token.isNotEmpty) {
                        context.read<AccessTokenProvider>().accessToken = token;
                      }
                      // In BFF mode, load current user to get permissions from session
                      if (Config.isBffMode) {
                        final currentUserProvider = context.read<CurrentUserProvider>();
                        await currentUserProvider.load();
                        // CurrentUserProvider will notify listeners when load completes
                      }
                    }
                  });
                  return Consumer<AppPreferencesProvider>(
                    builder: (context, provider, child) {
                      _appRouter ??= appRouter(context.read<UserDataProvider>(),
                          context.read<PermissionProvider>());

                      return MaterialApp.router(
                        debugShowCheckedModeBanner: false,
                        routeInformationProvider:
                            _appRouter!.routeInformationProvider,
                        routeInformationParser:
                            _appRouter!.routeInformationParser,
                        routerDelegate: _appRouter!.routerDelegate,
                        supportedLocales: Lang.delegate.supportedLocales,
                        localizationsDelegates: const [
                          Lang.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                          FormBuilderLocalizations.delegate,
                        ],
                        locale: provider.locale,
                        onGenerateTitle: (context) => 'Weebi',
                        theme: AppThemeData.instance.light(),
                        darkTheme: AppThemeData.instance.dark(),
                        themeMode: provider.themeMode,
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}
