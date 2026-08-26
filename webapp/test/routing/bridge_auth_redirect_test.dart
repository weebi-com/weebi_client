import 'package:flutter_test/flutter_test.dart';
import 'package:web_admin/core/routing/routes.dart';
import 'package:web_admin/core/routing/bridge_auth_redirect.dart';

void main() {
  group('resolveGoRouterInitialLocation', () {
    test('prefers hash /bridge over document path /', () {
      final uri = Uri.parse(
        'https://cloud.weebi.com/?t=tok&product=syscohada&year=2025#/bridge',
      );
      expect(resolveGoRouterInitialLocation(uri), RouteUri.bridge);
    });

    test('strips hash query and keeps path', () {
      final uri = Uri.parse('https://cloud.weebi.com/#/bridge?t=legacy');
      expect(resolveGoRouterInitialLocation(uri), RouteUri.bridge);
    });

    test('falls back when fragment empty', () {
      final uri = Uri.parse('https://cloud.weebi.com/?t=tok');
      expect(resolveGoRouterInitialLocation(uri), RouteUri.home);
    });

    test('falls back when fragment is only /', () {
      final uri = Uri.parse('https://cloud.weebi.com/#/');
      expect(resolveGoRouterInitialLocation(uri), RouteUri.home);
    });

    test('keeps billing deep link', () {
      final uri = Uri.parse(
        'https://cloud.weebi.com/#/billing?product=premium',
      );
      expect(resolveGoRouterInitialLocation(uri), RouteUri.billing);
    });
  });

  group('resolveAuthRedirect', () {
    const unrestricted = unrestrictedRoutes;
    const public = publicRoutes;

    test('rescues magic-link token on / to /bridge when logged out', () {
      expect(
        resolveAuthRedirect(
          matchedLocation: RouteUri.home,
          isLoggedIn: false,
          hasFirm: false,
          isServiceAccount: false,
          documentQuery: {
            't': 'abc',
            'product': 'syscohada',
            'year': '2025',
          },
          unrestrictedRoutes: unrestricted,
          publicRoutes: public,
        ),
        RouteUri.bridge,
      );
    });

    test('rescues magic-link token on /dashboard to /bridge when logged out',
        () {
      expect(
        resolveAuthRedirect(
          matchedLocation: RouteUri.dashboard,
          isLoggedIn: false,
          hasFirm: false,
          isServiceAccount: false,
          documentQuery: {'t': 'abc', 'product': 'premium'},
          unrestrictedRoutes: unrestricted,
          publicRoutes: public,
        ),
        RouteUri.bridge,
      );
    });

    test('does not rescue /login (spent token / explicit login)', () {
      expect(
        resolveAuthRedirect(
          matchedLocation: RouteUri.login,
          isLoggedIn: false,
          hasFirm: false,
          isServiceAccount: false,
          documentQuery: {'t': 'abc', 'product': 'premium'},
          unrestrictedRoutes: unrestricted,
          publicRoutes: public,
        ),
        isNull,
      );
    });

    test('/bridge stays unrestricted when logged out', () {
      expect(
        resolveAuthRedirect(
          matchedLocation: RouteUri.bridge,
          isLoggedIn: false,
          hasFirm: false,
          isServiceAccount: false,
          documentQuery: {},
          unrestrictedRoutes: unrestricted,
          publicRoutes: public,
        ),
        isNull,
      );
    });

    test('protected /billing stays put while BFF session check is pending', () {
      expect(
        resolveAuthRedirect(
          matchedLocation: RouteUri.billing,
          isLoggedIn: false,
          hasFirm: false,
          isServiceAccount: false,
          isAuthCheckPending: true,
          documentQuery: {},
          unrestrictedRoutes: unrestricted,
          publicRoutes: public,
        ),
        isNull,
      );
    });

    test('protected /billing redirects to login when logged out', () {
      expect(
        resolveAuthRedirect(
          matchedLocation: RouteUri.billing,
          isLoggedIn: false,
          hasFirm: false,
          isServiceAccount: false,
          documentQuery: {},
          unrestrictedRoutes: unrestricted,
          publicRoutes: public,
        ),
        RouteUri.login,
      );
    });

    test('protected /billing allowed when logged in and has firm', () {
      expect(
        resolveAuthRedirect(
          matchedLocation: RouteUri.billing,
          isLoggedIn: true,
          hasFirm: true,
          isServiceAccount: false,
          documentQuery: {},
          unrestrictedRoutes: unrestricted,
          publicRoutes: public,
        ),
        isNull,
      );
    });

    test('protected /billing funnels to /create-firm when logged in but no firm',
        () {
      expect(
        resolveAuthRedirect(
          matchedLocation: RouteUri.billing,
          isLoggedIn: true,
          hasFirm: false,
          isServiceAccount: false,
          documentQuery: {},
          unrestrictedRoutes: unrestricted,
          publicRoutes: public,
        ),
        RouteUri.createFirm,
      );
    });

    test('service account allowed without firm', () {
      expect(
        resolveAuthRedirect(
          matchedLocation: RouteUri.billing,
          isLoggedIn: true,
          hasFirm: false,
          isServiceAccount: true,
          documentQuery: {},
          unrestrictedRoutes: unrestricted,
          publicRoutes: public,
        ),
        isNull,
      );
    });

    test('no rescue without t query on /', () {
      expect(
        resolveAuthRedirect(
          matchedLocation: RouteUri.home,
          isLoggedIn: false,
          hasFirm: false,
          isServiceAccount: false,
          documentQuery: {'product': 'premium'},
          unrestrictedRoutes: unrestricted,
          publicRoutes: public,
        ),
        RouteUri.login,
      );
    });
  });
}
