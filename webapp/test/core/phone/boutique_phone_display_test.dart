import 'package:flutter_test/flutter_test.dart';
import 'package:web_admin/core/phone/boutique_phone_display.dart';

void main() {
  test('formats the account phone the way Fence parses boutiquePhone', () {
    expect(
      formatBoutiquePhone(countryCode: 33, number: '612345678'),
      '+33 612345678',
    );
    expect(
      formatBoutiquePhone(countryCode: 221, number: ' 771234567 '),
      '+221 771234567',
    );
  });

  test('omits an empty number and a missing dial code', () {
    expect(formatBoutiquePhone(countryCode: 33, number: '  '), isEmpty);
    expect(formatBoutiquePhone(number: '771234567'), '771234567');
  });

  test('reads dial digits from a picker code', () {
    expect(dialCodeToInt('+221'), 221);
    expect(dialCodeToInt('33'), 33);
    expect(dialCodeToInt('+'), isNull);
    expect(dialCodeToInt(null), isNull);
  });
}
