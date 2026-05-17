import 'package:protos_weebi/protos_weebi_io.dart';

import 'license_seat_client.dart';

/// Matches server `firmCreatorOperationalJoker` in `entitlement_helpers.dart`: the firm
/// creator may use a **narrow** operational preview path without an attributed licence.
/// This is **not** a lifetime licence and does not cover licence-gated portal features.
/// See `docs/commercial-model.md` (no subscriptions).
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

/// Whether [license] is within its global validity window.
bool isLicenseCurrentlyValid(License license, {DateTime? now}) =>
    LicenseSeatClient.isLicenseCurrentlyValid(license, now: now);

/// True if [userId] has at least one active seat on a currently valid license.
bool userHasActiveLicensedSeat(
  String userId,
  Iterable<License> licenses, {
  DateTime? now,
}) =>
    LicenseSeatClient.userHasActiveLicensedSeat(userId, licenses, now: now);

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
      if (!LicenseSeatClient.isSeatTimeWindowActive(seat, at)) continue;
      assigned++;
    }
  }
  return FirmLicenseSeatSummary(
    totalCapacity: capacity,
    activeAssignedSeats: assigned,
  );
}
