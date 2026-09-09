import 'package:flutter_test/flutter_test.dart';
import 'package:web_admin/core/routing/bridge_auth_redirect.dart';

/// VM-safe: does not import app_router (pulls grpc/web).
void main() {
  const unrestricted = [
    '/404',
    '/logout',
    '/login',
    '/register',
    '/bridge',
    '/legal/terms',
    '/legal/cgv',
    '/legal/cgv-accounting-report',
  ];
  const public = <String>[];

  test('firmless boss is sent to /create-firm', () {
    expect(
      resolveAuthRedirect(
        matchedLocation: '/dashboard',
        isLoggedIn: true,
        documentQuery: {},
        unrestrictedRoutes: unrestricted,
        publicRoutes: public,
        canCreateFirm: true,
        firmId: '',
      ),
      '/create-firm',
    );
  });

  test('already on /create-firm stays there', () {
    expect(
      resolveAuthRedirect(
        matchedLocation: '/create-firm',
        isLoggedIn: true,
        documentQuery: {},
        unrestrictedRoutes: unrestricted,
        publicRoutes: public,
        canCreateFirm: true,
        firmId: '',
      ),
      isNull,
    );
  });

  test('invited user without create-firm right is not redirected', () {
    expect(
      resolveAuthRedirect(
        matchedLocation: '/dashboard',
        isLoggedIn: true,
        documentQuery: {},
        unrestrictedRoutes: unrestricted,
        publicRoutes: public,
        canCreateFirm: false,
        firmId: '',
      ),
      isNull,
    );
  });

  test('boss with a firm stays on dashboard', () {
    expect(
      resolveAuthRedirect(
        matchedLocation: '/dashboard',
        isLoggedIn: true,
        documentQuery: {},
        unrestrictedRoutes: unrestricted,
        publicRoutes: public,
        canCreateFirm: false,
        firmId: 'firm-1',
      ),
      isNull,
    );
  });

  test('logged-out user is sent to login, not create-firm', () {
    expect(
      resolveAuthRedirect(
        matchedLocation: '/dashboard',
        isLoggedIn: false,
        documentQuery: {},
        unrestrictedRoutes: unrestricted,
        publicRoutes: public,
        canCreateFirm: true,
        firmId: '',
      ),
      '/login',
    );
  });
}
