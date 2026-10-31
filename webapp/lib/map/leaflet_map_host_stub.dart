import 'package:flutter/widgets.dart';
import 'package:web_admin/map/boutique_map_host.dart';
import 'package:web_admin/map/city_point.dart';

/// Non-web stub: records nothing and renders an empty box.
class LeafletMapHost implements BoutiqueMapHost {
  LeafletMapHost();

  /// View type for [HtmlElementView]; unused on VM.
  static const viewType = 'weebi-boutiques-map';

  Widget buildMapView() => const SizedBox.expand();

  @override
  void setPins(List<BoutiquePin> pins, MapGroupBy groupBy) {}

  @override
  void fitBounds(MapBounds? bounds) {}

  @override
  void focus(BoutiquePin pin) {}

  @override
  void dispose() {}
}
