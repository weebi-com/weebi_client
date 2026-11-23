import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/map/map_license.dart';

Timestamp _utc(int year, int month, int day) {
  final dt = DateTime.utc(year, month, day);
  return Timestamp()
    ..seconds = Int64(dt.millisecondsSinceEpoch ~/ 1000)
    ..nanos = 0;
}

License _license({
  required Timestamp validFrom,
  Timestamp? validUntil,
  List<LicenseSeat>? seats,
}) {
  final l = License()
    ..validFrom = validFrom
    ..maxUsers = 5;
  if (validUntil != null) l.validUntil = validUntil;
  if (seats != null) l.seats.addAll(seats);
  return l;
}

LicenseSeat _seat(String userId) => LicenseSeat()..userId = userId;

void main() {
  final now = DateTime.utc(2025, 6, 15, 12);

  group('mapViewUnlocked', () {
    test('empty user id is locked', () {
      final licenses = [
        _license(validFrom: _utc(2025, 1, 1), seats: [_seat('user_1')]),
      ];
      expect(mapViewUnlocked('', licenses, now: now), isFalse);
    });

    test('no licenses is locked', () {
      expect(mapViewUnlocked('user_1', const [], now: now), isFalse);
    });

    test('seat on another user is locked', () {
      final licenses = [
        _license(validFrom: _utc(2025, 1, 1), seats: [_seat('other')]),
      ];
      expect(mapViewUnlocked('user_1', licenses, now: now), isFalse);
    });

    test('seat whose license validUntil is in the past is locked', () {
      final licenses = [
        _license(
          validFrom: _utc(2024, 1, 1),
          validUntil: _utc(2025, 1, 1),
          seats: [_seat('user_1')],
        ),
      ];
      expect(mapViewUnlocked('user_1', licenses, now: now), isFalse);
    });

    test('active seat for this user is unlocked', () {
      final licenses = [
        _license(validFrom: _utc(2025, 1, 1), seats: [_seat('user_1')]),
      ];
      expect(mapViewUnlocked('user_1', licenses, now: now), isTrue);
    });

    test('firm creator without seat stays locked', () {
      // mapViewUnlocked only looks at seats; being firm creator is irrelevant.
      final licenses = [
        _license(validFrom: _utc(2025, 1, 1), seats: [_seat('someone_else')]),
      ];
      expect(mapViewUnlocked('firm_creator', licenses, now: now), isFalse);
    });
  });
}
