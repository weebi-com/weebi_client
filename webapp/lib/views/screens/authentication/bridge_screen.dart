import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/core/billing/billing_bridge_destination.dart';
import 'package:web_admin/core/services/auth_service.dart';
import 'package:web_admin/providers/current_user_provider.dart';
import 'package:web_admin/providers/user_data_provider.dart';

/// Consumes App->Web magic-link token, establishes BFF session, opens billing.
class BridgeScreen extends StatefulWidget {
  const BridgeScreen({super.key});

  @override
  State<BridgeScreen> createState() => _BridgeScreenState();
}

class _BridgeScreenState extends State<BridgeScreen> {
  String? _error;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    if (_started) return;
    _started = true;

    final query = billingQueryParamsFromLocation();
    final token = bridgeTokenFromQuery(query);
    final destination = parseBillingBridgeDestination(
      query: query,
      requireToken: true,
    );

    if (token == null || destination == null) {
      setState(() => _error = 'Invalid or incomplete magic link.');
      return;
    }

    try {
      final auth = AuthService();
      final tokens = await auth.exchangeWebBridgeToken(token);
      if (tokens.sessionId.isEmpty) {
        setState(() => _error = 'Could not open a web session from this link.');
        return;
      }

      if (!mounted) return;

      // Mark legacy go_router gate as logged-in *before* readOneUser / billing
      // navigation so refreshListenable cannot bounce us to /login mid-bridge.
      await context.read<UserDataProvider>().setUserDataAsync(
            mail: 'bridge@weebi',
            userProfileImageUrl:
                'https://www.weebi.com/images/Weebi_Logo_Full.png',
            bffSessionLive: true,
          );

      if (!mounted) return;
      final currentUser = context.read<CurrentUserProvider>();
      currentUser.clear();
      final user = await currentUser.load(force: true);
      if (!mounted) return;

      if (user?.mail.isNotEmpty == true) {
        await context.read<UserDataProvider>().setUserDataAsync(
              mail: user!.mail,
            );
      }

      if (!mounted) return;
      GoRouter.of(context).go(destination.billingLocation);
    } on GrpcError catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message ?? 'Magic link expired or already used.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Magic link expired or already used.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        key: const Key('bridgeScreen'),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    key: const Key('bridgeErrorText'),
                    _error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const Key('bridgeGoToLoginButton'),
                    onPressed: () => GoRouter.of(context).go(RouteUri.login),
                    child: const Text('Go to login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      key: Key('bridgeScreen'),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
