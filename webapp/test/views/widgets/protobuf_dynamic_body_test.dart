import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/views/widgets/protobuf/protobuf_dynamic_body.dart';

void main() {
  testWidgets('renders scalar ContactPb fields from proto descriptors',
      (tester) async {
    final contact = ContactPb.create()
      ..firstName = 'Ada'
      ..lastName = 'Lovelace'
      ..mail = 'ada@weebi.com'
      ..status = true
      ..isClient = true;

      await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProtobufDynamicBody(pbObject: contact),
          ),
        ),
      ),
    );

    expect(find.text('First Name'), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Last Name'), findsOneWidget);
    expect(find.text('Lovelace'), findsOneWidget);
    expect(find.text('ada@weebi.com'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsWidgets);
  });

  testWidgets('skips listed field names', (tester) async {
    final contact = ContactPb.create()
      ..firstName = 'Ada'
      ..mail = 'hidden@weebi.com';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProtobufDynamicBody(
              pbObject: contact,
              skipFieldNames: const ['mail'],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('hidden@weebi.com'), findsNothing);
  });

  testWidgets('recurses nested Address instead of toString', (tester) async {
    final contact = ContactPb.create()
      ..firstName = 'Marie'
      ..addressFull = (Address.create()
        ..street = 'Rue des Fleurs'
        ..city = 'Dakar'
        ..code = '10000');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProtobufDynamicBody(pbObject: contact),
          ),
        ),
      ),
    );

    expect(find.text('Rue des Fleurs'), findsOneWidget);
    expect(find.text('Dakar'), findsOneWidget);
  });

  testWidgets('recurses nested ArticleRetailPb on a calibre', (tester) async {
    final calibre = CalibrePb.create()
      ..id = 7
      ..title = 'Cola'
      ..kind = ArticleKindPb.retail
      ..articlesRetail.add(
        ArticleRetailPb.create()
          ..id = 1
          ..designation = 'Cola 33cl'
          ..price = 500
          ..barcodeEAN = '123456',
      );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProtobufDynamicBody(
              pbObject: calibre,
              skipFieldNames: const ['codeShortcut'],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Cola'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Cola 33cl'), findsOneWidget);
    expect(find.text('123456'), findsOneWidget);
  });

  testWidgets('renders Phone without a dedicated Contact widget', (tester) async {
    final contact = ContactPb.create()
      ..firstName = 'Ada'
      ..phone = (Phone.create()
        ..countryCode = 221
        ..number = '770000000');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProtobufDynamicBody(pbObject: contact),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('770000000'), findsWidgets);
    expect(find.textContaining('+221'), findsWidgets);
  });
}
