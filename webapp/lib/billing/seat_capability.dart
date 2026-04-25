import 'package:protos_weebi/protos_weebi_io.dart';

import 'license_seat_client.dart';

/// Subscription-backed capabilities in the portal (no firm-creator joker).
///
/// See `docs/entitlements.md`. Operational RPC access uses the server’s
/// `assertUserHasOperationalLicense` (joker OR seat); UI features
/// such as ticket store filter / grouping use **seat only** via this helper.
class SeatCapability {
  SeatCapability._();

  /// Whether [userId] has an active seat on a currently valid firm [licenses].
  static bool userHasActiveLicensedSeat(
    String userId,
    Iterable<License> licenses, {
    DateTime? now,
  }) =>
      LicenseSeatClient.userHasActiveLicensedSeat(userId, licenses, now: now);

  /// Store filter and “group by store” on the tickets overview (seat only).
  static bool ticketsBoutiqueViewsUnlocked(
    String userId,
    Iterable<License> licenses, {
    DateTime? now,
  }) =>
      userHasActiveLicensedSeat(userId, licenses, now: now);
}
