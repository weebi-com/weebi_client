import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:users_weebi/src/l10n/user_ui_strings.dart';
import 'package:users_weebi/src/providers/user_provider.dart';

/// Fence client that must never be called — used to prove createUser guards
/// empty firmId before the RPC.
class _NeverCallFenceClient implements FenceServiceClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    fail('FenceServiceClient must not be called: ${invocation.memberName}');
  }
}

void main() {
  group('UserProvider.createUser firmId guard', () {
    test('throws ArgumentError when permissions.firmId is empty', () async {
      final provider = UserProvider(_NeverCallFenceClient());
      final user = UserPublic.create()
        ..firstname = 'A'
        ..lastname = 'B'
        ..mail = 'a@b.com'
        ..permissions = UserPermissions.create(); // empty firmId

      expect(
        () => provider.createUser(user),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          UserUiStrings.createUserMissingFirmId,
        )),
      );
    });
  });
}
