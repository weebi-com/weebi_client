import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/map/capital_city_table.dart';
import 'package:web_admin/map/city_geocoder.dart';
import 'package:web_admin/map/city_normalize.dart';
import 'package:web_admin/map/city_point.dart';

bool hasStoredCoordinates(Address address) {
  return address.latitude != 0 && address.longitude != 0;
}

/// Walks [chains] and resolves each boutique to a pin or an unplaced entry.
///
/// Order per boutique: stored lat/lng (non-zero) → [CapitalCityTable] →
/// [geocoder]. Deleted boutiques are skipped. `(0,0)` is never a pin.
Future<BoutiqueMapResult> buildBoutiqueMap(
  Iterable<Chain> chains, {
  CityGeocoder geocoder = const NullCityGeocoder(),
}) async {
  final pins = <BoutiquePin>[];
  final unplaced = <UnplacedBoutique>[];
  // Shared cache across this build so two boutiques in the same unknown city
  // only hit the geocoder once even without CachingCityGeocoder.
  final resolveCache = <String, CityPoint?>{};

  for (final chain in chains) {
    if (chain.isDeleted) continue;
    final chainName = chain.name.trim().isNotEmpty ? chain.name.trim() : chain.chainId;
    for (final boutiqueMongo in chain.boutiques) {
      if (boutiqueMongo.isDeleted) continue;
      final boutique = boutiqueMongo.boutique;
      if (boutique.isDeleted) continue;

      final boutiqueId = boutiqueMongo.boutiqueId.isNotEmpty
          ? boutiqueMongo.boutiqueId
          : boutique.boutiqueId;
      if (boutiqueId.isEmpty) continue;

      final name = boutiqueMongo.name.trim().isNotEmpty
          ? boutiqueMongo.name.trim()
          : (boutique.name.trim().isNotEmpty ? boutique.name.trim() : boutiqueId);
      final chainId = boutiqueMongo.chainId.isNotEmpty
          ? boutiqueMongo.chainId
          : chain.chainId;
      final address = boutique.addressFull;
      final city = address.city;
      final countryCode = address.hasCountry()
          ? normalizeCountryCode(address.country.code2Letters)
          : '';

      if (hasStoredCoordinates(address)) {
        pins.add(
          BoutiquePin(
            boutiqueId: boutiqueId,
            name: name,
            chainId: chainId,
            chainName: chainName,
            city: city,
            countryCode: countryCode,
            latitude: address.latitude,
            longitude: address.longitude,
            precision: PinPrecision.precise,
          ),
        );
        continue;
      }

      CityPoint? point = CapitalCityTable.lookup(city, countryCode);
      if (point != null) {
        pins.add(
          BoutiquePin(
            boutiqueId: boutiqueId,
            name: name,
            chainId: chainId,
            chainName: chainName,
            city: city,
            countryCode: countryCode,
            latitude: point.latitude,
            longitude: point.longitude,
            precision: PinPrecision.approximate,
          ),
        );
        continue;
      }

      final cacheKey =
          '${normalizeCityName(city)}|${normalizeCountryCode(countryCode)}';
      if (normalizeCityName(city).isEmpty || countryCode.isEmpty) {
        unplaced.add(
          UnplacedBoutique(
            boutiqueId: boutiqueId,
            name: name,
            chainId: chainId,
            chainName: chainName,
            city: city,
            countryCode: countryCode,
          ),
        );
        continue;
      }

      if (!resolveCache.containsKey(cacheKey)) {
        resolveCache[cacheKey] = await geocoder.locate(city, countryCode);
      }
      point = resolveCache[cacheKey];
      if (point != null) {
        pins.add(
          BoutiquePin(
            boutiqueId: boutiqueId,
            name: name,
            chainId: chainId,
            chainName: chainName,
            city: city,
            countryCode: countryCode,
            latitude: point.latitude,
            longitude: point.longitude,
            precision: PinPrecision.approximate,
          ),
        );
      } else {
        unplaced.add(
          UnplacedBoutique(
            boutiqueId: boutiqueId,
            name: name,
            chainId: chainId,
            chainName: chainName,
            city: city,
            countryCode: countryCode,
          ),
        );
      }
    }
  }

  return BoutiqueMapResult(pins: pins, unplaced: unplaced);
}

/// Bounding box for [pins]. Returns null when [pins] is empty.
MapBounds? boundsFor(List<BoutiquePin> pins) {
  if (pins.isEmpty) return null;
  var south = pins.first.latitude;
  var north = pins.first.latitude;
  var west = pins.first.longitude;
  var east = pins.first.longitude;
  for (final pin in pins.skip(1)) {
    if (pin.latitude < south) south = pin.latitude;
    if (pin.latitude > north) north = pin.latitude;
    if (pin.longitude < west) west = pin.longitude;
    if (pin.longitude > east) east = pin.longitude;
  }
  return MapBounds(south: south, west: west, north: north, east: east);
}

/// First pin whose boutique name or chain name contains [query] (case-insensitive).
BoutiquePin? findPin(List<BoutiquePin> pins, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return null;
  for (final pin in pins) {
    if (pin.name.toLowerCase().contains(q) ||
        pin.chainName.toLowerCase().contains(q) ||
        pin.boutiqueId.toLowerCase() == q) {
      return pin;
    }
  }
  return null;
}
