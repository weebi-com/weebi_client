import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/contacts/provider/contacts_provider.dart';

class _FakeDirectoryApi implements DirectoryApi {
  _FakeDirectoryApi(this.store);

  final List<ContactPb> store;
  ReadAllContactsRequest? lastReadAll;

  @override
  Future<ContactsResponse> readAll(ReadAllContactsRequest request) async {
    lastReadAll = request;
    var filtered = store.where((c) {
      if (request.statusFilter == 1 && !c.status) return false;
      if (request.statusFilter == 2 && c.status) return false;
      final q = request.query.trim().toLowerCase();
      if (q.isEmpty) return true;
      return c.firstName.toLowerCase().contains(q) ||
          c.lastName.toLowerCase().contains(q) ||
          c.mail.toLowerCase().contains(q);
    }).toList();
    final total = filtered.length;
    if (request.limit > 0) {
      final end = (request.offset + request.limit).clamp(0, filtered.length);
      filtered = filtered.sublist(
        request.offset.clamp(0, filtered.length),
        end,
      );
    }
    return ContactsResponse(
      contacts: filtered,
      total: total,
      offset: request.offset,
      batchSize: filtered.length,
      hasMore: request.offset + filtered.length < total,
    );
  }

  @override
  Future<ContactsIdsResponse> readAllIds(ReadContactsIdsRequest request) async {
    return ContactsIdsResponse(ids: store.map((c) => c.id));
  }

  @override
  Future<ContactPb> readOne(ReadContactRequest request) async {
    return store.firstWhere((c) => c.id == request.contactId);
  }

  @override
  Future<StatusResponse> createOne(ContactRequest request) async {
    store.add(request.contact);
    return StatusResponse(type: StatusResponse_Type.CREATED);
  }

  @override
  Future<StatusResponse> updateOne(ContactRequest request) async {
    final i = store.indexWhere((c) => c.id == request.contact.id);
    if (i >= 0) store[i] = request.contact;
    return StatusResponse(type: StatusResponse_Type.UPDATED);
  }

  @override
  Future<StatusResponse> deleteOne(ContactRequest request) async {
    store.removeWhere((c) => c.id == request.contact.id);
    return StatusResponse(type: StatusResponse_Type.DELETED);
  }
}

class _LegacyDumpDirectoryApi implements DirectoryApi {
  _LegacyDumpDirectoryApi(this.store);

  final List<ContactPb> store;

  @override
  Future<ContactsResponse> readAll(ReadAllContactsRequest request) async {
    return ContactsResponse(contacts: store);
  }

  @override
  Future<ContactsIdsResponse> readAllIds(ReadContactsIdsRequest request) async =>
      ContactsIdsResponse(ids: store.map((c) => c.id));

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

ContactPb _contact(int id, String first, String last) {
  return ContactPb.create()
    ..id = id
    ..firstName = first
    ..lastName = last
    ..status = true;
}

void main() {
  test('load paginates and setQuery resets offset', () async {
    final api = _FakeDirectoryApi([
      _contact(1, 'Ada', 'Lovelace'),
      _contact(2, 'Lili', 'Gancel'),
      _contact(3, 'Marie', 'Curie'),
    ]);
    final notifier = ContactsNotifier(api: api, chainId: 'chain-1', pageSize: 2);
    await notifier.load();
    expect(notifier.contacts, hasLength(2));
    expect(notifier.total, 3);
    await notifier.setQuery('lili');
    expect(notifier.offset, 0);
    expect(notifier.contacts.single.firstName, 'Lili');
    expect(api.lastReadAll!.query, 'lili');
  });

  test('save create then appears in list', () async {
    final api = _FakeDirectoryApi([]);
    final notifier = ContactsNotifier(api: api, chainId: 'chain-1');
    final ok = await notifier.save(_contact(1, 'John', 'Doe'), isNew: true);
    expect(ok, isTrue);
    expect(notifier.contacts.single.lastName, 'Doe');
  });

  test('nextContactId is max plus one', () async {
    final api = _FakeDirectoryApi([
      _contact(1, 'Ada', 'Lovelace'),
      _contact(3, 'Marie', 'Curie'),
    ]);
    final notifier = ContactsNotifier(api: api, chainId: 'chain-1');
    expect(await notifier.nextContactId(), 4);
  });

  test('delete removes the contact and reloads', () async {
    final api = _FakeDirectoryApi([_contact(1, 'Ada', 'Lovelace')]);
    final notifier = ContactsNotifier(api: api, chainId: 'chain-1');
    await notifier.load();
    final ok = await notifier.delete(notifier.contacts.single);
    expect(ok, isTrue);
    expect(notifier.contacts, isEmpty);
  });

  test('load treats missing total as the returned list length (legacy server)',
      () async {
    final api = _LegacyDumpDirectoryApi([_contact(1, 'Ada', 'Lovelace')]);
    final notifier = ContactsNotifier(api: api, chainId: 'chain-1');
    await notifier.load();
    expect(notifier.contacts, hasLength(1));
    expect(notifier.total, 1);
  });
}
