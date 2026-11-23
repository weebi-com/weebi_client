import 'package:entitlements_weebi/entitlements_weebi.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

/// Whether [userId] may open the boutiques map (attributed active seat).
///
/// Same rule as ticket store views: no firm-creator joker.
bool mapViewUnlocked(
  String userId,
  Iterable<License> licenses, {
  DateTime? now,
}) =>
    SeatCapability.userHasActiveLicensedSeat(userId, licenses, now: now);
