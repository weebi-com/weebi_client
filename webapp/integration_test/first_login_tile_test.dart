import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web_admin/main_patrol.dart' as app;

/// Browser integration test (runs with `flutter test integration_test/... -d chrome`).
/// Patrol 4 web requires Dart SDK >=3.8; this file is the runnable fallback on SDK 3.7.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login then stats tile keeps session', (tester) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 45));

    await tester.enterText(find.byKey(const Key('loginMailField')), 'dev@weebi.com');
    await tester.enterText(find.byKey(const Key('loginPasswordField')), 'weebi.com2');
    await tester.tap(find.byKey(const Key('loginSubmitButton')));
    await tester.pumpAndSettle(const Duration(seconds: 45));

    expect(find.byKey(const Key('dashboardScreen')), findsOneWidget);
    expect(find.byKey(const Key('loginSubmitButton')), findsNothing);

    await tester.tap(find.byKey(const Key('dashboardStatsTile')));
    await tester.pumpAndSettle(const Duration(seconds: 45));

    expect(find.byKey(const Key('statsScreen')), findsOneWidget);
    expect(find.byKey(const Key('loginSubmitButton')), findsNothing);
  });

  testWidgets('login then licenses tile keeps session', (tester) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 45));

    await tester.enterText(find.byKey(const Key('loginMailField')), 'dev@weebi.com');
    await tester.enterText(find.byKey(const Key('loginPasswordField')), 'weebi.com2');
    await tester.tap(find.byKey(const Key('loginSubmitButton')));
    await tester.pumpAndSettle(const Duration(seconds: 45));

    expect(find.byKey(const Key('dashboardScreen')), findsOneWidget);
    expect(find.byKey(const Key('loginSubmitButton')), findsNothing);

    await tester.tap(find.byKey(const Key('dashboardLicensesTile')));
    await tester.pumpAndSettle(const Duration(seconds: 45));

    expect(find.byKey(const Key('billingScreen')), findsOneWidget);
    expect(find.byKey(const Key('loginSubmitButton')), findsNothing);
  });
}
