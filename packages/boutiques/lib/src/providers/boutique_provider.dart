import 'package:flutter/foundation.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import '../../boutique.dart';
import '../events/boutique_events.dart';

/// Provider class for managing boutique and chain state
class BoutiqueProvider extends ChangeNotifier {
  final FenceServiceClient _fenceServiceClient;
  final BoutiqueBus _bus = BoutiqueBus();

  List<Chain> _chains = [];
  Chain? _selectedChain;
  BoutiqueMongo? _selectedBoutique;
  bool _isLoading = false;
  String? _error;

  BoutiqueProvider(this._fenceServiceClient);

  // Getters
  List<Chain> get chains => _chains;
  Chain? get selectedChain => _selectedChain;
  BoutiqueMongo? get selectedBoutique => _selectedBoutique;
  bool get isLoading => _isLoading;
  String? get error => _error;
  FenceServiceClient get fenceServiceClient => _fenceServiceClient;
  BoutiqueBus get bus => _bus;

  /// Gets all boutiques across all chains
  List<BoutiqueMongo> get allBoutiques {
    return _chains.expand((chain) => chain.boutiques).toList();
  }

  /// Gets boutiques for a specific chain
  List<BoutiqueMongo> getBoutiquesForChain(String chainId) {
    final chain = _chains.firstWhere(
      (c) => c.chainId == chainId,
      orElse: () => Chain(),
    );
    return chain.boutiques;
  }

  /// Gets active boutiques across all chains
  List<BoutiqueMongo> get activeBoutiques {
    return allBoutiques.where((b) => b.boutique.isDeleted == false).toList();
  }

  /// Gets boutiques grouped by chain
  Map<Chain, List<BoutiqueMongo>> get boutiquesByChain {
    final result = <Chain, List<BoutiqueMongo>>{};
    for (final chain in _chains) {
      result[chain] = chain.boutiques;
    }
    return result;
  }

