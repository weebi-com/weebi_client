import 'dart:convert';

import 'package:auth_weebi/auth_weebi.dart'
    show AccessTokenObject, AccessTokenProvider, PermissionProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/grpc.dart' show ClientChannel;
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:users_weebi/src/l10n/user_ui_strings.dart';
import 'package:users_weebi/src/providers/user_provider.dart';
import 'package:users_weebi/src/widgets/user_create_view.dart';
import 'package:users_weebi/src/widgets/user_list_widget.dart';

String _fakeJwt({required String firmId}) {
  final header =
      base64Url.encode(utf8.encode(jsonEncode({'alg': 'none', 'typ': 'JWT'})));
  final body = base64Url.encode(utf8.encode(jsonEncode({
    'sub': 'user1',
    'userId': 'user1',
    'firmId': firmId,
    'exp': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
        1000,
  })));
  return '$header.$body.sig';
}

class _DummyChannel implements ClientChannel {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SeededUserProvider extends UserProvider {
  _SeededUserProvider(this._seeded)
      : super(FenceServiceClient(_DummyChannel()));

  final List<UserPublic> _seeded;

  @override
  List<UserPublic> get users => _seeded;

  @override
  Future<void> loadUsers() async {}
}

Widget _wrapCreateView({
  required AccessTokenProvider access,
  PermissionProvider? permissions,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AccessTokenProvider>.value(value: access),
      ChangeNotifierProvider<PermissionProvider>.value(
        value: permissions ?? PermissionProvider(access),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: UserCreateView(showFloatingActionButton: false),
      ),
    ),
  );
}

void main() {
  testWidgets('UserCreateView shows identity fields with a valid token',
      (tester) async {
    final access = AccessTokenProvider(
      AccessTokenObject()..value = _fakeJwt(firmId: 'firmA'),
    );

    await tester.pumpWidget(_wrapCreateView(access: access));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(UserCreateView), findsOneWidget);
    expect(find.text(UserUiStrings.labelFirstName), findsOneWidget);
    expect(find.text(UserUiStrings.labelLastName), findsOneWidget);
    expect(find.text(UserUiStrings.labelEmail), findsOneWidget);
    expect(find.text(UserUiStrings.createUser), findsOneWidget);
  });

  testWidgets('UserCreateView stays visible when firmId cannot be resolved',
      (tester) async {
    final access = AccessTokenProvider(AccessTokenObject());

    await tester.pumpWidget(_wrapCreateView(access: access));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(UserCreateView), findsOneWidget);
    expect(find.text(UserUiStrings.labelFirstName), findsOneWidget);
    expect(find.text(UserUiStrings.createUserMissingFirmId), findsOneWidget);
  });

  testWidgets('UserCreateView uses PermissionProvider firmId when JWT has none',
      (tester) async {
    final access = AccessTokenProvider(AccessTokenObject());
    final permissions = PermissionProvider(access)
      ..updateBffPermissions(UserPermissions.create()..firmId = 'bffFirm');

    await tester.pumpWidget(
      _wrapCreateView(access: access, permissions: permissions),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(UserUiStrings.labelFirstName), findsOneWidget);
    expect(find.text(UserUiStrings.createUserMissingFirmId), findsNothing);
  });

  testWidgets('FAB on user list pushes UserCreateView on the nearest navigator',
      (tester) async {
    final access = AccessTokenProvider(
      AccessTokenObject()..value = _fakeJwt(firmId: 'firmA'),
    );
    final users = [
      UserPublic.create()
        ..userId = 'u1'
        ..firstname = 'Ada'
        ..lastname = 'Lovelace'
        ..mail = 'ada@example.com',
    ];

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AccessTokenProvider>.value(value: access),
          ChangeNotifierProvider<PermissionProvider>.value(
            value: PermissionProvider(access),
          ),
          ChangeNotifierProvider<UserProvider>.value(
            value: _SeededUserProvider(users),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: UserListWidget(currentUserId: 'other'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(UserCreateView), findsOneWidget);
    expect(find.text(UserUiStrings.labelFirstName), findsOneWidget);
    expect(find.text(UserUiStrings.appBarCreateUser), findsOneWidget);
  });
}
