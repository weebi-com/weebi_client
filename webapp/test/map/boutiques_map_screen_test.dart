import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:web_admin/core/routing/routes.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/map/boutique_map_host.dart';
import 'package:web_admin/map/city_point.dart';
import 'package:web_admin/views/screens/map/boutiques_map_view.dart';

Widget _harness({
  required BoutiqueMapHost host,
  required bool unlocked,
  required List<BoutiquePin> pins,
  required List<UnplacedBoutique> unplaced,
}) {
  final router = GoRouter(
    initialLocation: RouteUri.map,
    routes: [
      GoRoute(
        path: RouteUri.map,
        builder: (context, state) => Scaffold(
          body: BoutiquesMapView(
            unlocked: unlocked,
            pins: pins,
            unplaced: unplaced,
            mapHost: host,
            mapView: const SizedBox.expand(
              child: ColoredBox(color: Color(0xFFE8EEF5)),
            ),
          ),
        ),
      ),
      GoRoute(
        path: RouteUri.billing,
        builder: (context, state) => const Scaffold(
          body: Text('billing'),
        ),
      ),
    ],
  );

  return MaterialApp.router(
    localizationsDelegates: const [
      Lang.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: Lang.delegate.supportedLocales,
    locale: const Locale('en'),
    routerConfig: router,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final pins = [
    BoutiquePin(
      boutiqueId: 'b1',
      name: 'Gombe Shop',
      chainId: 'c1',
      chainName: 'Food',
      city: 'Kinshasa',
      countryCode: 'CD',
      latitude: -4.3276,
      longitude: 15.3136,
      precision: PinPrecision.approximate,
    ),
    BoutiquePin(
      boutiqueId: 'b2',
      name: 'Plateau Shop',
      chainId: 'c2',
      chainName: 'Beauty',
      city: 'Dakar',
      countryCode: 'SN',
      latitude: 14.7167,
      longitude: -17.4677,
      precision: PinPrecision.approximate,
    ),
  ];

  final unplaced = [
    UnplacedBoutique(
      boutiqueId: 'b3',
      name: 'Nowhere Shop',
      chainId: 'c2',
      chainName: 'Beauty',
      city: 'Unknownville',
      countryCode: 'ZZ',
    ),
  ];

  testWidgets('locked user shows lock copy and never calls setPins',
      (tester) async {
    final host = RecordingMapHost();
    await tester.pumpWidget(
      _harness(
        host: host,
        unlocked: false,
        pins: pins,
        unplaced: unplaced,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Map requires an active license'), findsOneWidget);
    expect(find.text('Open Billing'), findsOneWidget);
    expect(host.setPinsCallCount, 0);
    expect(host.lastPins, isNull);
  });

  testWidgets('unlocked user pushes pins and lists unplaced', (tester) async {
    final host = RecordingMapHost();
    await tester.pumpWidget(
      _harness(
        host: host,
        unlocked: true,
        pins: pins,
        unplaced: unplaced,
      ),
    );
    await tester.pumpAndSettle();

    expect(host.setPinsCallCount, greaterThan(0));
    expect(host.lastPins, isNotNull);
    expect(host.lastPins!.map((p) => p.boutiqueId).toSet(), {'b1', 'b2'});
    expect(host.lastPins!.map((p) => p.chainName).toSet(), {'Food', 'Beauty'});
    expect(host.lastGroupBy, MapGroupBy.chainName);
    expect(find.textContaining('Nowhere Shop'), findsOneWidget);
    expect(find.textContaining('Without position'), findsOneWidget);
  });

  testWidgets('search focuses matching pin', (tester) async {
    final host = RecordingMapHost();
    await tester.pumpWidget(
      _harness(
        host: host,
        unlocked: true,
        pins: pins,
        unplaced: unplaced,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('mapSearchField')), 'Gombe');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(host.lastFocus?.boutiqueId, 'b1');
  });
}
