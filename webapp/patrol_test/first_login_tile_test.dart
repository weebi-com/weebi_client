/// E2E: login → dashboard → stats/licenses tile must stay authenticated.
///
/// Run from WSL (Flutter 3.44+ / Dart 3.8+):
/// ```sh
/// export PATH="$PATH:$HOME/.pub-cache/bin"
/// cd webapp
/// patrol test -t patrol_test/first_login_tile_test.dart -d chrome \
///   --web-headless true --web-locale en-US
/// ```
///
/// Note: the test browser origin is `http://localhost:<port>`. Envoy CORS must
/// allow that origin (and credentials) or login will fail before the dashboard.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:patrol/patrol.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/core/session/bff_session_store.dart';
import 'package:web_admin/main_patrol.dart' as app;

void main() {
  // Single patrolTest: Flutter web does not reliably restart between cases,
  // so a second `app.main()` hangs after the first scenario.
  patrolTest(
    'login then stats and licenses tiles keep session',
    ($) async {
      await app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 60));

      await _login($);
      await _expectLoggedIn($);

      final sessionId = await BffSessionStore.getSessionId();
      expect(
        sessionId,
        isNotNull,
        reason: 'BFF login must return and persist a sessionId',
      );
      expect(sessionId, isNotEmpty);

      await $(#dashboardStatsTile).scrollTo().tap();
      await $.pumpAndSettle(timeout: const Duration(seconds: 60));

      expect(
        $(#loginSubmitButton),
        findsNothing,
        reason: 'Navigating to stats must not log the user out',
      );
      await $(#statsScreen).waitUntilVisible(timeout: const Duration(seconds: 45));

      // Same session: return to dashboard without restarting the app (web hang).
      final navContext = $.tester.element(find.byType(Navigator).first);
      GoRouter.of(navContext).go(RouteUri.dashboard);
      await $.pumpAndSettle(timeout: const Duration(seconds: 30));
      await $(#dashboardScreen).waitUntilVisible(timeout: const Duration(seconds: 45));

      await $(#dashboardLicensesTile).scrollTo().tap();
      await $.pumpAndSettle(timeout: const Duration(seconds: 60));

      expect(
        $(#loginSubmitButton),
        findsNothing,
        reason: 'Navigating to licenses must not log the user out',
      );
      await $(#billingScreen).waitUntilVisible(timeout: const Duration(seconds: 45));
    },
  );
}

Future<void> _login(PatrolIntegrationTester $) async {
  await $(#loginMailField).waitUntilVisible(timeout: const Duration(seconds: 30));
  await $(#loginMailField).enterText('dev@weebi.com');
  await $(#loginPasswordField).enterText('weebi.com2');
  await $(#loginSubmitButton).scrollTo().tap();
  await $.pump(const Duration(seconds: 2));
  await $.pumpAndSettle(timeout: const Duration(seconds: 60));
}

Future<void> _expectLoggedIn(PatrolIntegrationTester $) async {
  // Prefer waiting for dashboard; if login failed, surface CORS/auth errors.
  final dashboard = $(#dashboardScreen);
  try {
    await dashboard.waitUntilVisible(timeout: const Duration(seconds: 45));
  } catch (_) {
    final errorTexts = <String>[];
    for (final text in $.tester.widgetList<Text>(find.byType(Text))) {
      final value = text.data ?? text.textSpan?.toPlainText() ?? '';
      if (value.isEmpty) continue;
      final lower = value.toLowerCase();
      if (lower.contains('cors') ||
          lower.contains('error') ||
          lower.contains('grpc') ||
          lower.contains('unauthenticated') ||
          lower.contains('http request')) {
        errorTexts.add(value);
      }
    }

    final stillOnLogin = $(#loginSubmitButton).evaluate().isNotEmpty;
    fail(
      'Login did not reach dashboard.\n'
      'Still on login form: $stillOnLogin\n'
      'Visible error-like texts: ${errorTexts.isEmpty ? '(none found)' : errorTexts.join(' | ')}\n'
      'Likely causes: Envoy CORS blocking localhost origin, session cookie not set, '
      'or authenticateWithCredentials failed.',
    );
  }

  expect($(#loginSubmitButton), findsNothing);
}
