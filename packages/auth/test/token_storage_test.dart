import 'package:test/test.dart';
import 'package:auth_weebi/src/storage/token_storage.dart';

void main() {
  group('MemoryTokenStorage', () {
    test('initially empty', () async {
      final storage = MemoryTokenStorage();
      expect(await storage.read(), '');
    });

    test('write then read returns value', () async {
      final storage = MemoryTokenStorage();
      await storage.write('abc');
      expect(await storage.read(), 'abc');
    });

    test('clear resets to empty', () async {
      final storage = MemoryTokenStorage();
      await storage.write('abc');
      await storage.clear();
      expect(await storage.read(), '');
    });
  });
}
