import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/catalog/catalog_api.dart';
import 'package:web_admin/catalog/catalog_notifier.dart';
import 'package:web_admin/views/screens/catalog/catalog_list_content.dart';

import '../helpers/l10n_app.dart';

class _FakeCatalogApi implements CatalogApi {
  _FakeCatalogApi(this.store, {this.omitTotal = false});

  final List<CalibrePb> store;
  final bool omitTotal;

  @override
  Future<CalibresResponse> readAll(ReadAllRequest request) async {
    if (omitTotal) {
      return CalibresResponse(calibres: store);
    }
    return CalibresResponse(
      calibres: store,
      total: store.length,
      offset: 0,
      batchSize: store.length,
      hasMore: false,
    );
  }

  @override
  Future<CalibresIdsResponse> readAllIds(ReadIdsRequest request) async =>
      CalibresIdsResponse();

  @override
  Future<CalibrePb> readOne(ReadCalibreRequest request) async => store.first;

  @override
  Future<StatusResponse> createOne(CalibreRequest request) async =>
      StatusResponse();

  @override
  Future<StatusResponse> updateOne(CalibreRequest request) async =>
      StatusResponse();

  @override
  Future<StatusResponse> deleteOne(CalibreRequest request) async =>
      StatusResponse();
}

void main() {
  testWidgets('empty catalog shows create CTA', (tester) async {
    final notifier = CatalogNotifier(
      api: _FakeCatalogApi([]),
      chainId: 'chain-1',
    );
    await notifier.load();
    var created = false;

    await tester.pumpWidget(
      l10nApp(
        home: ChangeNotifierProvider.value(
          value: notifier,
          child: Scaffold(
            body: CatalogListContent(
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

  testWidgets('catalog list shows calibre title from the page', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final calibre = newRetailCalibre(
      id: 1,
      title: 'Cola',
      designation: 'Cola 33cl',
      price: 500,
      cost: 200,
      barcode: '123456',
      unitsInOnePiece: 1,
    );
    final notifier = CatalogNotifier(
      api: _FakeCatalogApi([calibre]),
      chainId: 'chain-1',
    );
    await notifier.load();

    await tester.pumpWidget(
      l10nApp(
        home: ChangeNotifierProvider.value(
          value: notifier,
          child: Scaffold(
            body: CatalogListContent(
              onCreate: () {},
              onOpen: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cola'), findsOneWidget);
    expect(find.text('Cola 33cl'), findsNothing);
    expect(find.text('200'), findsOneWidget);
    expect(find.text('Créer'), findsOneWidget);
    expect(find.text('Type'), findsNothing);
    expect(find.text('Statut'), findsNothing);
  });

  testWidgets('legacy dump without total still shows rows', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final calibre = newRetailCalibre(
      id: 1,
      title: 'Cola',
      designation: 'Cola 33cl',
      price: 500,
      cost: 200,
      barcode: '123456',
      unitsInOnePiece: 1,
    );
    final notifier = CatalogNotifier(
      api: _FakeCatalogApi([calibre], omitTotal: true),
      chainId: 'chain-1',
    );
    await notifier.load();

    await tester.pumpWidget(
      l10nApp(
        home: ChangeNotifierProvider.value(
          value: notifier,
          child: Scaffold(
            body: CatalogListContent(
              onCreate: () {},
              onOpen: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cliquez sur + pour créer un enregistrement.'), findsNothing);
    expect(find.text('Cola'), findsOneWidget);
  });

  testWidgets('inactive calibres are greyed out without a status column',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final calibre = newRetailCalibre(
      id: 1,
      title: 'Old Cola',
      designation: 'Old Cola 33cl',
      price: 500,
      cost: 200,
      barcode: '123456',
      unitsInOnePiece: 1,
    )..status = false;
    final notifier = CatalogNotifier(
      api: _FakeCatalogApi([calibre]),
      chainId: 'chain-1',
    );
    await notifier.load();

    await tester.pumpWidget(
      l10nApp(
        home: ChangeNotifierProvider.value(
          value: notifier,
          child: Scaffold(
            body: CatalogListContent(
              onCreate: () {},
              onOpen: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final name = tester.widget<Text>(find.text('Old Cola'));
    expect(name.style?.color, Colors.grey);
    expect(find.text('Statut'), findsNothing);
    expect(find.text('Type'), findsNothing);
  });
}
