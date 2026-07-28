import 'package:flutter/foundation.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/catalog/catalog_calibre_mapper.dart';
import 'package:web_admin/catalog/catalog_seed_item.dart';
import 'package:web_admin/catalog/catalog_seed_loader.dart';
import 'package:web_admin/catalog/catalog_selection.dart';

/// State for FMCG catalog discovery: seed browse, selection bag, materialize.
class CatalogDiscoveryNotifier extends ChangeNotifier {
  CatalogDiscoveryNotifier({
    required ArticleServiceClient articleClient,
    CatalogSeedLoader loader = const CatalogSeedLoader(),
    CatalogCalibreMapper mapper = const CatalogCalibreMapper(),
  })  : _articleClient = articleClient,
        _loader = loader,
        _mapper = mapper;

  final ArticleServiceClient _articleClient;
  final CatalogSeedLoader _loader;
  final CatalogCalibreMapper _mapper;

  CatalogSeed? _seed;
  bool _isLoadingSeed = false;
  String? _seedError;

  String _searchQuery = '';
  String? _selectedCategory;

  final Map<String, CatalogSelectionEntry> _selection = {};

  String? _chainId;
  Set<String> _existingBarcodes = {};
  bool _isLoadingChainArticles = false;
  String? _chainArticlesError;

  bool _isSubmitting = false;
  String? _submitError;
  String? _submitSuccess;

  CatalogSeed? get seed => _seed;
  bool get isLoadingSeed => _isLoadingSeed;
  String? get seedError => _seedError;

  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  List<CatalogSelectionEntry> get selection =>
      _selection.values.toList(growable: false);
  int get selectionCount => _selection.length;
  bool isPicked(String seedId) => _selection.containsKey(seedId);

  String? get chainId => _chainId;
  Set<String> get existingBarcodes => _existingBarcodes;
  bool get isLoadingChainArticles => _isLoadingChainArticles;
  String? get chainArticlesError => _chainArticlesError;

  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;
  String? get submitSuccess => _submitSuccess;

  bool isAlreadyInCatalog(CatalogSeedItem item) {
    if (item.barcodeEan.isEmpty) return false;
    return _existingBarcodes.contains(item.barcodeEan);
  }

  List<String> get categories => _seed?.categories ?? const [];

  List<CatalogSeedItem> get filteredItems {
    final items = _seed?.items ?? const <CatalogSeedItem>[];
    final query = _searchQuery.trim().toLowerCase();
    return items.where((item) {
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }
      if (query.isEmpty) return true;
      return item.title.toLowerCase().contains(query) ||
          item.designation.toLowerCase().contains(query) ||
          item.barcodeEan.contains(query) ||
          item.category.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  Future<void> loadSeed() async {
    if (_isLoadingSeed) return;
    _isLoadingSeed = true;
    _seedError = null;
    notifyListeners();
    try {
      _seed = await _loader.loadFmcg();
    } catch (e) {
      _seedError = e.toString();
      _seed = null;
    } finally {
      _isLoadingSeed = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void pick(CatalogSeedItem item) {
    if (isAlreadyInCatalog(item)) return;
    if (_selection.containsKey(item.seedId)) return;
    _selection[item.seedId] = CatalogSelectionEntry.fromSeed(item);
    _submitSuccess = null;
    _submitError = null;
    notifyListeners();
  }

  void remove(String seedId) {
    if (_selection.remove(seedId) == null) return;
    notifyListeners();
  }

  void updatePrice(String seedId, double price) {
    final entry = _selection[seedId];
    if (entry == null) return;
    entry.price = price;
    notifyListeners();
  }

  void updateCost(String seedId, double cost) {
    final entry = _selection[seedId];
    if (entry == null) return;
    entry.cost = cost;
    notifyListeners();
  }

  void clearSelection() {
    if (_selection.isEmpty) return;
    _selection.clear();
    notifyListeners();
  }

  Future<void> setChainId(String? chainId) async {
    if (_chainId == chainId) return;
    _chainId = chainId;
    _existingBarcodes = {};
    _chainArticlesError = null;
    _submitSuccess = null;
    _submitError = null;
    notifyListeners();
    if (chainId != null && chainId.isNotEmpty) {
      await refreshExistingBarcodes();
    }
  }

  Future<void> refreshExistingBarcodes() async {
    final chainId = _chainId;
    if (chainId == null || chainId.isEmpty) return;

    _isLoadingChainArticles = true;
    _chainArticlesError = null;
    notifyListeners();
    try {
      final response = await _articleClient.readAll(
        ReadAllRequest(chainId: chainId),
      );
      final barcodes = <String>{};
      for (final calibre in response.calibres) {
        for (final retail in calibre.articlesRetail) {
          if (retail.barcodeEAN.isNotEmpty) {
            barcodes.add(retail.barcodeEAN);
          }
        }
      }
      _existingBarcodes = barcodes;

      // Drop picks that are already in the chain catalog.
      _selection.removeWhere(
        (_, entry) => barcodes.contains(entry.item.barcodeEan),
      );
    } catch (e) {
      _chainArticlesError = e.toString();
    } finally {
      _isLoadingChainArticles = false;
      notifyListeners();
    }
  }

  Future<bool> materializeSelection() async {
    final chainId = _chainId;
    if (chainId == null || chainId.isEmpty) {
      _submitError = 'Select a chain first.';
      notifyListeners();
      return false;
    }
    if (_selection.isEmpty) {
      _submitError = 'Pick at least one product.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _submitError = null;
    _submitSuccess = null;
    notifyListeners();

    try {
      final idsResponse = await _articleClient.readAllIds(
        ReadIdsRequest(chainId: chainId),
      );
      final startingId = CatalogCalibreMapper.nextCalibreId(idsResponse.ids);
      final entries = selection;
      final calibres = _mapper.toCalibres(
        entries: entries,
        startingCalibreId: startingId,
      );

      final status = await _articleClient.createMany(
        CalibresRequest(chainId: chainId, calibres: calibres),
      );

      final message = status.message.isNotEmpty
          ? status.message
          : 'Added ${calibres.length} product(s) to the catalog.';
      _submitSuccess = message;
      _selection.clear();
      await refreshExistingBarcodes();
      return true;
    } catch (e) {
      _submitError = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
