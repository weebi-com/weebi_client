// E2E: Stay connected must survive an in-process cold start (tab-close analogue).
//
// Flutter web does not reliably restart between `patrolTest`s (`app.main()`
// hangs the second time), so this simulates tab close by dropping the
// in-memory session id, reloading prefs, and running the same boot restore
// as RootApp.
//
// Run from WSL (Flutter 3.44+ / Dart 3.8+):
// ```sh
// export PATH="$PATH:$HOME/.pub-cache/bin"
// cd webapp
// patrol test -t patrol_test/stay_connected_reload_test.dart -d chrome \
//   --web-headless true --web-locale en-US
// ```
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart' show UserId;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:users_weebi/users_weebi.dart' show FenceServiceClientProviderV2;
import 'package:web_admin/core/constants/values.dart';
import 'package:web_admin/core/services/auth_service.dart';
import 'package:web_admin/core/session/bff_session_store.dart';
import 'package:web_admin/core/session/session_bootstrap.dart';
import 'package:web_admin/grpc/server.dart';
import 'package:web_admin/main_patrol.dart' as app;
import 'package:web_admin/providers/session_recovery.dart';
import 'package:web_admin/providers/user_data_provider.dart';

void main() {
  patrolTest(
    'stay connected restores session after in-process cold start',
    ($) async {
      await app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 60));

      await _loginWithStayConnected($);
      await _expectLoggedIn($);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getBool(SharePrefKeys.stayConnected),
        isTrue,
        reason: 'Stay connected must be persisted as true after login',
      );

      final sessionId = await BffSessionStore.getSessionId();
      expect(
        sessionId,
        isNotNull,
        reason: 'BFF login must persist a sessionId in localStorage',
      );
      expect(sessionId, isNotEmpty);

      final navContext = $.tester.element(find.byType(Navigator).first);
      final fenceClient =
          navContext.read<FenceServiceClientProviderV2>().fenceServiceClient;

      // Tab close analogue: drop Dart heap, keep localStorage. Use a fresh
      // provider so we do not rebuild/dispose the running widget tree.
      BffSessionStore.forgetMemory();
      final coldStart = UserDataProvider();
      await coldStart.loadAsync();
      expect(
        coldStart.isUserLoggedIn(),
        isFalse,
        reason: 'Cold start must not trust prefs until the live probe',
      );
      expect(coldStart.isBffSessionCheckPending, isTrue);

      await SessionBootstrap.restore(
        userDataProvider: coldStart,
        refreshSession: () async {
          final tokens = await AuthService().authenticateWithRefreshToken();
          return SessionRestoreResult(sessionId: tokens.sessionId);
        },
        probeLiveSession: () async {
          await fenceClient.readOneUser(
            UserId(),
            options: authenticatedCallOptions(),
          );
        },
        isDeadSession: SessionRecoveryBinding.instance.isUnauthenticated,
      );

      expect(
        coldStart.isUserLoggedIn(),
        isTrue,
        reason: 'Boot restore/probe must mark the BFF session live',
      );
      expect(await BffSessionStore.getSessionId(), isNotEmpty);
      expect($(#loginSubmitButton), findsNothing);
      await $(#dashboardScreen).waitUntilVisible(
        timeout: const Duration(seconds: 45),
      );
    },
  );
}

Future<void> _loginWithStayConnected(PatrolIntegrationTester $) async {
  await $(#loginMailField).waitUntilVisible(timeout: const Duration(seconds: 30));
  await $(#loginMailField).enterText('dev@weebi.com');
  await $(#loginPasswordField).enterText('weebi.com2');

  final stayConnected = $(#loginStayConnectedCheckbox);
  await stayConnected.waitUntilVisible(timeout: const Duration(seconds: 15));
  await stayConnected.scrollTo();

  await $(#loginSubmitButton).scrollTo().tap();
  await $.pump(const Duration(seconds: 2));
  await $.pumpAndSettle(timeout: const Duration(seconds: 60));
}

Future<void> _expectLoggedIn(PatrolIntegrationTester $) async {
  final dashboard = $(#dashboardScreen);
  try {
    await dashboard.waitUntilVisible(timeout: const Duration(seconds: 45));
  } catch (_) {
    final stillOnLogin = $(#loginSubmitButton).evaluate().isNotEmpty;
    fail(
      'Login did not reach dashboard (stay connected cold-start test).\n'
      'Still on login form: $stillOnLogin',
    );
  }
  expect($(#loginSubmitButton), findsNothing);
}
