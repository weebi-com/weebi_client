import 'package:flutter_test/flutter_test.dart';

import 'package:charts_weebi_example/main.dart';

void main() {
  testWidgets('example app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const ChartsWeebiExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('charts_weebi — financial charts'), findsOneWidget);
    expect(find.textContaining('Demo data:'), findsOneWidget);
  });
}
