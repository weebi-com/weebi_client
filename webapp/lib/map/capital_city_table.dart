import 'package:web_admin/map/city_normalize.dart';
import 'package:web_admin/map/city_point.dart';

/// Static city centroids for demo capitals and common Weebi markets.
///
/// Keys are `"${normalizeCityName(city)}|${normalizeCountryCode(country)}"`.
class CapitalCityTable {
  CapitalCityTable._();

  static const Map<String, CityPoint> _entries = {
    'kinshasa|CD': CityPoint(latitude: -4.3276, longitude: 15.3136),
    'brazzaville|CG': CityPoint(latitude: -4.2634, longitude: 15.2429),
    'dakar|SN': CityPoint(latitude: 14.7167, longitude: -17.4677),
    'abidjan|CI': CityPoint(latitude: 5.3600, longitude: -4.0083),
    'douala|CM': CityPoint(latitude: 4.0511, longitude: 9.7679),
    'yaounde|CM': CityPoint(latitude: 3.8480, longitude: 11.5021),
    'libreville|GA': CityPoint(latitude: 0.4162, longitude: 9.4673),
    'cotonou|BJ': CityPoint(latitude: 6.3703, longitude: 2.3912),
    'lome|TG': CityPoint(latitude: 6.1725, longitude: 1.2314),
    'bamako|ML': CityPoint(latitude: 12.6392, longitude: -8.0029),
    'ouagadougou|BF': CityPoint(latitude: 12.3714, longitude: -1.5197),
    'niamey|NE': CityPoint(latitude: 13.5116, longitude: 2.1254),
    'ndjamena|TD': CityPoint(latitude: 12.1348, longitude: 15.0557),
    'n\'djamena|TD': CityPoint(latitude: 12.1348, longitude: 15.0557),
    'paris|FR': CityPoint(latitude: 48.8566, longitude: 2.3522),
    'bruxelles|BE': CityPoint(latitude: 50.8503, longitude: 4.3517),
    'brussels|BE': CityPoint(latitude: 50.8503, longitude: 4.3517),
    'lagos|NG': CityPoint(latitude: 6.5244, longitude: 3.3792),
    'accra|GH': CityPoint(latitude: 5.6037, longitude: -0.1870),
    'luanda|AO': CityPoint(latitude: -8.8383, longitude: 13.2344),
    'maputo|MZ': CityPoint(latitude: -25.9692, longitude: 32.5732),
    'antananarivo|MG': CityPoint(latitude: -18.8792, longitude: 47.5079),
    'kigali|RW': CityPoint(latitude: -1.9441, longitude: 30.0619),
    'kampala|UG': CityPoint(latitude: 0.3476, longitude: 32.5825),
    'nairobi|KE': CityPoint(latitude: -1.2921, longitude: 36.8219),
  };

  /// Lookup a city centroid. Returns null when the city is not in the table.
  static CityPoint? lookup(String city, String countryCode) {
    final key =
        '${normalizeCityName(city)}|${normalizeCountryCode(countryCode)}';
    if (key.startsWith('|')) return null;
    return _entries[key];
  }
}
