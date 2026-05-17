import 'package:protos_weebi/protos_weebi_io.dart';

import 'license_seat_client.dart';

/// Portal capabilities that require an attributed **lifetime licence** (no firm-creator joker).
///
/// See `docs/commercial-model.md`: Weebi does not use subscriptions; `validUntil` is
/// for exceptional shutdown only, not renewal.
///
/// Operational RPC access uses the server's `assertUserHasOperationalLicense`
/// (joker OR licence); UI features such as ticket store filter / grouping and
/// boutique business rules require a licence via this helper.
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

  /// Edit boutique/chain business rules in the portal (seat only).
  static bool businessRulesEditable(
    String userId,
    Iterable<License> licenses, {
    DateTime? now,
  }) =>
      userHasActiveLicensedSeat(userId, licenses, now: now);
}
