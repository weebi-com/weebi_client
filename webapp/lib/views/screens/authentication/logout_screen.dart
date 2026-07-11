import 'package:flutter/material.dart';
import 'package:auth_weebi/auth_weebi.dart'
    show AccessTokenProvider, AuthServiceAbstract, PersistedTokenProvider;
import 'package:boutiques_weebi/boutiques_weebi.dart' show BoutiqueProvider;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/providers/current_user_provider.dart';
import 'package:web_admin/providers/operational_license_gate.dart';
import 'package:web_admin/providers/tickets_boutique_cache.dart';
import 'package:web_admin/providers/user_data_provider.dart';
import 'package:web_admin/core/session/bff_session_store.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  Future<void> _doLogoutAsync({
    required UserDataProvider userDataProvider,
    required AccessTokenProvider accessTokenProvider,
    required PersistedTokenProvider<AuthServiceAbstract> persistedTokenProvider,
    required CurrentUserProvider currentUserProvider,
    required BoutiqueProvider boutiqueProvider,
    required TicketsBoutiqueCache ticketsBoutiqueCache,
    required VoidCallback onSuccess,
  }) async {
    await userDataProvider.clearSessionDataAsync();
    await BffSessionStore.clear();
    accessTokenProvider.clearAccessToken();
    await persistedTokenProvider.clearAccessToken();
    await persistedTokenProvider.clearRefreshToken();
    currentUserProvider.clear();
    boutiqueProvider.clearSession();
    ticketsBoutiqueCache.clear();
    OperationalLicenseGateBinding.instance.clear();

    onSuccess.call();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final router = GoRouter.of(context);
      final userDataProvider = context.read<UserDataProvider>();
      final accessTokenProvider = context.read<AccessTokenProvider>();
      final persistedTokenProvider =
          context.read<PersistedTokenProvider<AuthServiceAbstract>>();
      final currentUserProvider = context.read<CurrentUserProvider>();
      final boutiqueProvider = context.read<BoutiqueProvider>();
      final ticketsBoutiqueCache = context.read<TicketsBoutiqueCache>();

      // Clear local user data and redirect to login screen.
      await (_doLogoutAsync(
        userDataProvider: userDataProvider,
        accessTokenProvider: accessTokenProvider,
        persistedTokenProvider: persistedTokenProvider,
        currentUserProvider: currentUserProvider,
        boutiqueProvider: boutiqueProvider,
        ticketsBoutiqueCache: ticketsBoutiqueCache,
        onSuccess: () => router.go(RouteUri.login),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
