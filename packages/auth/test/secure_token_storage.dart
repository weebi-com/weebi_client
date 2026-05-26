/* // Package imports:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Project imports:
import 'secure_storage_upsert.dart';
import 'token_storage.dart';

/// Secure storage-backed access token storage
class SecureTokenStorage implements TokenStorage {
  static const String _key = 'access';
  final FlutterSecureStorage _storage;

  const SecureTokenStorage(this._storage);

  /// Some environments expose the API but fail at runtime
  /// We check if secure storage actually works before using it
  /// Probe availability by read/write/delete round trip
  static Future<bool> isAvailable(FlutterSecureStorage storage) async {
    try {
      const String probeKey = '__probe_access__';
      await writeSecureStorageValue(
        storage: storage,
        key: probeKey,
        value: '1',
      );
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
    await writeSecureStorageValue(
      storage: _storage,
      key: _key,
      value: value,
    );
  }
}
 */