/// Abstraction for storing the access token
abstract class TokenStorage {
  Future<String> read();
  Future<void> write(String value);
  Future<void> clear();
}

/// In-memory token storage (process-lifetime only)
class MemoryTokenStorage implements TokenStorage {
  String _value = '';

  @override
  Future<void> clear() async {
    _value = '';
  }

  @override
  Future<String> read() async => _value;

  @override
  Future<void> write(String value) async {
    _value = value;
  }
}

