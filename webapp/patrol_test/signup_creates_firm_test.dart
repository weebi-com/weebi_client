/// E2E: webapp signup must create a firm (not leave the user firmless).
///
/// Mirrors fence `user_journeys_test`: signUp → authent → createFirm → refresh.
/// After success the user is logged in, `firmId` is set, and `Right.create`
/// on firm is gone.
///
/// Run from WSL (Flutter 3.44+ / Dart 3.8+):
/// ```sh
/// export PATH="$PATH:$HOME/.pub-cache/bin"
/// cd webapp
/// patrol test -t patrol_test/signup_creates_firm_test.dart -d chrome \
///   --web-headless true --web-locale en-US
/// ```
import 'package:auth_weebi/auth_weebi.dart' show PermissionProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:patrol/patrol.dart';
import 'package:provider/provider.dart';
import 'package:web_admin/core/routing/routes.dart';
import 'package:web_admin/core/session/bff_session_store.dart';
import 'package:web_admin/main_patrol.dart' as app;
import 'package:web_admin/providers/current_user_provider.dart';

void main() {
  patrolTest(
    'signup creates a firm and lands logged in with firmId',
    ($) async {
      await app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 60));

      final stamp = DateTime.now().millisecondsSinceEpoch;
      final firmName = 'Patrol Firm $stamp';
      final mail = 'p.$stamp@weebi.com';
      const password = 'patrol1234';

      await $(#loginRegisterNowButton).waitUntilVisible(
        timeout: const Duration(seconds: 30),
      );
      await $(#loginRegisterNowButton).tap();
      await $.pumpAndSettle(timeout: const Duration(seconds: 30));

      await $(#registerScreen).waitUntilVisible(
        timeout: const Duration(seconds: 30),
      );
      await $(#registerFirmNameField).enterText(firmName);
      await $(#registerFirstNameField).enterText('Patrol');
      await $(#registerLastNameField).enterText('Signup');
      await $(#registerMailField).enterText(mail);
      await $(#registerPasswordField).enterText(password);
      await $(#registerRetypePasswordField).enterText(password);
      await $(#registerSubmitButton).scrollTo().tap();
      await $.pump(const Duration(seconds: 2));
      await $.pumpAndSettle(timeout: const Duration(seconds: 90));

      await _expectSignupReachedDashboard($);

      expect(
        $(#createFirmScreen),
        findsNothing,
        reason: 'Successful signup must not recover onto /create-firm '
            '(that means createFirm never ran)',
      );
      expect($(#loginSubmitButton), findsNothing);
      expect($(#registerSubmitButton), findsNothing);

      final sessionId = await BffSessionStore.getSessionId();
      expect(
        sessionId,
        isNotNull,
        reason: 'BFF signup must persist a sessionId after createFirm+refresh',
      );
      expect(sessionId, isNotEmpty);

      await $(#dashboardFirmTile).scrollTo().tap();
      await $.pumpAndSettle(timeout: const Duration(seconds: 60));

      await $(#firmOverviewBody).waitUntilVisible(
        timeout: const Duration(seconds: 45),
      );
      expect(
        $(#createFirmCtaButton),
        findsNothing,
        reason: 'Firm page CTA is the firmless recovery path',
      );

      final nameText = _widgetText($, #firmNameValue);
      expect(
        nameText,
        firmName,
        reason: 'Firm overview must show the name submitted at signup',
      );

      final firmIdText = _widgetText($, #firmIdValue);
      expect(firmIdText, isNotEmpty, reason: 'firmId must be assigned');

      final navContext = $.tester.element(find.byType(Navigator).first);
      final currentUser =
          Provider.of<CurrentUserProvider>(navContext, listen: false);
      expect(
        currentUser.firmId,
        isNotEmpty,
        reason: 'CurrentUserProvider.firmId must be set after signup',
      );
      expect(currentUser.firmId, firmIdText);

      final permissions =
          Provider.of<PermissionProvider>(navContext, listen: false);
      expect(permissions.firmId, firmIdText);
      expect(
        permissions.canCreateFirm,
        isFalse,
        reason: 'After createFirm, Right.create is removed (journey test)',
      );
      expect(
        permissions.canReadFirm,
        isTrue,
        reason: 'After createFirm+refresh, the boss can read the firm',
      );

      // Same session: dashboard must remain authenticated (web hang if restart).
      GoRouter.of(navContext).go(RouteUri.dashboard);
      await $.pumpAndSettle(timeout: const Duration(seconds: 30));
      await $(#dashboardScreen).waitUntilVisible(
        timeout: const Duration(seconds: 45),
      );
      expect($(#loginSubmitButton), findsNothing);
      expect($(#createFirmScreen), findsNothing);
    },
  );
}

String _widgetText(PatrolIntegrationTester $, Object key) {
  final finder = $(key);
  final text = finder.evaluate().single.widget;
  if (text is Text) {
    return text.data ?? text.textSpan?.toPlainText() ?? '';
  }
  if (text is SelectableText) {
    return text.data ?? text.textSpan?.toPlainText() ?? '';
  }
  fail('Expected Text/SelectableText for $key, got ${text.runtimeType}');
}

Future<void> _expectSignupReachedDashboard(PatrolIntegrationTester $) async {
  final dashboard = $(#dashboardScreen);
  try {
    await dashboard.waitUntilVisible(timeout: const Duration(seconds: 60));
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
          lower.contains('firm') ||
          lower.contains('signup') ||
          lower.contains('register') ||
          lower.contains('http request')) {
        errorTexts.add(value);
      }
    }

    fail(
      'Signup did not reach dashboard.\n'
      'Still on register: ${$(#registerSubmitButton).evaluate().isNotEmpty}\n'
      'On login: ${$(#loginSubmitButton).evaluate().isNotEmpty}\n'
      'On create-firm (firmless): ${$(#createFirmScreen).evaluate().isNotEmpty}\n'
      'Visible error-like texts: ${errorTexts.isEmpty ? '(none found)' : errorTexts.join(' | ')}\n'
      'Likely causes: createFirm unauthenticated in BFF, session cookie missing, '
      'or signup returned success without persisting the session.',
    );
  }
}
