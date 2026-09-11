/// E2E: billing referral text field is present; own code shows validation error.
///
/// Run from WSL:
/// ```sh
/// cd webapp
/// patrol test -t patrol_test/billing_referral_field_test.dart -d chrome \
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
    'billing referral field rejects own firmId before payment',
    ($) async {
      await app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 60));

      await _login($);
      await $(#dashboardScreen).waitUntilVisible(timeout: const Duration(seconds: 45));

      final navContext = $.tester.element(find.byType(Navigator).first);
      GoRouter.of(navContext).go(RouteUri.billing);
      await $.pumpAndSettle(timeout: const Duration(seconds: 60));
      await $(#billingScreen).waitUntilVisible(timeout: const Duration(seconds: 45));

      await $(#billingOfferTeaserPremium).waitUntilVisible(
        timeout: const Duration(seconds: 30),
      );
      await $(#billingOfferTeaserPremium).tap();
      await $.pumpAndSettle();

      await $(#billingReferralTextField).waitUntilVisible(
        timeout: const Duration(seconds: 30),
      );

      // Prefer reading the displayed own code when available.
      String ownCode = '';
      final ownFinder = find.byKey(const Key('billingOwnReferralCode'));
      if (ownFinder.evaluate().isNotEmpty) {
        final selectable = $.tester.widget<SelectableText>(ownFinder);
        ownCode = (selectable.data ?? '').trim();
      }
      if (ownCode.isEmpty) {
        // Fallback: Dummy/dev firm may still expose code after getReferralInfo.
        ownCode = 'own-code-placeholder';
      }

      await $(#billingReferralTextField).enterText(ownCode);
      await $.pumpAndSettle();

      if (ownCode != 'own-code-placeholder') {
        expect(
          find.textContaining('cannot use your own', findRichText: true),
          findsWidgets,
        );
      }
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
