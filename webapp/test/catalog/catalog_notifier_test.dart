import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/catalog/catalog_api.dart';
import 'package:web_admin/catalog/catalog_ids.dart';
import 'package:web_admin/catalog/catalog_notifier.dart';

class _FakeCatalogApi implements CatalogApi {
  _FakeCatalogApi(this.store);

  final List<CalibrePb> store;
  ReadAllRequest? lastReadAll;

  @override
  Future<CalibresResponse> readAll(ReadAllRequest request) async {
    lastReadAll = request;
    var filtered = store.where((c) {
      if (request.statusFilter == 1 && !c.status) return false;
      if (request.statusFilter == 2 && c.status) return false;
      final q = request.query.trim().toLowerCase();
      if (q.isEmpty) return true;
      final designation =
          c.articlesRetail.isEmpty ? '' : c.articlesRetail.first.designation;
      final barcode =
          c.articlesRetail.isEmpty ? '' : c.articlesRetail.first.barcodeEAN;
      return c.title.toLowerCase().contains(q) ||
          designation.toLowerCase().contains(q) ||
          barcode.toLowerCase().contains(q);
    }).toList();
    final total = filtered.length;
    if (request.limit > 0) {
      final end = (request.offset + request.limit).clamp(0, filtered.length);
      filtered = filtered.sublist(
        request.offset.clamp(0, filtered.length),
        end,
      );
    }
    return CalibresResponse(
      calibres: filtered,
      total: total,
      offset: request.offset,
      batchSize: filtered.length,
      hasMore: request.offset + filtered.length < total,
    );
  }

  @override
  Future<CalibresIdsResponse> readAllIds(ReadIdsRequest request) async {
    return CalibresIdsResponse(ids: store.map((c) => c.id));
  }

  @override
  Future<CalibrePb> readOne(ReadCalibreRequest request) async {
    return store.firstWhere((c) => c.id == request.calibreId);
  }

  @override
  Future<StatusResponse> createOne(CalibreRequest request) async {
    store.add(request.calibre);
    return StatusResponse(type: StatusResponse_Type.CREATED);
  }

  @override
  Future<StatusResponse> updateOne(CalibreRequest request) async {
    final i = store.indexWhere((c) => c.id == request.calibre.id);
    if (i >= 0) store[i] = request.calibre;
    return StatusResponse(type: StatusResponse_Type.UPDATED);
  }

  @override
  Future<StatusResponse> deleteOne(CalibreRequest request) async {
    store.removeWhere((c) => c.id == request.calibre.id);
    return StatusResponse(type: StatusResponse_Type.DELETED);
  }
}

/// Mimics a deployed server that dumps all calibres and never sets [CalibresResponse.total].
class _LegacyDumpCatalogApi implements CatalogApi {
  _LegacyDumpCatalogApi(this.store);

  final List<CalibrePb> store;

  @override
  Future<CalibresResponse> readAll(ReadAllRequest request) async {
    return CalibresResponse(calibres: store);
  }

  @override
  Future<CalibresIdsResponse> readAllIds(ReadIdsRequest request) async =>
      CalibresIdsResponse(ids: store.map((c) => c.id));

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

CalibrePb _calibre(int id, String title, {bool status = true}) {
  return newRetailCalibre(
    id: id,
    title: title,
    designation: '$title pack',
    price: 10,
    cost: 5,
    barcode: '$id$id$id',
    unitsInOnePiece: 1,
  )..status = status;
}

void main() {
  test('nextPositiveId is max plus one', () {
    expect(nextPositiveId(const []), 1);
    expect(nextPositiveId(const [1, 7, 3]), 8);
  });

  test('load sends pagination query to the API', () async {
    final api = _FakeCatalogApi([
      _calibre(1, 'Cola'),
      _calibre(2, 'Chips'),
      _calibre(3, 'Soap'),
    ]);
    final notifier = CatalogNotifier(api: api, chainId: 'chain-1', pageSize: 2);
    await notifier.load();
    expect(api.lastReadAll!.limit, 2);
    expect(api.lastReadAll!.offset, 0);
    expect(notifier.items, hasLength(2));
    expect(notifier.total, 3);
    expect(notifier.hasMore, isTrue);
  });

  test('setQuery resets offset and filters', () async {
    final api = _FakeCatalogApi([
      _calibre(1, 'Cola'),
      _calibre(2, 'Chips'),
    ]);
    final notifier = CatalogNotifier(api: api, chainId: 'chain-1', pageSize: 20);
    await notifier.setPage(20);
    await notifier.setQuery('cola');
    expect(notifier.offset, 0);
    expect(notifier.items.single.title, 'Cola');
    expect(api.lastReadAll!.query, 'cola');
  });

  test('save create then appears in list', () async {
    final api = _FakeCatalogApi([]);
    final notifier = CatalogNotifier(api: api, chainId: 'chain-1');
    final created = newRetailCalibre(
      id: 1,
      title: 'Milk',
      designation: 'Milk 1L',
      price: 800,
      cost: 500,
      barcode: '999',
      unitsInOnePiece: 1,
    );
    final ok = await notifier.save(created, isNew: true);
    expect(ok, isTrue);
    expect(notifier.items.single.title, 'Milk');
  });

  test('load treats missing total as the returned list length (legacy server)',
      () async {
    final api = _LegacyDumpCatalogApi([_calibre(1, 'Cola'), _calibre(2, 'Chips')]);
    final notifier = CatalogNotifier(api: api, chainId: 'chain-1');
    await notifier.load();
    expect(notifier.items, hasLength(2));
    expect(notifier.total, 2);
    expect(notifier.items.first.title, 'Cola');
  });

  test('nextCalibreId is max plus one from readAllIds', () async {
    final api = _FakeCatalogApi([_calibre(1, 'A'), _calibre(4, 'B')]);
    final notifier = CatalogNotifier(api: api, chainId: 'chain-1');
    expect(await notifier.nextCalibreId(), 5);
  });

  test('setStatusFilter resets offset and sends filter', () async {
    final api = _FakeCatalogApi([
      _calibre(1, 'Cola'),
      _calibre(2, 'Old', status: false),
    ]);
    final notifier = CatalogNotifier(api: api, chainId: 'chain-1', pageSize: 20);
    await notifier.setPage(20);
    await notifier.setStatusFilter(2);
    expect(notifier.offset, 0);
    expect(api.lastReadAll!.statusFilter, 2);
    expect(notifier.items.single.title, 'Old');
  });

  test('delete removes the calibre and reloads', () async {
    final api = _FakeCatalogApi([_calibre(1, 'Cola')]);
    final notifier = CatalogNotifier(api: api, chainId: 'chain-1');
    await notifier.load();
    final ok = await notifier.delete(notifier.items.single);
    expect(ok, isTrue);
    expect(notifier.items, isEmpty);
    expect(notifier.total, 0);
  });

  test('isCalibreTitleTaken is accent-insensitive and ignores self', () async {
    final api = _FakeCatalogApi([_calibre(1, 'Café')]);
    final notifier = CatalogNotifier(api: api, chainId: 'chain-1');
    await notifier.load();
    expect(await notifier.isCalibreTitleTaken('Cafe'), isTrue);
    expect(await notifier.isCalibreTitleTaken('Café', excludeId: 1), isFalse);
    expect(await notifier.isCalibreTitleTaken('Tea'), isFalse);
  });
}
