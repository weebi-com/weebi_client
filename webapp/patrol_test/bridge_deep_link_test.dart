/// Patrol: magic-link /bridge must not be bounced to login by legacy auth gate.
///
/// Run from WSL (Flutter 3.44+ / Dart 3.8+):
/// ```sh
/// export PATH="$PATH:$HOME/.pub-cache/bin"
/// cd webapp
/// patrol test -t patrol_test/bridge_deep_link_test.dart -d chrome \
///   --web-headless true --web-locale en-US
/// ```
///
/// Without a live one-time token we assert the cold path that previously
/// failed: open `/bridge` while logged out → stay on bridge (error UI), never
/// auto-redirect to the login form.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:patrol/patrol.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/main_patrol.dart' as app;

void main() {
  patrolTest(
    'logged-out /bridge stays on bridge (not auto login redirect)',
    ($) async {
      await app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 60));

      // Cold start without session lands on login; navigate like a deep link.
      final navContext = $.tester.element(find.byType(Navigator).first);
      GoRouter.of(navContext).go(RouteUri.bridge);
      await $.pumpAndSettle(timeout: const Duration(seconds: 30));

      await $(#bridgeScreen).waitUntilVisible(
        timeout: const Duration(seconds: 30),
      );

      expect(
        $(#loginSubmitButton),
        findsNothing,
        reason:
            'Auth redirect must not kick /bridge to login; bridge is unrestricted',
      );

      await $(#bridgeErrorText).waitUntilVisible(
        timeout: const Duration(seconds: 15),
      );
      expect($(#bridgeGoToLoginButton), findsOneWidget);
    },
  );
}
