/// A geographic point for a city (or boutique pin).
class CityPoint {
  const CityPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityPoint &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

/// How a pin's coordinates were obtained.
enum PinPrecision {
  /// Stored latitude/longitude on the boutique address.
  precise,

  /// Capital table or city geocoder fallback.
  approximate,
}

/// A boutique that can be drawn on the map.
class BoutiquePin {
  const BoutiquePin({
    required this.boutiqueId,
    required this.name,
    required this.chainId,
    required this.chainName,
    required this.city,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.precision,
  });

  final String boutiqueId;
  final String name;
  final String chainId;
  final String chainName;
  final String city;
  final String countryCode;
  final double latitude;
  final double longitude;
  final PinPrecision precision;
}

/// A boutique that could not be placed on the map.
class UnplacedBoutique {
  const UnplacedBoutique({
    required this.boutiqueId,
    required this.name,
    required this.chainId,
    required this.chainName,
    required this.city,
    required this.countryCode,
  });

  final String boutiqueId;
  final String name;
  final String chainId;
  final String chainName;
  final String city;
  final String countryCode;
}

/// Result of resolving boutiques to map pins.
class BoutiqueMapResult {
  const BoutiqueMapResult({
    required this.pins,
    required this.unplaced,
  });

  final List<BoutiquePin> pins;
  final List<UnplacedBoutique> unplaced;
}

/// Bounding box for fitting the map view.
class MapBounds {
  const MapBounds({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
  });

  final double south;
  final double west;
  final double north;
  final double east;
}
