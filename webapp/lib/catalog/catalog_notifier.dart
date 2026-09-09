import 'package:flutter/foundation.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/catalog/article_label.dart';
import 'package:web_admin/catalog/catalog_api.dart';
import 'package:web_admin/catalog/catalog_ids.dart';

/// 0 = all, 1 = active, 2 = inactive (matches server statusFilter).
class CatalogNotifier extends ChangeNotifier {
  CatalogNotifier({
    required CatalogApi api,
    required String chainId,
    this.pageSize = 20,
  }) : _api = api, // ignore: prefer_initializing_formals
       _chainId = chainId; // ignore: prefer_initializing_formals

  final CatalogApi _api;
  String _chainId;
  final int pageSize;

  List<CalibrePb> _items = [];
  int _total = 0;
  int _offset = 0;
  String _query = '';
  int _statusFilter = 0;
  bool _isLoading = false;
  String? _error;

  String get chainId => _chainId;
  List<CalibrePb> get items => _items;
  int get total => _total;
  int get offset => _offset;
  int get pageSizeUsed => pageSize;
  String get query => _query;
  int get statusFilter => _statusFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => (_offset + _items.length) < _total;

  Future<void> setChainId(String chainId) async {
    if (_chainId == chainId) return;
    _chainId = chainId;
    _offset = 0;
    await load();
  }

  Future<void> setQuery(String value) async {
    if (_query == value) return;
    _query = value;
    _offset = 0;
    await load();
  }

  Future<void> setStatusFilter(int value) async {
    if (_statusFilter == value) return;
    _statusFilter = value;
    _offset = 0;
    await load();
  }

  Future<void> setPage(int offset) async {
    if (offset < 0) offset = 0;
    _offset = offset;
    await load();
  }

  Future<void> load() async {
    if (_chainId.isEmpty) {
      _error = 'Select a chain first.';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.readAll(
        ReadAllRequest(
          chainId: _chainId,
          offset: _offset,
          limit: pageSize,
          query: _query,
          statusFilter: _statusFilter,
        ),
      );
      _items = List<CalibrePb>.from(response.calibres);
      _total = response.total > 0 ? response.total : _items.length;
    } on GrpcError catch (e) {
      _error = e.message ?? e.codeName;
      _items = [];
      _total = 0;
    } catch (e) {
      _error = e.toString();
      _items = [];
      _total = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> nextCalibreId() async {
    final ids = await _api.readAllIds(ReadIdsRequest(chainId: _chainId));
    return nextPositiveId(ids.ids);
  }

  Future<bool> isCalibreTitleTaken(String title, {int? excludeId}) async {
    final needle = title.asArticleKey;
    if (needle.isEmpty) return false;
    if (_items.any(
      (c) => c.id != excludeId && c.title.asArticleKey == needle,
    )) {
      return true;
    }
    return _anyCalibreMatches(
      query: title.trim(),
      matches: (c) => c.id != excludeId && c.title.asArticleKey == needle,
    );
  }

  Future<bool> isArticleDesignationTaken(
    String designation, {
    int? excludeCalibreId,
    int? excludeArticleId,
  }) async {
    final needle = designation.asArticleKey;
    if (needle.isEmpty) return false;
    bool hits(CalibrePb c) {
      for (final article in c.articlesRetail) {
        if (c.id == excludeCalibreId && article.id == excludeArticleId) {
          continue;
        }
        if (article.designation.asArticleKey == needle) return true;
      }
      return false;
    }

    if (_items.any(hits)) return true;
    return _anyCalibreMatches(query: designation.trim(), matches: hits);
  }

  Future<bool> _anyCalibreMatches({
    required String query,
    required bool Function(CalibrePb calibre) matches,
  }) async {
    if (_chainId.isEmpty) return false;
    try {
      final response = await _api.readAll(
        ReadAllRequest(
          chainId: _chainId,
          offset: 0,
          limit: 50,
          query: query,
          statusFilter: 0,
        ),
      );
      return response.calibres.any(matches);
    } catch (_) {
      return false;
    }
  }

  Future<CalibrePb> readOne(int calibreId) {
    return _api.readOne(
      ReadCalibreRequest(chainId: _chainId, calibreId: calibreId),
    );
  }

  Future<bool> save(CalibrePb calibre, {required bool isNew}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final request = CalibreRequest(chainId: _chainId, calibre: calibre);
      final status =
          isNew ? await _api.createOne(request) : await _api.updateOne(request);
      if (status.type == StatusResponse_Type.ERROR) {
        _error = status.message.isNotEmpty ? status.message : 'Save failed.';
        return false;
      }
      await load();
      return true;
    } on GrpcError catch (e) {
      _error = e.message ?? e.codeName;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> delete(CalibrePb calibre) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.deleteOne(CalibreRequest(chainId: _chainId, calibre: calibre));
      await load();
      return true;
    } on GrpcError catch (e) {
      _error = e.message ?? e.codeName;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

ArticleRetailPb firstRetailOrNew(CalibrePb calibre) {
  if (calibre.articlesRetail.isNotEmpty) {
    return calibre.articlesRetail.first;
  }
  return ArticleRetailPb.create()
    ..id = 1
    ..calibreId = calibre.id
    ..kind = ArticleKindPb.retail
    ..status = true
    ..unitsInOnePiece = 1;
}

CalibrePb newRetailCalibre({
  required int id,
  required String title,
  required String designation,
  required double price,
  required double cost,
  required String barcode,
  required double unitsInOnePiece,
  CalibrePb_StockUnit stockUnit = CalibrePb_StockUnit.unit,
}) {
  final now = DateTime.now().toUtc().toIso8601String();
  final retail = ArticleRetailPb.create()
    ..id = 1
    ..calibreId = id
    ..designation = designation
    ..kind = ArticleKindPb.retail
    ..status = true
    ..creationDate = now
    ..updateDate = now
    ..statusUpdateDate = now
    ..price = price
    ..cost = cost
    ..unitsInOnePiece = unitsInOnePiece
    ..barcodeEAN = barcode;
  return CalibrePb.create()
    ..id = id
    ..creationDate = now
    ..updateDate = now
    ..statusUpdateDate = now
    ..status = true
    ..title = title
    ..stockUnit = stockUnit
    ..kind = ArticleKindPb.retail
    ..articlesRetail.add(retail);
}
