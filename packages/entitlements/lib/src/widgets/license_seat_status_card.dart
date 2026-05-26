import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

import '../firm_license_seat_summary.dart';
import '../l10n/entitlement_ui_strings.dart';

/// Shows whether [userId] has an active attributed licence on [licenses].
///
/// When [subjectIsFirmCreator] is true and there is no licence, copy reflects the
/// firm-creator preview path — not a lifetime licence. See `docs/commercial-model.md`.
///
/// Default copy is French ([EntitlementUiStrings]); sign-in is allowed without a seat.
class LicenseSeatStatusCard extends StatelessWidget {
  final String userId;
  final Iterable<License> licenses;

  /// From [UserPermissions.isFirmCreator] for the **subject** user (this card's [userId]).
  final bool subjectIsFirmCreator;

  const LicenseSeatStatusCard({
    super.key,
    required this.userId,
    required this.licenses,
    this.subjectIsFirmCreator = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasSeat = userHasActiveLicensedSeat(userId, licenses);
    final creatorNoSeat = !hasSeat && subjectIsFirmCreator;

    late final IconData icon;
    late final Color iconColor;
    if (hasSeat) {
      icon = Icons.verified_user;
      iconColor = Colors.green[700]!;
    } else if (creatorNoSeat) {
      icon = Icons.info_outline;
      iconColor = Colors.blue[800]!;
    } else {
      icon = Icons.warning_amber_rounded;
      iconColor = Colors.orange[800]!;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          hasSeat
              ? EntitlementUiStrings.seatCardTitleActive
              : EntitlementUiStrings.seatCardTitleNone,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          hasSeat
              ? EntitlementUiStrings.seatCardSubtitleActive
              : creatorNoSeat
                  ? EntitlementUiStrings.seatCardSubtitleNoneFirmCreator
                  : EntitlementUiStrings.seatCardSubtitleNone,
        ),
      ),
    );
  }
}
