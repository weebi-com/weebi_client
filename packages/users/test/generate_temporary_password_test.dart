import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:users_weebi/src/generate_temporary_password.dart';

void main() {
  test('generateTemporaryPassword is 12 chars from the allowed set', () {
    final password = generateTemporaryPassword(random: Random(42));
    expect(password.length, 12);
    expect(password.contains(RegExp(r'[0OIl1]')), isFalse);
  });

  test('different seeds produce different passwords', () {
    final a = generateTemporaryPassword(random: Random(1));
    final b = generateTemporaryPassword(random: Random(2));
    expect(a, isNot(b));
  });
}
