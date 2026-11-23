import 'package:flutter_test/flutter_test.dart';
import 'package:web_admin/map/boutique_map_model.dart';
import 'package:web_admin/map/capital_city_table.dart';
import 'package:web_admin/map/city_geocoder.dart';
import 'package:web_admin/map/city_point.dart';

import 'chain_fixture.dart';

class RecordingGeocoder implements CityGeocoder {
  RecordingGeocoder({this.result});

  final CityPoint? result;
  final List<String> calls = [];

  @override
  Future<CityPoint?> locate(String city, String countryCode) async {
    calls.add('$city|$countryCode');
    return result;
  }
}

void main() {
  group('buildBoutiqueMap', () {
    test('stored coordinates win over the city table', () async {
      final chains = [
        chainFixture(
          chainId: 'c1',
          name: 'Food',
          boutiques: [
            boutiqueFixture(
              boutiqueId: 'b1',
              name: 'Gombe Precise',
              chainId: 'c1',
              city: 'Kinshasa',
              countryCode: 'CD',
              latitude: -4.3,
              longitude: 15.3,
            ),
          ],
        ),
      ];
      final result = await buildBoutiqueMap(chains);
      expect(result.pins, hasLength(1));
      expect(result.pins.first.latitude, -4.3);
      expect(result.pins.first.longitude, 15.3);
      expect(result.pins.first.precision, PinPrecision.precise);
      expect(result.unplaced, isEmpty);
    });

    test('0,0 plus Kinshasa/CD becomes approximate pin from table', () async {
      final table = CapitalCityTable.lookup('Kinshasa', 'CD')!;
      final chains = [
        chainFixture(
          chainId: 'c1',
          name: 'Food',
          boutiques: [
            boutiqueFixture(
              boutiqueId: 'b1',
              name: 'Gombe',
              chainId: 'c1',
              city: 'Kinshasa',
              countryCode: 'CD',
            ),
          ],
        ),
      ];
      final result = await buildBoutiqueMap(chains);
      expect(result.pins, hasLength(1));
      expect(result.pins.first.latitude, table.latitude);
      expect(result.pins.first.longitude, table.longitude);
      expect(result.pins.first.precision, PinPrecision.approximate);
    });

    test('case and accents match capital table', () async {
      final table = CapitalCityTable.lookup('Yaoundé', 'CM')!;
      final chains = [
        chainFixture(
          chainId: 'c1',
          name: 'Beauty',
          boutiques: [
            boutiqueFixture(
              boutiqueId: 'b1',
              name: 'Centre',
              chainId: 'c1',
              city: '  YAOUNDÉ ',
              countryCode: 'cm',
            ),
          ],
        ),
      ];
      final result = await buildBoutiqueMap(chains);
      expect(result.pins, hasLength(1));
      expect(result.pins.first.latitude, table.latitude);
      expect(result.pins.first.longitude, table.longitude);
    });

    test('two boutiques in one capital share lat/lng and keep chain names',
        () async {
      final table = CapitalCityTable.lookup('Dakar', 'SN')!;
      final chains = [
        chainFixture(
          chainId: 'c1',
          name: 'Food',
          boutiques: [
            boutiqueFixture(
              boutiqueId: 'b1',
              name: 'Plateau A',
              chainId: 'c1',
              city: 'Dakar',
              countryCode: 'SN',
            ),
          ],
        ),
        chainFixture(
          chainId: 'c2',
          name: 'Beauty',
          boutiques: [
            boutiqueFixture(
              boutiqueId: 'b2',
              name: 'Plateau B',
              chainId: 'c2',
              city: 'Dakar',
              countryCode: 'SN',
            ),
          ],
        ),
      ];
      final result = await buildBoutiqueMap(chains);
      expect(result.pins, hasLength(2));
      expect(result.pins[0].latitude, table.latitude);
      expect(result.pins[1].latitude, table.latitude);
      expect(result.pins[0].longitude, table.longitude);
      expect(result.pins[1].longitude, table.longitude);
      expect(result.pins.map((p) => p.chainName).toSet(), {'Food', 'Beauty'});
    });

    test('unknown city and null geocoder goes to unplaced', () async {
      final geocoder = RecordingGeocoder(result: null);
      final chains = [
        chainFixture(
          chainId: 'c1',
          name: 'Food',
          boutiques: [
            boutiqueFixture(
              boutiqueId: 'b1',
              name: 'Somewhere',
              chainId: 'c1',
              city: 'Unknownville',
              countryCode: 'ZZ',
            ),
          ],
        ),
      ];
      final result = await buildBoutiqueMap(chains, geocoder: geocoder);
      expect(result.pins, isEmpty);
      expect(result.unplaced, hasLength(1));
      expect(result.unplaced.first.boutiqueId, 'b1');
      expect(geocoder.calls, ['Unknownville|ZZ']);
    });

    test('unknown city geocoder called once then cached for two boutiques',
        () async {
      const point = CityPoint(latitude: 14.7, longitude: -17.4);
      final geocoder = RecordingGeocoder(result: point);
      final caching = CachingCityGeocoder(geocoder);
      final chains = [
        chainFixture(
          chainId: 'c1',
          name: 'Food',
          boutiques: [
            boutiqueFixture(
              boutiqueId: 'b1',
              name: 'A',
              chainId: 'c1',
              city: 'Thiès',
              countryCode: 'SN',
            ),
            boutiqueFixture(
              boutiqueId: 'b2',
              name: 'B',
              chainId: 'c1',
              city: 'Thies',
              countryCode: 'SN',
            ),
          ],
        ),
      ];
      final result = await buildBoutiqueMap(chains, geocoder: caching);
      expect(result.pins, hasLength(2));
      expect(result.pins.every((p) => p.latitude == point.latitude), isTrue);
      expect(geocoder.calls, hasLength(1));
    });

    test('deleted boutiques are omitted', () async {
      final chains = [
        chainFixture(
          chainId: 'c1',
          name: 'Food',
          boutiques: [
            boutiqueFixture(
              boutiqueId: 'b1',
              name: 'Alive',
              chainId: 'c1',
              city: 'Dakar',
              countryCode: 'SN',
            ),
            boutiqueFixture(
              boutiqueId: 'b2',
              name: 'Gone',
              chainId: 'c1',
              city: 'Dakar',
              countryCode: 'SN',
              isDeleted: true,
            ),
          ],
        ),
      ];
      final result = await buildBoutiqueMap(chains);
      expect(result.pins.map((p) => p.boutiqueId), ['b1']);
    });

    test('empty chains yield no pins', () async {
      final result = await buildBoutiqueMap(const []);
      expect(result.pins, isEmpty);
      expect(result.unplaced, isEmpty);
      expect(boundsFor(result.pins), isNull);
    });
  });

  group('findPin', () {
    final pins = [
      BoutiquePin(
        boutiqueId: 'b1',
        name: 'Gombe Shop',
        chainId: 'c1',
        chainName: 'Food Chain',
        city: 'Kinshasa',
        countryCode: 'CD',
        latitude: -4.3,
        longitude: 15.3,
        precision: PinPrecision.precise,
      ),
    ];

    test('hits a name', () {
      expect(findPin(pins, 'gombe')?.boutiqueId, 'b1');
      expect(findPin(pins, 'food')?.boutiqueId, 'b1');
    });

    test('misses garbage', () {
      expect(findPin(pins, 'zzzz'), isNull);
      expect(findPin(pins, '  '), isNull);
    });
  });

  group('boundsFor', () {
    test('spans southern and northern pins', () {
      final pins = [
        BoutiquePin(
          boutiqueId: 'south',
          name: 'S',
          chainId: 'c',
          chainName: 'C',
          city: '',
          countryCode: '',
          latitude: -4.0,
          longitude: 15.0,
          precision: PinPrecision.precise,
        ),
        BoutiquePin(
          boutiqueId: 'north',
          name: 'N',
          chainId: 'c',
          chainName: 'C',
          city: '',
          countryCode: '',
          latitude: 14.0,
          longitude: -17.0,
          precision: PinPrecision.precise,
        ),
      ];
      final bounds = boundsFor(pins)!;
      expect(bounds.south, -4.0);
      expect(bounds.north, 14.0);
      expect(bounds.west, -17.0);
      expect(bounds.east, 15.0);
    });
  });
}
