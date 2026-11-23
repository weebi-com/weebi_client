import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_admin/core/theme/themes.dart';
import 'package:web_admin/views/screens/billing/billing_plan_theme.dart';

double _contrastRatio(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('BillingPlanCountBadge contrast', () {
    test('entreprise and premium badge pairs meet WCAG AA', () {
      for (final style in [
        BillingPlanVisual.entreprise,
        BillingPlanVisual.premium,
      ]) {
        expect(
          _contrastRatio(style.buttonBackground, style.buttonForeground),
          greaterThan(4.5),
          reason: 'badge ${style.buttonBackground} / ${style.buttonForeground}',
        );
      }
    });

    testWidgets('entreprise badge is dark indigo on white, not gold on white',
        (tester) async {
      const style = BillingPlanVisual.entreprise;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemeData.instance.light(),
          home: ColoredBox(
            color: style.background,
            child: const Center(
              child: BillingPlanCountBadge(
                label: '1 Licence(s)',
                style: style,
              ),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('1 Licence(s)'));
      expect(text.style?.color, style.buttonForeground);
      expect(text.style?.color, isNot(style.onBackground));

      final decorated = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(BillingPlanCountBadge),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(
        (decorated.decoration as BoxDecoration).color,
        style.buttonBackground,
      );
    });

    testWidgets('premium badge stays navy on gold in dark theme',
        (tester) async {
      const style = BillingPlanVisual.premium;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemeData.instance.dark(),
          home: ColoredBox(
            color: style.background,
            child: const Center(
              child: BillingPlanCountBadge(
                label: '1 License(s)',
                style: style,
              ),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('1 License(s)'));
      expect(text.style?.color, style.buttonForeground);
      final decorated = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(BillingPlanCountBadge),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(
        (decorated.decoration as BoxDecoration).color,
        style.buttonBackground,
      );
    });
  });

  group('dark ColorScheme contrast', () {
    test('core pairs used on billing meet WCAG AA', () {
      final scheme = AppThemeData.instance.dark().colorScheme;
      expect(_contrastRatio(scheme.surface, scheme.onSurface), greaterThan(7));
      expect(
        _contrastRatio(scheme.surface, scheme.onSurfaceVariant),
        greaterThan(4.5),
      );
      expect(_contrastRatio(scheme.error, scheme.onError), greaterThan(4.5));
      expect(
        _contrastRatio(scheme.primaryContainer, scheme.onPrimaryContainer),
        greaterThan(4.5),
      );
    });
  });
}
