// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String _errSecDuplicateItemCode = '-25299';

/// Writes a secure storage value, replacing the existing Keychain item when iOS
/// reports errSecDuplicateItem.
Future<void> writeSecureStorageValue({
  required FlutterSecureStorage storage,
  required String key,
  required String value,
}) async {
  try {
    await storage.write(key: key, value: value);
  } on PlatformException catch (e) {
    if (e.code != _errSecDuplicateItemCode) {
      rethrow;
    }

    await storage.delete(key: key);
    await storage.write(key: key, value: value);
  }
}
