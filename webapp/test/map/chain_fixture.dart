import 'package:protos_weebi/protos_weebi_io.dart';

/// Builds a [Chain] with nested boutiques for map unit tests.
Chain chainFixture({
  required String chainId,
  required String name,
  List<BoutiqueMongo> boutiques = const [],
  bool isDeleted = false,
}) {
  final chain = Chain()
    ..chainId = chainId
    ..name = name
    ..isDeleted = isDeleted;
  chain.boutiques.addAll(boutiques);
  return chain;
}

BoutiqueMongo boutiqueFixture({
  required String boutiqueId,
  required String name,
  required String chainId,
  String city = '',
  String countryCode = '',
  double latitude = 0,
  double longitude = 0,
  bool isDeleted = false,
}) {
  final address = Address()
    ..city = city
    ..latitude = latitude
    ..longitude = longitude;
  if (countryCode.isNotEmpty) {
    address.country = Country()..code2Letters = countryCode;
  }
  final boutique = BoutiquePb()
    ..boutiqueId = boutiqueId
    ..name = name
    ..addressFull = address
    ..isDeleted = isDeleted;
  return BoutiqueMongo()
    ..boutiqueId = boutiqueId
    ..name = name
    ..chainId = chainId
    ..isDeleted = isDeleted
    ..boutique = boutique;
}
