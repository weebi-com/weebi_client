import 'dart:convert';
import 'package:protos_weebi/protos_weebi_io.dart' show UserPermissions;

/// Wrapper class for JWT token to trigger proxy provider updates
class JsonWebTokenWrapper {
  final String accessToken;
  const JsonWebTokenWrapper(this.accessToken);
}

/// JWT token parser and utility class
class JsonWebToken {
  Map<String, dynamic> _payload = {};
  
  JsonWebToken();

  /// Parse a JWT token string
  JsonWebToken.parse(String jwt) {
    final parts = jwt.split('.');
    final encodedPayload = parts[1];
    _payload = json.decode(utf8.decode(base64Url.decode(encodedPayload)));
  }

  /// Subject claim
  String get sub => _payload['sub'];
  
  /// Issued at claim
  String get iat => _payload['iat'];
  
  /// Expiration claim
  int? get exp => _payload['exp'] as int?;

  /// Check if token is expired
  bool get isTokenExpired {
    if (exp == null) {
      return true; // Missing expiration claim
    }
    final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp! * 1000);
    return DateTime.now().isAfter(expirationDate);
  }

  /// Extract user permissions from token
  UserPermissions get permissions => UserPermissions.create()
    ..mergeFromProto3Json(_payload, ignoreUnknownFields: true);

  /// Get the full payload
  Map<String, dynamic> get payload => _payload;
} 