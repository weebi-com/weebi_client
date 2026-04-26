import 'package:protos_weebi/protos_weebi_io.dart';

/// Matches server `firmCreatorOperationalJoker` in `entitlement_helpers.dart`: the firm
/// creator may use a **narrow** operational preview path (ticket / article / contact
/// RPCs) without an assigned seat. This is **not** a subscription seat and does not
/// cover seat-gated product features. See `weebi_server/doc/entitlements.md`.
bool firmCreatorOperationalJoker(UserPermissions permissions) =>
    permissions.isFirmCreator;

/// Seat counts for currently valid licenses (same rules as server operational gate).
class FirmLicenseSeatSummary {
  /// Sum of [License.maxUsers] across licenses that are valid for [now].
  final int totalCapacity;

  /// [LicenseSeat] entries with a non-empty [LicenseSeat.userId] and active validity
  /// on a currently valid license.
  final int activeAssignedSeats;

  const FirmLicenseSeatSummary({
    required this.totalCapacity,
    required this.activeAssignedSeats,
  });
}

DateTime _timestampToUtc(Timestamp t) {
  final s = t.seconds.toInt();
  final n = t.nanos;
  final ms = s * 1000 + (n / 1000000).floor();
  return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
}

/// Whether [license] is within its global validity window.
bool isLicenseCurrentlyValid(License license, {DateTime? now}) {
  final at = now ?? DateTime.now().toUtc();
  if (!license.hasValidFrom()) return false;
  final from = _timestampToUtc(license.validFrom);
  if (from.isAfter(at)) return false;
  if (license.hasValidUntil()) {
    final until = _timestampToUtc(license.validUntil);
    if (until.isBefore(at)) return false;
  }
  return true;
}

bool _isSeatTimeWindowActive(LicenseSeat seat, DateTime at) {
  if (seat.hasValidFrom()) {
    final from = _timestampToUtc(seat.validFrom);
    if (from.isAfter(at)) return false;
  }
  if (seat.hasValidUntil()) {
    final until = _timestampToUtc(seat.validUntil);
    if (until.isBefore(at)) return false;
  }
  return true;
}

/// True if [userId] has at least one active seat on a currently valid license.
bool userHasActiveLicensedSeat(
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

/// Aggregates capacity and assigned seats for valid licenses at [now].
FirmLicenseSeatSummary summarizeFirmLicenseSeats(
  Iterable<License> licenses, {
  DateTime? now,
}) {
  final at = now ?? DateTime.now().toUtc();
  var capacity = 0;
  var assigned = 0;
  for (final license in licenses) {
    if (!isLicenseCurrentlyValid(license, now: at)) continue;
    capacity += license.maxUsers;
    for (final seat in license.seats) {
      if (seat.userId.trim().isEmpty) continue;
      if (!_isSeatTimeWindowActive(seat, at)) continue;
      assigned++;
    }
  }
  return FirmLicenseSeatSummary(
    totalCapacity: capacity,
    activeAssignedSeats: assigned,
  );
}
