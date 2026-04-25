// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/contacts/contacts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContactsBody', () {
    testWidgets('renders Text', (tester) async {
      await tester.pumpWidget(
        Provider(
          create: (context) => ChangeNotifierProvider(
              create: (_) => ContactsNotifier(
                  context.read<ContactServiceClient>(), 'chainId')),
          child: MaterialApp(home: ContactsBody()),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
    });
  });
}
