import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/contacts/provider/contacts_provider.dart';
import 'package:web_admin/views/screens/contacts/contacts_list_content.dart';

import '../helpers/l10n_app.dart';

class _FakeDirectoryApi implements DirectoryApi {
  _FakeDirectoryApi(this.store);

  final List<ContactPb> store;

  @override
  Future<ContactsResponse> readAll(ReadAllContactsRequest request) async {
    return ContactsResponse(
      contacts: store,
      total: store.length,
      offset: 0,
      batchSize: store.length,
      hasMore: false,
    );
  }

  @override
  Future<ContactsIdsResponse> readAllIds(ReadContactsIdsRequest request) async =>
      ContactsIdsResponse();

  @override
  Future<ContactPb> readOne(ReadContactRequest request) async => store.first;

  @override
  Future<StatusResponse> createOne(ContactRequest request) async =>
      StatusResponse();

  @override
  Future<StatusResponse> updateOne(ContactRequest request) async =>
      StatusResponse();

  @override
  Future<StatusResponse> deleteOne(ContactRequest request) async =>
      StatusResponse();
}

void main() {
  testWidgets('empty contacts list shows create CTA', (tester) async {
    final notifier = ContactsNotifier(
      api: _FakeDirectoryApi([]),
      chainId: 'chain-1',
    );
    await notifier.load();
    var created = false;

    await tester.pumpWidget(
      l10nApp(
        home: ChangeNotifierProvider.value(
          value: notifier,
          child: Scaffold(
            body: ContactsListContent(
              onCreate: () => created = true,
              onOpen: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Cliquez sur + pour créer un enregistrement.'), findsOneWidget);
    expect(find.text('Créer'), findsOneWidget);
    await tester.tap(find.text('Créer'));
    expect(created, isTrue);
  });

  testWidgets('contacts list shows name columns', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final contact = ContactPb.create()
      ..id = 1
      ..firstName = 'Ada'
      ..lastName = 'Lovelace'
      ..mail = 'ada@weebi.com'
      ..status = true
      ..isClient = true;
    final notifier = ContactsNotifier(
      api: _FakeDirectoryApi([contact]),
      chainId: 'chain-1',
    );
    await notifier.load();

    await tester.pumpWidget(
      l10nApp(
        home: ChangeNotifierProvider.value(
          value: notifier,
          child: Scaffold(
            body: ContactsListContent(
              onCreate: () {},
              onOpen: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lovelace'), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('ada@weebi.com'), findsOneWidget);
    expect(find.text('Créer'), findsOneWidget);
  });
}
