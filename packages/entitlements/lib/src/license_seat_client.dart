import 'package:protos_weebi/protos_weebi_io.dart';

/// Low-level licence attribution validity (mirrors server [LicenseSeatEntitlement]).
///
/// Licences are **lifetime** purchases, not subscriptions; [License.validUntil] and
/// [LicenseSeat.validUntil] are for clean shutdown (abuse, etc.), not plan expiry.
/// See `docs/commercial-model.md`. For portal features, prefer [SeatCapability].
class LicenseSeatClient {
  LicenseSeatClient._();

  static DateTime timestampToUtc(Timestamp t) {
    final s = t.seconds.toInt();
    final n = t.nanos;
    final ms = s * 1000 + (n / 1000000).floor();
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  static bool isLicenseCurrentlyValid(License license, {DateTime? now}) {
    final at = now ?? DateTime.now().toUtc();
    if (!license.hasValidFrom()) return false;
    final from = timestampToUtc(license.validFrom);
    if (from.isAfter(at)) return false;
    if (license.hasValidUntil()) {
      final until = timestampToUtc(license.validUntil);
      if (until.isBefore(at)) return false;
    }
    return true;
  }

  static bool isSeatTimeWindowActive(LicenseSeat seat, DateTime at) {
    if (seat.hasValidFrom()) {
      final from = timestampToUtc(seat.validFrom);
      if (from.isAfter(at)) return false;
    }
    if (seat.hasValidUntil()) {
      final until = timestampToUtc(seat.validUntil);
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
        if (!isSeatTimeWindowActive(seat, at)) continue;
        return true;
      }
    }
    return false;
  }
}
