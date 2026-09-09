import 'package:flutter/foundation.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/catalog/catalog_ids.dart';

abstract class DirectoryApi {
  Future<ContactsResponse> readAll(ReadAllContactsRequest request);
  Future<ContactsIdsResponse> readAllIds(ReadContactsIdsRequest request);
  Future<ContactPb> readOne(ReadContactRequest request);
  Future<StatusResponse> createOne(ContactRequest request);
  Future<StatusResponse> updateOne(ContactRequest request);
  Future<StatusResponse> deleteOne(ContactRequest request);
}

class GrpcDirectoryApi implements DirectoryApi {
  GrpcDirectoryApi(this._client);

  final ContactServiceClient _client;

  @override
  Future<ContactsResponse> readAll(ReadAllContactsRequest request) =>
      _client.readAll(request);

  @override
  Future<ContactsIdsResponse> readAllIds(ReadContactsIdsRequest request) =>
      _client.readAllIds(request);

  @override
  Future<ContactPb> readOne(ReadContactRequest request) =>
      _client.readOne(request);

  @override
  Future<StatusResponse> createOne(ContactRequest request) =>
      _client.createOne(request);

  @override
  Future<StatusResponse> updateOne(ContactRequest request) =>
      _client.updateOne(request);

  @override
  Future<StatusResponse> deleteOne(ContactRequest request) =>
      _client.deleteOne(request);
}

class ContactsNotifier extends ChangeNotifier {
  ContactsNotifier({
    required DirectoryApi api,
    required String chainId,
    this.pageSize = 20,
  })  : _api = api, // ignore: prefer_initializing_formals
        _chainId = chainId; // ignore: prefer_initializing_formals

  final DirectoryApi _api;
  String _chainId;
  final int pageSize;

  List<ContactPb> _contacts = [];
  int _total = 0;
  int _offset = 0;
  String _query = '';
  int _statusFilter = 0;
  bool _isLoading = false;
  String? _error;

  String get chainId => _chainId;
  List<ContactPb> get contacts => _contacts;
  int get count => _contacts.length;
  int get total => _total;
  int get offset => _offset;
  String get query => _query;
  int get statusFilter => _statusFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
    _offset = offset < 0 ? 0 : offset;
    await load();
  }

  Future<void> fetchContacts() => load();

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
        ReadAllContactsRequest(
          chainId: _chainId,
          offset: _offset,
          limit: pageSize,
          query: _query,
          statusFilter: _statusFilter,
        ),
      );
      _contacts = List<ContactPb>.from(response.contacts);
      _total = response.total > 0 ? response.total : _contacts.length;
    } on GrpcError catch (e) {
      _error = e.message ?? e.codeName;
      _contacts = [];
      _total = 0;
    } catch (e) {
      _error = e.toString();
      _contacts = [];
      _total = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> nextContactId() async {
    final ids = await _api.readAllIds(ReadContactsIdsRequest(chainId: _chainId));
    return nextPositiveId(ids.ids);
  }

  Future<ContactPb> readOne(int contactId) {
    return _api.readOne(
      ReadContactRequest(contactChainId: _chainId, contactId: contactId),
    );
  }

  Future<bool> save(ContactPb contact, {required bool isNew}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final request = ContactRequest(chainId: _chainId, contact: contact);
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

  Future<bool> delete(ContactPb contact) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.deleteOne(ContactRequest(chainId: _chainId, contact: contact));
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

ContactPb newContactDraft({required int id}) {
  final now = DateTime.now().toUtc().toIso8601String();
  return ContactPb.create()
    ..id = id
    ..creationDate = now
    ..updateDate = now
    ..statusUpdateDate = now
    ..status = true
    ..isClient = true
    ..isSupplier = false;
}
