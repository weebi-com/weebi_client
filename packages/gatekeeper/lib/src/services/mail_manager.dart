import 'package:services_weebi/services_weebi.dart';

/// Manages user mail operations and filtering
/// Single Responsibility: Mail management only
class MailManager {
  MailManager(this._deviceService);
  
  final DeviceServiceAbstract _deviceService;
  final List<String> _userMails = [];
  String _queryString = '';

  /// Gets all user mails
  List<String> get userMails => List.unmodifiable(_userMails);

  /// Gets filtered user mails based on query string
  List<String> get userMailsFiltered => 
      _userMails.where((mail) => mail.contains(_queryString)).toList();

  /// Gets/sets the query string for filtering
  String get queryString => _queryString;
  set queryString(String query) {
    _queryString = query;
    print('MailManager: Set query filter to "$query"');
  }

  /// Reads user mails from service (like original CloudHub)
  Future<List<String>> loadUserMails() async {
    try {
      // ignore: void_checks
      final temp = await _deviceService.readMailsRpc.request(const []);
      if (temp.isNotEmpty) {
        _userMails.addAll(temp); // Like original CloudHub - append, don't replace
      }
      return temp;
    } catch (e) {
      print(e); // Match original CloudHub error logging
      rethrow;
    }
  }

  /// Adds a user mail (like original CloudHub)
  Future<String> addUserMail(String data) async {
    try {
      await _deviceService.addUserMailRpc.request(data);
      _userMails.add(data); // Like original CloudHub
      return data;
    } catch (e) {
      print(e); // Match original CloudHub error logging
      rethrow;
    }
  }

  /// Deletes all user mails (like original CloudHub)
  Future<void> deleteAllUserMails() async {
    try {
            // ignore: void_checks
      await _deviceService.deleteAllMailsRpc.request(const []);
      _userMails.clear();
      return;
    } catch (e) {
      print(e); // Match original CloudHub error logging
      rethrow;
    }
  }

  /// Removes a specific mail from local list (if service supports it)
  void removeMailLocally(String mail) {
    if (_userMails.remove(mail)) {
      print('MailManager: Removed mail locally: $mail');
    }
  }

  /// Checks if a mail exists
  bool containsMail(String mail) => _userMails.contains(mail);

  /// Gets count of mails
  int get mailCount => _userMails.length;

  /// Gets count of filtered mails
  int get filteredMailCount => userMailsFiltered.length;

  /// Clears local mail cache
  void clearLocalMails() {
    _userMails.clear();
    _queryString = '';
    print('MailManager: Cleared local mail cache');
  }
}

