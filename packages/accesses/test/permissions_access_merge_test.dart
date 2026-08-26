import 'package:flutter_test/flutter_test.dart';
import 'package:accesses_weebi/src/permissions_access_merge.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

void main() {
  group('applyAccessSelection', () {
    late UserPermissions existing;

    setUp(() {
      existing = UserPermissions.create()
        ..userId = 'alice'
        ..firmId = 'firmA'
        ..isFirmCreator = false
        ..articleRights = ArticleRights(rights: [Right.create, Right.read])
        ..contactRights = ContactRights(rights: [Right.read])
        ..ticketRights = TicketRights(rights: [Right.read])
        ..limitedAccess = AccessLimited(
          chainIds: ChainIds(ids: ['old-chain']),
          boutiqueIds: BoutiqueIds(ids: ['old-btq']),
        );
    });

    test('limited access keeps firmId and article rights', () {
      final result = applyAccessSelection(
        existing: existing,
        hasFullAccess: false,
        chainIds: ['chain1'],
        boutiqueIds: ['btq1', 'btq2'],
      );

      expect(result.firmId, 'firmA');
      expect(result.userId, 'alice');
      expect(result.articleRights.rights, [Right.create, Right.read]);
      expect(result.hasLimitedAccess(), isTrue);
      expect(result.limitedAccess.chainIds.ids, ['chain1']);
      expect(result.limitedAccess.boutiqueIds.ids, ['btq1', 'btq2']);
      expect(result.hasFullAccess(), isFalse);
    });

    test('full access keeps firmId and rights', () {
      final result = applyAccessSelection(
        existing: existing,
        hasFullAccess: true,
        chainIds: const [],
        boutiqueIds: const [],
      );

      expect(result.firmId, 'firmA');
      expect(result.userId, 'alice');
      expect(result.articleRights.rights, [Right.create, Right.read]);
      expect(result.hasFullAccess(), isTrue);
      expect(result.fullAccess.hasFullAccess, isTrue);
      expect(result.hasLimitedAccess(), isFalse);
    });

    test('preserves isFirmCreator when switching access', () {
      existing.isFirmCreator = true;

      final result = applyAccessSelection(
        existing: existing,
        hasFullAccess: true,
        chainIds: const [],
        boutiqueIds: const [],
      );

      expect(result.isFirmCreator, isTrue);
      expect(result.firmId, 'firmA');
    });
  });
}
