import 'package:entitlements_weebi/entitlements_weebi.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

Timestamp _utc(int year, int month, int day) {
  final dt = DateTime.utc(year, month, day);
  return Timestamp()
    ..seconds = Int64(dt.millisecondsSinceEpoch ~/ 1000)
    ..nanos = 0;
}

License _license({
  required Timestamp validFrom,
  Timestamp? validUntil,
  int maxUsers = 5,
  List<LicenseSeat>? seats,
}) {
  final l = License()
    ..validFrom = validFrom
    ..maxUsers = maxUsers;
  if (validUntil != null) {
    l.validUntil = validUntil;
  }
  if (seats != null) {
    l.seats.addAll(seats);
  }
  return l;
}

LicenseSeat _seat(String userId, {Timestamp? validFrom, Timestamp? validUntil}) {
  final s = LicenseSeat()..userId = userId;
  if (validFrom != null) s.validFrom = validFrom;
  if (validUntil != null) s.validUntil = validUntil;
  return s;
}

void main() {
  final now = DateTime.utc(2025, 6, 15, 12);

  group('LicenseSeatClient.isLicenseCurrentlyValid', () {
    test('false when validFrom missing', () {
      expect(
        LicenseSeatClient.isLicenseCurrentlyValid(License(), now: now),
        isFalse,
      );
    });

    test('false when license not yet started', () {
      final license = _license(validFrom: _utc(2026, 1, 1));
      expect(
        LicenseSeatClient.isLicenseCurrentlyValid(license, now: now),
        isFalse,
      );
    });

    test('false when license expired', () {
      final license = _license(
        validFrom: _utc(2024, 1, 1),
        validUntil: _utc(2025, 1, 1),
      );
      expect(
        LicenseSeatClient.isLicenseCurrentlyValid(license, now: now),
        isFalse,
      );
    });

    test('true when within window', () {
      final license = _license(
        validFrom: _utc(2025, 1, 1),
        validUntil: _utc(2026, 1, 1),
      );
      expect(
        LicenseSeatClient.isLicenseCurrentlyValid(license, now: now),
        isTrue,
      );
    });
  });

  group('userHasActiveLicensedSeat', () {
    test('false for empty userId', () {
      final licenses = [
        _license(
          validFrom: _utc(2025, 1, 1),
          seats: [_seat('user_1')],
        ),
      ];
      expect(userHasActiveLicensedSeat('', licenses, now: now), isFalse);
    });

    test('true when user has seat on valid license', () {
      final licenses = [
        _license(
          validFrom: _utc(2025, 1, 1),
          seats: [_seat('user_1')],
        ),
      ];
      expect(userHasActiveLicensedSeat('user_1', licenses, now: now), isTrue);
    });

    test('false when seat expired', () {
      final licenses = [
        _license(
          validFrom: _utc(2025, 1, 1),
          seats: [
            _seat(
              'user_1',
              validUntil: _utc(2025, 6, 1),
            ),
          ],
        ),
      ];
      expect(userHasActiveLicensedSeat('user_1', licenses, now: now), isFalse);
    });

    test('finds seat across multiple licenses', () {
      final licenses = [
        _license(validFrom: _utc(2024, 1, 1), validUntil: _utc(2025, 1, 1)),
        _license(
          validFrom: _utc(2025, 1, 1),
          seats: [_seat('user_2')],
        ),
      ];
      expect(userHasActiveLicensedSeat('user_2', licenses, now: now), isTrue);
    });
  });

  group('summarizeFirmLicenseSeats', () {
    test('counts capacity and assigned seats', () {
      final licenses = [
        _license(
          validFrom: _utc(2025, 1, 1),
          maxUsers: 10,
          seats: [_seat('a'), _seat('b'), LicenseSeat()],
        ),
        _license(validFrom: _utc(2024, 1, 1), validUntil: _utc(2025, 1, 1)),
      ];
      final summary = summarizeFirmLicenseSeats(licenses, now: now);
      expect(summary.totalCapacity, 10);
      expect(summary.activeAssignedSeats, 2);
    });
  });

  group('SeatCapability', () {
    test('businessRulesEditable matches active seat', () {
      final licenses = [
        _license(
          validFrom: _utc(2025, 1, 1),
          seats: [_seat('u1')],
        ),
      ];
      expect(
        SeatCapability.businessRulesEditable('u1', licenses, now: now),
        isTrue,
      );
      expect(
        SeatCapability.businessRulesEditable('other', licenses, now: now),
        isFalse,
      );
    });
  });
}
