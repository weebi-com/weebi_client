import 'package:web_admin/map/city_normalize.dart';
import 'package:web_admin/map/city_point.dart';

/// Geographic center of a country, used when a boutique has a country but no
/// usable city or coordinates.
class CountryCentroidTable {
  CountryCentroidTable._();

  static final _Index _index = _build();

  /// ISO 3166-1 alpha-2 lookup. Returns null for unknown codes.
  static CityPoint? lookup(String countryCode) {
    final code = normalizeCountryCode(countryCode);
    if (code.length != 2) return null;
    return _index.byCode[code];
  }

  /// Match a typed country name (French or English, accents ignored).
  static String? codeForName(String name) {
    final key = normalizeCityName(name);
    if (key.isEmpty) return null;
    return _index.byName[key];
  }

  static _Index _build() {
    final byCode = <String, CityPoint>{};
    final byName = <String, String>{};

    void add(String code, double lat, double lng, List<String> names) {
      byCode[code] = CityPoint(latitude: lat, longitude: lng);
      byName[code.toLowerCase()] = code;
      for (final name in names) {
        final key = normalizeCityName(name);
        if (key.isNotEmpty) byName[key] = code;
      }
    }

    add('DZ', 28.03, 1.66, ['Algérie', 'Algeria']);
    add('AO', -11.20, 17.87, ['Angola']);
    add('BJ', 9.31, 2.32, ['Bénin', 'Benin']);
    add('BW', -22.33, 24.68, ['Botswana']);
    add('BF', 12.24, -1.56, ['Burkina Faso']);
    add('BI', -3.37, 29.92, ['Burundi']);
    add('CV', 16.00, -24.01, ['Cap-Vert', 'Cape Verde']);
    add('CM', 7.37, 12.35, ['Cameroun', 'Cameroon']);
    add('CF', 6.61, 20.94, [
      'République centrafricaine',
      'Central African Republic',
    ]);
    add('TD', 15.45, 18.73, ['Tchad', 'Chad']);
    add('KM', -11.88, 43.87, ['Comores', 'Comoros']);
    add('CG', -0.23, 15.83, ['République du Congo', 'Congo', 'Congo-Brazzaville']);
    add('CD', -4.04, 21.76, [
      'République démocratique du Congo',
      'RD Congo',
      'RDC',
      'DR Congo',
      'Democratic Republic of the Congo',
    ]);
    add('CI', 7.54, -5.55, ["Côte d'Ivoire", 'Ivory Coast']);
    add('DJ', 11.83, 42.59, ['Djibouti']);
    add('EG', 26.82, 30.80, ['Égypte', 'Egypt']);
    add('GQ', 1.65, 10.27, ['Guinée équatoriale', 'Equatorial Guinea']);
    add('ER', 15.18, 39.78, ['Érythrée', 'Eritrea']);
    add('SZ', -26.52, 31.47, ['Eswatini', 'Swaziland']);
    add('ET', 9.15, 40.49, ['Éthiopie', 'Ethiopia']);
    add('GA', -0.80, 11.61, ['Gabon']);
    add('GM', 13.44, -15.31, ['Gambie', 'Gambia']);
    add('GH', 7.95, -1.02, ['Ghana']);
    add('GN', 9.95, -9.70, ['Guinée', 'Guinea']);
    add('GW', 11.80, -15.18, ['Guinée-Bissau', 'Guinea-Bissau']);
    add('KE', 0.02, 37.91, ['Kenya']);
    add('LS', -29.61, 28.23, ['Lesotho']);
    add('LR', 6.43, -9.43, ['Libéria', 'Liberia']);
    add('LY', 26.34, 17.23, ['Libye', 'Libya']);
    add('MG', -18.77, 46.87, ['Madagascar']);
    add('MW', -13.25, 34.30, ['Malawi']);
    add('ML', 17.57, -3.99, ['Mali']);
    add('MR', 21.01, -10.94, ['Mauritanie', 'Mauritania']);
    add('MU', -20.35, 57.55, ['Maurice', 'Mauritius']);
    add('MA', 31.79, -7.09, ['Maroc', 'Morocco']);
    add('MZ', -18.67, 35.53, ['Mozambique']);
    add('NA', -22.96, 18.49, ['Namibie', 'Namibia']);
    add('NE', 17.61, 8.08, ['Niger']);
    add('NG', 9.08, 8.68, ['Nigeria']);
    add('RW', -1.94, 29.87, ['Rwanda']);
    add('ST', 0.19, 6.61, ['Sao Tomé-et-Principe', 'Sao Tome and Principe']);
    add('SN', 14.50, -14.45, ['Sénégal', 'Senegal']);
    add('SC', -4.68, 55.49, ['Seychelles']);
    add('SL', 8.46, -11.78, ['Sierra Leone']);
    add('SO', 5.15, 46.20, ['Somalie', 'Somalia']);
    add('ZA', -30.56, 22.94, ['Afrique du Sud', 'South Africa']);
    add('SS', 6.88, 31.31, ['Soudan du Sud', 'South Sudan']);
    add('SD', 12.86, 30.22, ['Soudan', 'Sudan']);
    add('TZ', -6.37, 34.89, ['Tanzanie', 'Tanzania']);
    add('TG', 8.62, 0.82, ['Togo']);
    add('TN', 33.89, 9.54, ['Tunisie', 'Tunisia']);
    add('UG', 1.37, 32.29, ['Ouganda', 'Uganda']);
    add('ZM', -13.13, 27.85, ['Zambie', 'Zambia']);
    add('ZW', -19.02, 29.15, ['Zimbabwe']);

    add('FR', 46.23, 2.21, ['France']);
    add('BE', 50.50, 4.47, ['Belgique', 'Belgium']);
    add('CH', 46.82, 8.23, ['Suisse', 'Switzerland']);
    add('LU', 49.82, 6.13, ['Luxembourg']);
    add('DE', 51.17, 10.45, ['Allemagne', 'Germany']);
    add('ES', 40.46, -3.75, ['Espagne', 'Spain']);
    add('PT', 39.40, -8.22, ['Portugal']);
    add('IT', 41.87, 12.57, ['Italie', 'Italy']);
    add('GB', 55.38, -3.44, ['Royaume-Uni', 'United Kingdom', 'UK']);
    add('NL', 52.13, 5.29, ['Pays-Bas', 'Netherlands']);
    add('IE', 53.41, -8.24, ['Irlande', 'Ireland']);
    add('AT', 47.52, 14.55, ['Autriche', 'Austria']);
    add('PL', 51.92, 19.15, ['Pologne', 'Poland']);
    add('RO', 45.94, 24.97, ['Roumanie', 'Romania']);
    add('GR', 39.07, 21.82, ['Grèce', 'Greece']);
    add('SE', 60.13, 18.64, ['Suède', 'Sweden']);
    add('NO', 60.47, 8.47, ['Norvège', 'Norway']);
    add('DK', 56.26, 9.50, ['Danemark', 'Denmark']);
    add('CZ', 49.82, 15.47, ['République tchèque', 'Czech Republic', 'Czechia']);
    add('HU', 47.16, 19.50, ['Hongrie', 'Hungary']);
    add('UA', 48.38, 31.17, ['Ukraine']);
    add('RU', 61.52, 105.32, ['Russie', 'Russia']);

    add('US', 37.09, -95.71, ['États-Unis', 'United States', 'USA']);
    add('CA', 56.13, -106.35, ['Canada']);
    add('BR', -14.24, -51.93, ['Brésil', 'Brazil']);
    add('MX', 23.63, -102.55, ['Mexique', 'Mexico']);
    add('CN', 35.86, 104.20, ['Chine', 'China']);
    add('IN', 20.59, 78.96, ['Inde', 'India']);
    add('JP', 36.20, 138.25, ['Japon', 'Japan']);
    add('AE', 23.42, 53.85, ['Émirats Arabes Unis', 'United Arab Emirates']);
    add('SA', 23.89, 45.08, ['Arabie Saoudite', 'Saudi Arabia']);
    add('TR', 38.96, 35.24, ['Turquie', 'Turkey']);

    return _Index(byCode, byName);
  }
}

class _Index {
  const _Index(this.byCode, this.byName);

  final Map<String, CityPoint> byCode;
  final Map<String, String> byName;
}

/// Prefer a known ISO code, then a typed country name.
String resolveCountryCode({String code2Letters = '', String name = ''}) {
  final code = normalizeCountryCode(code2Letters);
  if (CountryCentroidTable.lookup(code) != null) return code;
  final fromCode = CountryCentroidTable.codeForName(code2Letters);
  if (fromCode != null) return fromCode;
  final fromName = CountryCentroidTable.codeForName(name);
  if (fromName != null) return fromName;
  return code.length == 2 ? code : '';
}
