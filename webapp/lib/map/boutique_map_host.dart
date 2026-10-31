import 'package:web_admin/map/city_point.dart';

/// Attribute used to color pie-cluster slices.
enum MapGroupBy {
  chainName,
  countryCode,
}

/// Abstraction over the Leaflet (or any) map so the screen is unit-testable.
abstract class BoutiqueMapHost {
  /// Replace markers and regroup clusters by [groupBy].
  void setPins(List<BoutiquePin> pins, MapGroupBy groupBy);

  /// Fit the map camera to [bounds]. No-op when null.
  void fitBounds(MapBounds? bounds);

  /// Zoom / highlight [pin].
  void focus(BoutiquePin pin);

  /// Tear down the map instance.
  void dispose();
}

/// Host that records calls for widget tests.
class RecordingMapHost implements BoutiqueMapHost {
  List<BoutiquePin>? lastPins;
  MapGroupBy? lastGroupBy;
  MapBounds? lastBounds;
  BoutiquePin? lastFocus;
  int setPinsCallCount = 0;

  @override
  void setPins(List<BoutiquePin> pins, MapGroupBy groupBy) {
    setPinsCallCount++;
    lastPins = List.unmodifiable(pins);
    lastGroupBy = groupBy;
  }

  @override
  void fitBounds(MapBounds? bounds) {
    lastBounds = bounds;
  }

  @override
  void focus(BoutiquePin pin) {
    lastFocus = pin;
  }

  @override
  void dispose() {}
}
