import 'package:models_weebi/models.dart' show DeviceCloudIdentity;
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:protos_weebi/data_dummy.dart';

/// Creates default permissions for offline use when no token is available
///
/// Provides minimal rights based on device enrollment:
/// - Salesperson-level article and ticket rights
/// - Read-only contact access
/// - Limited to the device's boutique and chain
///
/// These permissions allow the app to function offline without a login,
/// enabling basic operations like viewing articles and creating tickets.
UserPermissions createDefaultPermissions(DeviceCloudIdentity cloudIdentity) {
  return UserPermissions.create()
    ..firmId = cloudIdentity.firmId
    ..articleRights = RightSalesperson.article
    ..boutiqueRights = RightSalesperson.boutique
    ..contactRights = RightSalesperson.contact
    ..ticketRights = RightSalesperson.ticket
    ..limitedAccess = AccessLimited(
      boutiqueIds: BoutiqueIds(ids: [cloudIdentity.boutiqueId]),
      chainIds: ChainIds(ids: [cloudIdentity.chainId]),
    );
}
