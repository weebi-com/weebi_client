import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_admin/views/widgets/entity/entity_chrome.dart';

void main() {
  testWidgets('save button is disabled when onSave is null', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EntityEditHeader(
            title: 'New product',
            onSave: null,
            onCancel: _noop,
            saveLabel: 'Save',
            cancelLabel: 'Cancel',
          ),
        ),
      ),
    );

    final save =
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'));
    expect(save.onPressed, isNull);
  });
}

void _noop() {}
