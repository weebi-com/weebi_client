import 'package:gatekeeper_weebi/gatekeeper_weebi.dart';
import 'package:test/test.dart';

void main() {
  group('Gatekeeper', () {
    test('package exports are available', () {
      // Verify main exports are accessible
      expect(Gatekeeper, isNotNull);
      expect(DeviceManager, isNotNull);
      expect(UserSession, isNotNull);
      expect(MailManager, isNotNull);
    });
  });
}
