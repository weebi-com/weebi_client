// Package imports:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Project imports:
import 'token_storage.dart';

/// Generic secure string storage for a specific key
class SecureStringStorage implements TokenStorage {
  final FlutterSecureStorage _storage;
  final String _key;

  const SecureStringStorage(this._storage, this._key);

  /// Probe availability by read/write/delete round trip
  static Future<bool> isAvailable(FlutterSecureStorage storage) async {
    try {
      const String probeKey = '__probe_generic__';
      await storage.write(key: probeKey, value: '1');
      final v = await storage.read(key: probeKey);
      await storage.delete(key: probeKey);
      return v == '1';
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _key);
  }

  @override
  Future<String> read() async {
    return await _storage.read(key: _key) ?? '';
  }

  @override
  Future<void> write(String value) async {
    await _storage.write(key: _key, value: value);
  }
}


