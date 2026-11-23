// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;
import 'package:web_admin/map/boutique_map_host.dart';
import 'package:web_admin/map/city_point.dart';
import 'package:web_admin/map/map_icons.dart';

/// Leaflet + markercluster host for Flutter web.
class LeafletMapHost implements BoutiqueMapHost {
  LeafletMapHost() {
    _ensureViewFactory();
    _exposePieClusterIcon('chainName');
  }

  static const viewType = 'weebi-boutiques-map';
  static bool _factoryRegistered = false;

  JSObject? _map;
  JSObject? _cluster;
  List<BoutiquePin> _pins = const [];
  MapGroupBy _groupBy = MapGroupBy.chainName;

  Widget buildMapView() => const HtmlElementView(viewType: viewType);

  void _ensureViewFactory() {
    if (_factoryRegistered) return;
    _factoryRegistered = true;
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final mapDiv = web.HTMLDivElement()
        ..id = 'weebi-boutiques-map'
        ..style.width = '100%'
        ..style.height = '100%';
      // Defer until the div is in the DOM.
      Future<void>.delayed(const Duration(milliseconds: 50), _initMapIfNeeded);
      return mapDiv;
    });
  }

  JSObject? get _leafletApi {
    final l = globalContext.getProperty('L'.toJS);
    if (l == null || l.isUndefinedOrNull) return null;
    return l as JSObject;
  }

  void _exposePieClusterIcon(String groupingAttribute) {
    globalContext.setProperty(
      'dartPieClusterIcon'.toJS,
      ((JSAny? cluster) {
        final markers =
            (cluster as JSObject).callMethod('getAllChildMarkers'.toJS);
        final markersObj = markers as JSObject;
        final total = (markersObj.getProperty('length'.toJS) as JSNumber).toDartInt;
        final counts = <String, int>{};
        for (var i = 0; i < total; i++) {
          final marker = markersObj.getProperty(i.toJS) as JSObject;
          var type = '';
          if (marker.has(groupingAttribute)) {
            type = marker.getProperty(groupingAttribute.toJS).toString();
          } else if (marker.has('options')) {
            final options = marker.getProperty('options'.toJS) as JSObject;
            if (options.has(groupingAttribute)) {
              type = options.getProperty(groupingAttribute.toJS).toString();
            }
          }
          counts[type] = (counts[type] ?? 0) + 1;
        }
        return generatePieClusterIcon(counts, total).toJS;
      }).toJS,
    );
  }

  void _initMapIfNeeded() {
    if (_map != null) return;
    final L = _leafletApi;
    if (L == null) return;
    final existing = globalContext.getProperty('weebiMapInstance'.toJS);
    if (existing != null && !existing.isUndefinedOrNull) {
      try {
        (existing as JSObject).callMethod('remove'.toJS);
      } catch (_) {}
    }

    final map = L.callMethod(
      'map'.toJS,
      'weebi-boutiques-map'.toJS,
      <String, Object?>{
        'zoomControl': true,
        'attributionControl': false,
      }.jsify(),
    ) as JSObject;
    globalContext.setProperty('weebiMapInstance'.toJS, map);
    _map = map;

    final tileLayer = L.callMethod(
      'tileLayer'.toJS,
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'.toJS,
      <String, Object?>{'maxZoom': 19}.jsify(),
    ) as JSObject;
    tileLayer.callMethod('addTo'.toJS, map);

    _rebuildCluster();
  }

  String _groupValue(BoutiquePin pin) {
    switch (_groupBy) {
      case MapGroupBy.chainName:
        return pin.chainName;
      case MapGroupBy.countryCode:
        return pin.countryCode;
    }
  }

  void _rebuildCluster() {
    final L = _leafletApi;
    final map = _map;
    if (L == null || map == null) {
      // Map not ready yet; retry shortly after setPins.
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        if (_map == null) _initMapIfNeeded();
        if (_map != null) _rebuildCluster();
      });
      return;
    }

    if (_cluster != null) {
      try {
        map.callMethod('removeLayer'.toJS, _cluster);
      } catch (_) {}
    }

    _exposePieClusterIcon(
      _groupBy == MapGroupBy.chainName ? 'chainName' : 'countryCode',
    );

    final customIcon = globalContext.getProperty('customClusterIcon'.toJS);
    final cluster = L.callMethod(
      'markerClusterGroup'.toJS,
      <String, Object?>{
        if (customIcon != null && !customIcon.isUndefinedOrNull)
          'iconCreateFunction': customIcon,
      }.jsify(),
    ) as JSObject;
    _cluster = cluster;

    for (final pin in _pins) {
      final attr = _groupValue(pin);
      final iconData = iconDataForGroup(attr);
      final icon = L.callMethod(
        'icon'.toJS,
        <String, Object?>{
          'iconUrl': iconData['url'],
          'iconSize': iconData['size'],
        }.jsify(),
      );

      final latLng = L.callMethod(
        'latLng'.toJS,
        pin.latitude.toJS,
        pin.longitude.toJS,
      );
      final marker = L.callMethod(
        'marker'.toJS,
        latLng,
        <String, Object?>{'icon': icon}.jsify(),
      ) as JSObject;

      final options = marker.getProperty('options'.toJS) as JSObject;
      options.setProperty('chainName'.toJS, pin.chainName.toJS);
      options.setProperty('countryCode'.toJS, pin.countryCode.toJS);
      options.setProperty('pieClusterValue'.toJS, attr.toJS);
      marker.setProperty('chainName'.toJS, pin.chainName.toJS);
      marker.setProperty('countryCode'.toJS, pin.countryCode.toJS);
      marker.setProperty('pieClusterValue'.toJS, attr.toJS);

      final popup = '<b>${_escape(pin.name)}</b><br>'
          '${_escape(pin.chainName)}<br>'
          '${_escape(pin.city)}'
          '${pin.countryCode.isNotEmpty ? ', ${_escape(pin.countryCode)}' : ''}';
      marker.callMethod('bindPopup'.toJS, popup.toJS);

      cluster.callMethod('addLayer'.toJS, marker);
    }

    cluster.callMethod('addTo'.toJS, map);
    fitBounds(boundsForPins(_pins));
  }

  static MapBounds? boundsForPins(List<BoutiquePin> pins) {
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

  String _escape(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');

  @override
  void setPins(List<BoutiquePin> pins, MapGroupBy groupBy) {
    _pins = List.unmodifiable(pins);
    _groupBy = groupBy;
    _rebuildCluster();
  }

  @override
  void fitBounds(MapBounds? bounds) {
    final map = _map;
    final L = _leafletApi;
    if (map == null || L == null || bounds == null) return;
    final corner1 = L.callMethod(
      'latLng'.toJS,
      bounds.south.toJS,
      bounds.west.toJS,
    );
    final corner2 = L.callMethod(
      'latLng'.toJS,
      bounds.north.toJS,
      bounds.east.toJS,
    );
    final latLngBounds = L.callMethod('latLngBounds'.toJS, corner1, corner2);
    map.callMethod(
      'fitBounds'.toJS,
      latLngBounds,
      <String, Object?>{'padding': [24, 24]}.jsify(),
    );
  }

  @override
  void focus(BoutiquePin pin) {
    final map = _map;
    if (map == null) return;
    map.callMethod(
      'setView'.toJS,
      <Object?>[pin.latitude, pin.longitude].jsify(),
      14.toJS,
    );
  }

  @override
  void dispose() {
    final existing = globalContext.getProperty('weebiMapInstance'.toJS);
    if (existing != null && !existing.isUndefinedOrNull) {
      try {
        (existing as JSObject).callMethod('remove'.toJS);
      } catch (_) {}
      globalContext.setProperty('weebiMapInstance'.toJS, null);
    }
    _map = null;
    _cluster = null;
  }
}
