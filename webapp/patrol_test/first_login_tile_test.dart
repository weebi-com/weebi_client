/// E2E repro for first-login logout on stats/licenses tiles.
///
/// **Patrol web (recommended):** requires Dart SDK >=3.8 and `patrol` ^4.x:
///   flutter pub global activate patrol_cli
///   patrol test -t patrol_test/first_login_tile_test.dart -d chrome --web-headless true
///
/// **Fallback (current SDK 3.7):** run the mirrored test via flutter drive + chromedriver:
///   chromedriver --port=4444
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/first_login_tile_test.dart -d chrome
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:web_admin/main_patrol.dart' as app;

/// Reproduces the first-login logout bug:
/// login → dashboard → click stats or licenses tile → must stay logged in.
void main() {
  patrolTest(
    'login then stats tile keeps session',
    ($) async {
      await app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 45));

      await $(#loginMailField).enterText('dev@weebi.com');
      await $(#loginPasswordField).enterText('weebi.com2');
      await $(#loginSubmitButton).scrollTo().tap();
      await $.pumpAndSettle(timeout: const Duration(seconds: 45));

      expect($(#dashboardScreen), findsOneWidget);
      expect($(#loginSubmitButton), findsNothing);

      await $(#dashboardStatsTile).scrollTo().tap();
      await $.pumpAndSettle(timeout: const Duration(seconds: 45));

      expect($(#statsScreen), findsOneWidget);
      expect($(#loginSubmitButton), findsNothing);
    },
  );

  patrolTest(
    'login then licenses tile keeps session',
    ($) async {
      await app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 45));

      await $(#loginMailField).enterText('dev@weebi.com');
      await $(#loginPasswordField).enterText('weebi.com2');
      await $(#loginSubmitButton).scrollTo().tap();
      await $.pumpAndSettle(timeout: const Duration(seconds: 45));

      expect($(#dashboardScreen), findsOneWidget);
      expect($(#loginSubmitButton), findsNothing);

      await $(#dashboardLicensesTile).scrollTo().tap();
      await $.pumpAndSettle(timeout: const Duration(seconds: 45));

      expect($(#billingScreen), findsOneWidget);
      expect($(#loginSubmitButton), findsNothing);
    },
  );
}
