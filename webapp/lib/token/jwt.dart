import 'dart:convert';

import 'package:protos_weebi/protos_weebi_io.dart';

// so that proxy provider triggers the update
class JsonWebTokenWrapper {
  final String accessToken;
  const JsonWebTokenWrapper(this.accessToken);
}

class JsonWebToken {
  Map<String, dynamic> _payload = {};
  JsonWebToken();

  JsonWebToken.parse(String jwt) {
    final parts = jwt.split('.');
    final encodedPayload = parts[1];
    _payload = json.decode(utf8.decode(base64Url.decode(encodedPayload)));
  }

  String get sub => _payload['sub'];
  String get iat => _payload['iat'];
  int? get exp => _payload['exp'] as int?;

  bool get isTokenExpired {
    if (exp == null) {
      return true; // Missing expiration claim
    }
    final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp! * 1000);

    return DateTime.now().isAfter(expirationDate);
  }

  UserPermissions get permissions => UserPermissions.create()
    ..mergeFromProto3Json(_payload, ignoreUnknownFields: true);

  Map<String, dynamic> get payload => _payload;
}
