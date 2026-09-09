import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_admin/views/widgets/entity/entity_chrome.dart';

void main() {
  testWidgets('empty state calls onCreate', (tester) async {
    var created = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EntityEmptyState(
            message: 'Click + to create a record.',
            actionLabel: 'Create',
            onCreate: () => created = true,
          ),
        ),
      ),
    );

    expect(find.text('Click + to create a record.'), findsOneWidget);
    await tester.tap(find.text('Create'));
    expect(created, isTrue);
  });
}
