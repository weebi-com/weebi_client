// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/contacts/contacts.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockContactServiceClient implements ContactServiceClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ContactsPage', () {
    group('route', () {
      test('is routable', () {
        expect(ContactsPage.route('chainId'), isA<MaterialPageRoute>());
      });
    });

    testWidgets('renders ContactsView', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockClient = _MockContactServiceClient();
      await tester.pumpWidget(
        Provider<ContactServiceClient>.value(
          value: mockClient,
          child: MaterialApp(
            home: ContactsPage('chainId'),
          ),
        ),
      );
      expect(find.byType(ContactsView), findsOneWidget);
    });
  });
}
