// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:protos_weebi/protos_weebi_io.dart';

// Project imports:
import '../models/access_token_object.dart';
import '../models/jwt_token.dart';

/// Provider for managing access token state
class AccessTokenProvider extends ChangeNotifier {
  final AccessTokenObject _accessToken;

  AccessTokenProvider(this._accessToken);

  /// Get the current access token
  String get accessToken => _accessToken.value;
  
  /// Check if token is empty or expired
  bool get isEmptyOrExpired => _accessToken.value.isEmpty
      ? true
      : JsonWebToken.parse(_accessToken.value).isTokenExpired;

  /// is not empty and not expired
  bool get isUsable => isEmptyOrExpired == false;

  /// Get user permissions from the token
  UserPermissions get permissions => _accessToken.value.isEmpty
      ? UserPermissions.create()
      : JsonWebToken.parse(_accessToken.value).permissions;

  /// Set the access token and notify listeners
  set accessToken(String val) {
    _accessToken.value = val;
    notifyListeners();
  }

  /// Clear the access token and notify listeners
  void clearAccessToken() {
    _accessToken.clear();
    notifyListeners();
  }
} 