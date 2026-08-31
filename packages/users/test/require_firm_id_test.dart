import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:users_weebi/src/require_firm_id.dart';

String _fakeJwt(Map<String, dynamic> payload) {
  final header =
      base64Url.encode(utf8.encode(jsonEncode({'alg': 'none', 'typ': 'JWT'})));
  final body = base64Url.encode(utf8.encode(jsonEncode(payload)));
  return '$header.$body.sig';
}

void main() {
  group('requireFirmIdFromAccessToken', () {
    test('returns firmId when present in payload', () {
      final token = _fakeJwt({
        'sub': 'user1',
        'firmId': 'firmA',
        'userId': 'user1',
      });
      expect(requireFirmIdFromAccessToken(token), 'firmA');
    });

    test('throws when firmId missing (proto3 omit)', () {
      final token = _fakeJwt({
        'sub': 'user1',
        'userId': 'user1',
      });
      expect(
        () => requireFirmIdFromAccessToken(token),
        throwsA(isA<StateError>()),
      );
    });

    test('throws when firmId is empty string', () {
      final token = _fakeJwt({
        'sub': 'user1',
        'firmId': '',
        'userId': 'user1',
      });
      expect(
        () => requireFirmIdFromAccessToken(token),
        throwsA(isA<StateError>()),
      );
    });

    test('throws when token is empty', () {
      expect(
        () => requireFirmIdFromAccessToken(''),
        throwsA(isA<StateError>()),
      );
    });
  });
}
