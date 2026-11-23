import 'package:web_admin/map/city_normalize.dart';
import 'package:web_admin/map/city_point.dart';

/// Resolves a city name + country to coordinates. Injected for tests.
abstract class CityGeocoder {
  Future<CityPoint?> locate(String city, String countryCode);
}

/// Geocoder that always returns null (no network).
class NullCityGeocoder implements CityGeocoder {
  const NullCityGeocoder();

  @override
  Future<CityPoint?> locate(String city, String countryCode) async => null;
}

/// Caches [CityGeocoder.locate] results by normalized city|country.
///
/// Concurrent calls for the same key share one in-flight future.
class CachingCityGeocoder implements CityGeocoder {
  CachingCityGeocoder(this._inner);

  final CityGeocoder _inner;
  final Map<String, CityPoint?> _cache = {};
  final Map<String, Future<CityPoint?>> _inflight = {};

  String _key(String city, String countryCode) =>
      '${normalizeCityName(city)}|${normalizeCountryCode(countryCode)}';

  @override
  Future<CityPoint?> locate(String city, String countryCode) {
    final key = _key(city, countryCode);
    if (_cache.containsKey(key)) {
      return Future.value(_cache[key]);
    }
    final pending = _inflight[key];
    if (pending != null) return pending;

    final future = _inner.locate(city, countryCode).then((point) {
      _cache[key] = point;
      _inflight.remove(key);
      return point;
    });
    _inflight[key] = future;
    return future;
  }
}
