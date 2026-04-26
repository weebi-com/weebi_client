import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/token/jwt.dart';

class AccessTokenObject {
  String value = '';
  void clear() {
    value = '';
  }
}

class AccessTokenProvider extends ChangeNotifier {
  final AccessTokenObject _accessToken;

  String get accessToken => _accessToken.value;
  bool get isEmptyOrExpired => _accessToken.value.isEmpty
      ? true
      : JsonWebToken.parse(_accessToken.value).isTokenExpired;

  UserPermissions get permissions =>
      JsonWebToken.parse(_accessToken.value).permissions;

  AccessTokenProvider(this._accessToken);

  set accessToken(String val) {
    _accessToken.value = val;
    notifyListeners();
  }

  void clearAccessToken() {
    _accessToken.clear();
    notifyListeners();
  }
}
