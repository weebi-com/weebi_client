import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_admin/core/session/bff_session_store.dart';
import 'package:web_admin/environment.dart';

import '../core/constants/values.dart';

class UserDataProvider extends ChangeNotifier {
  var _userProfileImageUrl = '';
  var _firstname = '';
  var _lastname = '';
  var _mail = '';
  var _accessToken = '';
  var _refreshToken = '';
  var _bffSessionId = '';
  var _stayConnected = true;

  String get userProfileImageUrl => _userProfileImageUrl;

  String get firstname => _firstname;
  String get lastname => _lastname;
  String get mail => _mail;
  String get accessToken => _accessToken;
  String get refreshToken => _refreshToken;
  String get bffSessionId => _bffSessionId;
  bool get stayConnected => _stayConnected;

  Future<void> loadAsync() async {
    final sharedPref = await SharedPreferences.getInstance();

    _firstname = sharedPref.getString(SharePrefKeys.firstname) ?? '';
    _lastname = sharedPref.getString(SharePrefKeys.lastname) ?? '';
    _mail = sharedPref.getString(SharePrefKeys.mail) ?? '';
    _accessToken = sharedPref.getString(SharePrefKeys.accessToken) ?? '';
    _refreshToken = sharedPref.getString(SharePrefKeys.refreshToken) ?? '';
    _userProfileImageUrl =
        sharedPref.getString(SharePrefKeys.userProfileImageUrl) ?? '';
    _stayConnected = sharedPref.getBool(SharePrefKeys.stayConnected) ?? true;
    _bffSessionId = await BffSessionStore.getSessionId() ?? '';

    notifyListeners();
  }

  Future<void> setUserDataAsync({
    String? userProfileImageUrl,
    String? mail,
    String? accessToken,
    String? refreshToken,
    String? bffSessionId,
    bool? stayConnected,
  }) async {
    final sharedPref = await SharedPreferences.getInstance();
    var shouldNotify = false;

    if (stayConnected != null && stayConnected != _stayConnected) {
      _stayConnected = stayConnected;
      await sharedPref.setBool(SharePrefKeys.stayConnected, _stayConnected);
      shouldNotify = true;
    } else if (stayConnected != null) {
      await sharedPref.setBool(SharePrefKeys.stayConnected, stayConnected);
    }

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

    if (accessToken != null && accessToken != _accessToken) {
      _accessToken = accessToken;

      await sharedPref.setString(SharePrefKeys.accessToken, _accessToken);

      shouldNotify = true;
    }

    if (refreshToken != null && refreshToken != _refreshToken) {
      _refreshToken = refreshToken;

      await sharedPref.setString(SharePrefKeys.refreshToken, _refreshToken);

      shouldNotify = true;
    }

    if (bffSessionId != null && bffSessionId != _bffSessionId) {
      _bffSessionId = bffSessionId;
      if (bffSessionId.isEmpty) {
        await BffSessionStore.clear();
      } else {
        await BffSessionStore.setSessionId(
          bffSessionId,
          persist: _stayConnected,
        );
      }
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

  /// Clears the live session (tokens, names, BFF session id) but keeps
  /// remembered [mail] and the Stay connected preference for the login form.
  Future<void> clearSessionDataAsync() async {
    final sharedPref = await SharedPreferences.getInstance();

    await sharedPref.remove(SharePrefKeys.firstname);
    await sharedPref.remove(SharePrefKeys.lastname);
    await sharedPref.remove(SharePrefKeys.userProfileImageUrl);
    await sharedPref.remove(SharePrefKeys.accessToken);
    await sharedPref.remove(SharePrefKeys.refreshToken);
    await BffSessionStore.clear();

    _firstname = '';
    _lastname = '';
    _userProfileImageUrl = '';
    _accessToken = '';
    _refreshToken = '';
    _bffSessionId = '';

    notifyListeners();
  }

  bool isUserLoggedIn() {
    if (Config.isBffMode) {
      return _mail.isNotEmpty && _bffSessionId.isNotEmpty;
    }
    return _mail.isNotEmpty && _accessToken.isNotEmpty;
  }
}
