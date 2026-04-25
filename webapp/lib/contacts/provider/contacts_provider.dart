import 'package:flutter/foundation.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

class ContactsNotifier with ChangeNotifier {
  final ContactServiceClient _contactStub;
  final String chainId;
  ContactsNotifier(this._contactStub, this.chainId);
  List<ContactPb> _contacts = [];
  bool _isLoading = false;

  List<ContactPb> get contacts => _contacts;
  bool get isLoading => _isLoading;

  Future<void> fetchContacts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response =
          await _contactStub.readAll(ReadAllContactsRequest(chainId: ''));
      _contacts = response.contacts;
    } on GrpcError catch (e) {
      if (kDebugMode) {
        print(e.codeName);
        print(e.message);
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  int get count => _contacts.length;
}