  /// Clears any error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clears user-scoped boutique state when the app session ends.
  void clearSession() {
    _chains = [];
    _selectedChain = null;
    _selectedBoutique = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// Loads all chains with their boutiques
  Future<void> loadChains() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _fenceServiceClient.readAllChains(Empty());
      _chains = response.chains;
      
      // Emit refresh event to notify other parts of the app
      _bus.emit(BoutiqueEvent(
        type: BoutiqueEventType.refreshed,
        timestamp: Timestamp.fromDateTime(DateTime.now()),
      ));
    } on GrpcError catch (e) {
      _error = '${e.code} ${e.message}';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Selects a chain
  void selectChain(Chain? chain) {
    _selectedChain = chain;
    // Clear boutique selection when chain changes
    if (_selectedBoutique != null && 
        chain?.chainId != _selectedBoutique?.chainId) {
      _selectedBoutique = null;
    }
    notifyListeners();
  }

  /// Selects a boutique
  void selectBoutique(BoutiqueMongo? boutique) {
    _selectedBoutique = boutique;
    // Auto-select the chain if boutique is selected
    if (boutique != null) {
      final chain = _chains.firstWhere(
        (c) => c.chainId == boutique.chainId,
        orElse: () => Chain(),
      );
      if (chain.chainId.isNotEmpty) {
        _selectedChain = chain;
      }
    }
    notifyListeners();
  }

  /// Creates a new chain
  Future<bool> createChain(Chain chain) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _fenceServiceClient.createOneChain(chain);
      if (response.type == StatusResponse_Type.CREATED) {
        await loadChains(); // Reload to get the updated list
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } on GrpcError catch (e) {
      _error = '${e.code} ${e.message}';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates an existing chain (patch: optional fields omitted by [request] are unchanged server-side).
  Future<bool> updateChain(ChainRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _fenceServiceClient.updateOneChain(request);
      
      if (response.type == StatusResponse_Type.UPDATED) {
        await loadChains(); // Reload to get the updated list
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } on GrpcError catch (e) {
      _error = '${e.code} ${e.message}';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a chain
  Future<bool> deleteChain(String chainId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = DeleteChainRequest()..chainId = chainId;
      final response = await _fenceServiceClient.deleteOneChain(request);
      
      if (response.type == StatusResponse_Type.DELETED) {
        await loadChains(); // Reload to get the updated list
        // Clear selections if deleted chain was selected
        if (_selectedChain?.chainId == chainId) {
          _selectedChain = null;
          _selectedBoutique = null;
        }
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new boutique
  Future<bool> createBoutique(String chainId, BoutiquePb boutique, {List<int>? logo, String? logoExtension}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = BoutiqueRequest()
        ..chainId = chainId
        ..boutique = boutique;
      
      if (logo != null) request.logo = logo;
      if (logoExtension != null) request.logoExtension = logoExtension;
      
      final response = await _fenceServiceClient.createOneBoutique(request);
      
      if (response.type == StatusResponse_Type.CREATED) {
        await loadChains(); // Reload to get the updated list
        
        // Emit created event
        _bus.emit(BoutiqueEvent(
          type: BoutiqueEventType.created,
          chainId: chainId,
          timestamp: Timestamp.fromDateTime(DateTime.now()),
        ));
        
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } on GrpcError catch (e) {
      _error = '${e.code} ${e.message}';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates an existing boutique
  Future<bool> updateBoutique(String chainId, String boutiqueId, BoutiquePb boutique, {List<int>? logo, String? logoExtension}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Ensure the boutiqueId is set in the boutique object for updates
      final boutiqueToUpdate = BoutiquePb()
        ..mergeFromMessage(boutique)
        ..boutiqueId = boutiqueId;
      
      final request = BoutiqueRequest()
        ..chainId = chainId
        ..boutique = boutiqueToUpdate;
      
      if (logo != null) request.logo = logo;
      if (logoExtension != null) request.logoExtension = logoExtension;
      
      final response = await _fenceServiceClient.updateOneBoutique(request);
      
      if (response.type == StatusResponse_Type.UPDATED) {
        await loadChains(); // Reload to get the updated list
        
        // Emit updated event
        _bus.emit(BoutiqueEvent(
          type: BoutiqueEventType.updated,
          boutiqueId: boutiqueId,
          chainId: chainId,
          timestamp: Timestamp.fromDateTime(DateTime.now()),
        ));
        
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } on GrpcError catch (e) {
      _error = '${e.code} ${e.message}';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a boutique
  Future<bool> deleteBoutique(String chainId, String boutiqueId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = BoutiqueRequest()
        ..chainId = chainId
        ..boutique = (BoutiquePb()..boutiqueId = boutiqueId);
      
      final response = await _fenceServiceClient.deleteOneBoutique(request);
      
      if (response.type == StatusResponse_Type.DELETED) {
        await loadChains(); // Reload to get the updated list
        // Clear selection if deleted boutique was selected
        if (_selectedBoutique?.boutiqueId == boutiqueId) {
          _selectedBoutique = null;
        }
        
        // Emit deleted event
        _bus.emit(BoutiqueEvent(
          type: BoutiqueEventType.deleted,
          boutiqueId: boutiqueId,
          chainId: chainId,
          timestamp: Timestamp.fromDateTime(DateTime.now()),
        ));
        
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } on GrpcError catch (e) {
      _error = '${e.code} ${e.message}';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Searches boutiques by name
  List<BoutiqueMongo> searchBoutiques(String query) {
    if (query.isEmpty) return allBoutiques;
    
    final lowercaseQuery = query.toLowerCase();
    return allBoutiques.where((boutique) =>
      boutique.displayName.toLowerCase().contains(lowercaseQuery) ||
      boutique.formattedAddress.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  /// Searches chains by name
  List<Chain> searchChains(String query) {
    if (query.isEmpty) return _chains;
    
    final lowercaseQuery = query.toLowerCase();
    return _chains.where((chain) =>
      chain.name.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
}
