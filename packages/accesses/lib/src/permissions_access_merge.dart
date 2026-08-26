import 'package:protos_weebi/protos_weebi_io.dart';

/// Applies chain/boutique access selection onto an existing [UserPermissions]
/// without wiping identity fields (`firmId`, `userId`, rights, `isFirmCreator`).
UserPermissions applyAccessSelection({
  required UserPermissions existing,
  required bool hasFullAccess,
  required Iterable<String> chainIds,
  required Iterable<String> boutiqueIds,
}) {
  final result = UserPermissions.create()..mergeFromMessage(existing);

  if (hasFullAccess) {
    result.clearLimitedAccess();
    result.fullAccess = AccessFull.create()..hasFullAccess = true;
  } else {
    result.clearFullAccess();
    final limited = AccessLimited.create();
    limited.chainIds = ChainIds.create()..ids.addAll(chainIds);
    limited.boutiqueIds = BoutiqueIds.create()..ids.addAll(boutiqueIds);
    result.limitedAccess = limited;
  }

  return result;
}
