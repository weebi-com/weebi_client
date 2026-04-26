import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_admin/core/theme/themes.dart';
import 'package:web_admin/generated/l10n.dart';

/// Tests that the forgot password feature exists and is visible.
/// These tests avoid importing LoginScreen (which pulls in grpc/web) so they
/// run on the VM. We verify the l10n strings and that a widget with the
/// forgot password text can be found when rendered.
void main() {
  group('Forgot password', () {
    testWidgets('forgotPassword l10n string displays "Forgot password?" in English',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemeData.instance.light(),
          localizationsDelegates: const [
            Lang.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: Lang.delegate.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) => Text(Lang.of(context).forgotPassword),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Forgot password?'), findsOneWidget);
    });

    testWidgets('forgotPasswordTitle l10n string exists for dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemeData.instance.light(),
          localizationsDelegates: const [
            Lang.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: Lang.delegate.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) => Text(Lang.of(context).forgotPasswordTitle),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Forgot password'), findsOneWidget);
    });
  });
}
