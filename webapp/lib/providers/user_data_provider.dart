import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/values.dart';

class UserDataProvider extends ChangeNotifier {
  var _userProfileImageUrl = '';
  var _firstname = '';
  var _lastname = '';
  var _mail = '';
  var _accessToken = '';
  var _refreshToken = '';

  String get userProfileImageUrl => _userProfileImageUrl;

  String get firstname => _firstname;
  String get lastname => _lastname;
  String get mail => _mail;
  String get accessToken => _accessToken;
  String get refreshToken => _refreshToken;

  Future<void> loadAsync() async {
    final sharedPref = await SharedPreferences.getInstance();

    _firstname = sharedPref.getString(SharePrefKeys.firstname) ?? '';
    _lastname = sharedPref.getString(SharePrefKeys.lastname) ?? '';
    _mail = sharedPref.getString(SharePrefKeys.mail) ?? '';
    _accessToken = sharedPref.getString(SharePrefKeys.accessToken) ?? '';
    _refreshToken = sharedPref.getString(SharePrefKeys.refreshToken) ?? '';
    _userProfileImageUrl =
        sharedPref.getString(SharePrefKeys.userProfileImageUrl) ?? '';

    notifyListeners();
  }

  Future<void> setUserDataAsync({
    String? userProfileImageUrl,
    String? mail,
  }) async {
    final sharedPref = await SharedPreferences.getInstance();
    var shouldNotify = false;

    if (userProfileImageUrl != null &&
        userProfileImageUrl != _userProfileImageUrl) {
      _userProfileImageUrl = userProfileImageUrl;

      await sharedPref.setString(
          SharePrefKeys.userProfileImageUrl, _userProfileImageUrl);

      shouldNotify = true;
    }

    if (mail != null && mail != _mail) {
      _mail = mail;

      await sharedPref.setString(SharePrefKeys.mail, _mail);

      shouldNotify = true;
    }

    if (shouldNotify) {
      notifyListeners();
    }
  }

  Future<void> clearUserDataAsync() async {
    final sharedPref = await SharedPreferences.getInstance();

    await sharedPref.remove(SharePrefKeys.mail);
    await sharedPref.remove(SharePrefKeys.userProfileImageUrl);

    _mail = '';
    _userProfileImageUrl = '';

    notifyListeners();
  }

  bool isUserLoggedIn() {
    return _mail.isNotEmpty;
  }
}
