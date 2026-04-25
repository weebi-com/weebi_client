// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:web_admin/contacts/contacts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContactsPage', () {
    group('route', () {
      test('is routable', () {
        expect(ContactsPage.route('chainId'), isA<MaterialPageRoute>());
      });
    });

    testWidgets('renders ContactsView', (tester) async {
      await tester.pumpWidget(MaterialApp(home: ContactsPage('chainId')));
      expect(find.byType(ContactsView), findsOneWidget);
    });
  });
}
