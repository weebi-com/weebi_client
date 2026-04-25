import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:provider/provider.dart';
import 'package:users_weebi/weebi_users.dart';

Future<void> _expandSection(WidgetTester tester, String sectionTitle) async {
  final finder = find.text(sectionTitle).first;
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _expandUserManagement(WidgetTester tester) async {
  await _expandSection(tester, PermissionsUiStrings.sectionUserManagement);
}

void _tallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

UserPermissions _samplePermissions(String userId) {
  return UserPermissions.create()
    ..userId = userId
    ..firmId = 'firm1'
    ..articleRights = ArticleRights(rights: [Right.read, Right.create])
    ..contactRights = ContactRights(rights: [Right.read])
    ..ticketRights = TicketRights(rights: [Right.read])
    ..userManagementRights = UserManagementRights(
      rights: [Right.read, Right.update],
      canUpdateUserPassword: true,
    )
    ..boolRights = (BoolRights.create()..canSeeStats = true);
}

UserPublic _userWithPermissions(String userId) {
  return UserPublic.create()
    ..userId = userId
    ..mail = 'a@b.com'
    ..firstname = 'Jean'
    ..lastname = 'Test'
    ..permissions = _samplePermissions(userId);
}

class _DetailTestUserProvider extends UserProvider {
  _DetailTestUserProvider() : super(FenceServiceClient(_DummyChannel()));

  @override
  Future<UserPermissions?> getUserPermissions(
    String userId, {
    bool forceRefresh = false,
  }) async =>
      _samplePermissions(userId);
}

class _DummyChannel implements ClientChannel {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
      'viewing own user: user management frozen; other sections stay editable',
      (WidgetTester tester) async {
    _tallViewport(tester);
    const uid = 'user-self';
    final user = _userWithPermissions(uid);
    final provider = _DetailTestUserProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<UserProvider>.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: UserDetailWidget(
                user: user,
                userProvider: provider,
                currentUserId: uid,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _expandUserManagement(tester);
    expect(find.text(UserUiStrings.selfPermissionsReadOnlyHint), findsOneWidget);
    expect(find.text(PermissionsUiStrings.canUpdateUserPassword), findsOneWidget);
    expect(find.byType(Switch), findsNothing);
    expect(find.byType(Checkbox), findsWidgets);

    await _expandSection(tester, PermissionsUiStrings.sectionArticles);
    expect(find.byType(Switch), findsWidgets);
  });

  testWidgets('viewing another user: permission rows use Switch (editable)',
      (WidgetTester tester) async {
    _tallViewport(tester);
    const selfId = 'admin-1';
    const otherId = 'user-other';
    final user = _userWithPermissions(otherId);
    final provider = _DetailTestUserProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<UserProvider>.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: UserDetailWidget(
                user: user,
                userProvider: provider,
                currentUserId: selfId,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(UserUiStrings.selfPermissionsReadOnlyHint), findsNothing);
    await _expandUserManagement(tester);
    expect(find.byType(Switch), findsWidgets);
  });
}
