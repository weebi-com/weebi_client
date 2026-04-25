import 'package:protos_weebi/protos_weebi_io.dart';

/// Low-level seat validity (mirrors server [LicenseSeatEntitlement]).
///
/// For subscription-backed portal features, prefer `SeatCapability`.
class LicenseSeatClient {
  static DateTime _toDateTime(Timestamp t) {
    final s = t.seconds.toInt();
    final n = t.nanos;
    final ms = s * 1000 + (n / 1000000).floor();
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  static bool isLicenseCurrentlyValid(License license, {DateTime? now}) {
    final at = now ?? DateTime.now().toUtc();
    if (!license.hasValidFrom()) return false;
    final from = _toDateTime(license.validFrom);
    if (from.isAfter(at)) return false;
    if (license.hasValidUntil()) {
      final until = _toDateTime(license.validUntil);
      if (until.isBefore(at)) return false;
    }
    return true;
  }

  static bool _isSeatTimeWindowActive(LicenseSeat seat, DateTime at) {
    if (seat.hasValidFrom()) {
      final from = _toDateTime(seat.validFrom);
      if (from.isAfter(at)) return false;
    }
    if (seat.hasValidUntil()) {
      final until = _toDateTime(seat.validUntil);
      if (until.isBefore(at)) return false;
    }
    return true;
  }

  static bool userHasActiveLicensedSeat(
    String userId,
    Iterable<License> licenses, {
    DateTime? now,
  }) {
    final uid = userId.trim();
    if (uid.isEmpty) return false;
    final at = now ?? DateTime.now().toUtc();
    for (final license in licenses) {
      if (!isLicenseCurrentlyValid(license, now: at)) continue;
      for (final seat in license.seats) {
        if (seat.userId.trim() != uid) continue;
        if (!_isSeatTimeWindowActive(seat, at)) continue;
        return true;
      }
    }
    return false;
  }
}
