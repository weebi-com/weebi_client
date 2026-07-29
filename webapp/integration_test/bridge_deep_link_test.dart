import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/main_patrol.dart' as app;

/// Browser fallback when Patrol CLI is unavailable (Dart SDK < 3.8).
///
/// ```sh
/// flutter test integration_test/bridge_deep_link_test.dart -d chrome
/// ```
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('logged-out /bridge stays on bridge (not auto login redirect)',
      (tester) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 45));

    final navContext = tester.element(find.byType(Navigator).first);
    GoRouter.of(navContext).go(RouteUri.bridge);
    await tester.pumpAndSettle(const Duration(seconds: 20));

    expect(find.byKey(const Key('bridgeScreen')), findsOneWidget);
    expect(
      find.byKey(const Key('loginSubmitButton')),
      findsNothing,
      reason:
          'Auth redirect must not kick /bridge to login; bridge is unrestricted',
    );
    expect(find.byKey(const Key('bridgeErrorText')), findsOneWidget);
    expect(find.byKey(const Key('bridgeGoToLoginButton')), findsOneWidget);
  });
}
