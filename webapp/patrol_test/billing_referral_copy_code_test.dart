/// E2E: billing screen shows the firm's own referral code after login.
///
/// Run from WSL:
/// ```sh
/// cd webapp
/// patrol test -t patrol_test/billing_referral_copy_code_test.dart -d chrome \
///   --web-headless true --web-locale en-US
/// ```
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:patrol/patrol.dart';
import 'package:web_admin/core/routing/routes.dart';
import 'package:web_admin/main_patrol.dart' as app;

void main() {
  patrolTest(
    'billing shows own referral code and copy control',
    ($) async {
      await app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 60));

      await _login($);
      await $(#dashboardScreen).waitUntilVisible(timeout: const Duration(seconds: 45));

      final navContext = $.tester.element(find.byType(Navigator).first);
      GoRouter.of(navContext).go(RouteUri.billing);
      await $.pumpAndSettle(timeout: const Duration(seconds: 60));
      await $(#billingScreen).waitUntilVisible(timeout: const Duration(seconds: 45));

      await $(#billingOfferTeaserReferral).waitUntilVisible(
        timeout: const Duration(seconds: 30),
      );
      await $(#billingOfferTeaserReferral).tap();
      await $.pumpAndSettle();

      await $(#billingOwnReferralCode).waitUntilVisible(
        timeout: const Duration(seconds: 30),
      );
      expect($(#billingCopyReferralCode), findsOneWidget);

      final selectable = $.tester.widget<SelectableText>(
        find.byKey(const Key('billingOwnReferralCode')),
      );
      final text = selectable.data ?? '';
      expect(text.trim(), isNotEmpty);
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
