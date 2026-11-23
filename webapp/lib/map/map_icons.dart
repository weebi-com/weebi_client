import 'dart:math';

import 'package:flutter/material.dart' as material;

const _iconSize = [48, 32];

final Map<String, material.Color> _groupColors = {};

String normalizeGroupId(String id) => id.trim().toLowerCase();

String colorToHex(material.Color color) {
  final argb = color.toARGB32();
  return '#${argb.toRadixString(16).padLeft(8, '0').substring(2)}';
}

material.Color colorForGroup(String groupValue) {
  final id = normalizeGroupId(groupValue);
  if (id.isEmpty) return material.Colors.grey;
  final cached = _groupColors[id];
  if (cached != null) return cached;
  final hash = id.codeUnits.fold(0, (a, b) => a + b);
  final hue = (hash * 37) % 360;
  final color = material.HSLColor.fromAHSL(1, hue.toDouble(), 0.7, 0.55).toColor();
  _groupColors[id] = color;
  return color;
}

Map<String, dynamic> iconDataForGroup(String groupValue) {
  final color = colorForGroup(groupValue);
  final colorHex = colorToHex(color);
  final svg = generateColoredBoutiqueSvg(colorHex);
  final dataUri = 'data:image/svg+xml;utf8,${Uri.encodeComponent(svg)}';
  return {
    'url': dataUri,
    'size': _iconSize,
    'color': color,
  };
}

String generateColoredBoutiqueSvg(String hexColor) {
  return '''<?xml version="1.0" encoding="utf-8"?>
<svg width="48" height="32" viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
  <g>
    <rect width="48" height="48" fill="none"/>
    <path fill="$hexColor" d="M45.8,16.4v-.3L40.8,5.2A2,2,0,0,0,39,4H9A2,2,0,0,0,7.2,5.2L2.3,16.1v.3a6,6,0,0,0,1,5.2,6.9,6.9,0,0,0,2.8,2V41a3,3,0,0,0,3,3H27a.9.9,0,0,0,1-1V27h7V43a.9.9,0,0,0,1,1h3a3,3,0,0,0,3-3V23.6a6.9,6.9,0,0,0,2.8-2A6,6,0,0,0,45.8,16.4ZM24,37H13V27H24ZM41.6,19.1a2.1,2.1,0,0,1-1.8.9h-1a2.1,2.1,0,0,1-2.2-2.1,2,2,0,0,0-4,0A2.1,2.1,0,0,1,30.4,20H28.2A2.1,2.1,0,0,1,26,17.9a2,2,0,0,0-4,0A2.1,2.1,0,0,1,19.8,20H17.6a2.1,2.1,0,0,1-2.2-2.1,2,2,0,0,0-4,0A2.1,2.1,0,0,1,9.2,20h-1a2.1,2.1,0,0,1-1.8-.9A2.1,2.1,0,0,1,6,17.6L10.3,8H37.7L42,17.6A2.1,2.1,0,0,1,41.6,19.1Z"/>
  </g>
</svg>
''';
}

/// Pie-cluster HTML/SVG used by the Leaflet iconCreateFunction bridge.
String generatePieClusterIcon(Map<String, int> counts, int total) {
  String getPieSliceColor(String groupValue) {
    if (groupValue.isEmpty) return '#cccccc';
    return colorToHex(colorForGroup(groupValue));
  }

  final types = counts.keys.toList();
  final tooltipContent = types.map((type) {
    final colorHex = getPieSliceColor(type);
    final displayType = (type.isEmpty || type == 'other') ? '(none)' : type;
    return '<span style="display:inline-block;width:10px;height:10px;background:$colorHex;border-radius:50%;margin-right:4px;"></span>'
        '<b>$displayType:</b> ${counts[type]}';
  }).join('<br>');

  const tooltipStyle = '''
    <style>
      .pie-cluster-icon-container { position: relative; display: inline-block; }
      .pie-tooltip { display: none; position: absolute; left: 50%; top: 0; transform: translate(-50%, -110%); z-index: 1000; background: #fff; padding: 8px 12px; border-radius: 6px; box-shadow: 0 2px 8px rgba(0,0,0,0.15); font-size: 13px; white-space: nowrap; }
      .pie-cluster-icon-container:hover .pie-tooltip { display: block; }
      .pie-cluster-icon { width: 48px; height: 48px; border-radius: 50%; box-shadow: 0 4px 16px rgba(50, 80, 160, 0.18), 0 0 0 3px #fff; border: 2px solid #fff; background: #fff; display: flex; align-items: center; justify-content: center; }
    </style>
  ''';

  final tooltipDiv = '<div class="pie-tooltip">$tooltipContent</div>';

  String svg;
  if (types.length == 1) {
    final color = getPieSliceColor(types.first);
    svg = '''
      <svg width="48" height="48" viewBox="0 0 48 48">
        <circle cx="24" cy="24" r="24" fill="$color"/>
        <text x="24" y="28" text-anchor="middle" font-size="20" fill="#fff">$total</text>
      </svg>
    ''';
  } else {
    var startAngle = 0.0;
    const radius = 24.0;
    final buffer = StringBuffer();
    for (final type in types) {
      final value = counts[type]!;
      final angle = (value / total) * 360;
      final endAngle = startAngle + angle;
      final largeArc = angle > 180 ? 1 : 0;
      final x1 = radius + radius * cos(pi * startAngle / 180);
      final y1 = radius + radius * sin(pi * startAngle / 180);
      final x2 = radius + radius * cos(pi * endAngle / 180);
      final y2 = radius + radius * sin(pi * endAngle / 180);
      buffer.write(
        '<path d="M$radius,$radius L$x1,$y1 A$radius,$radius 0 $largeArc,1 $x2,$y2 Z" fill="${getPieSliceColor(type)}"></path>',
      );
      startAngle += angle;
    }
    svg = '''
      <svg width="48" height="48" viewBox="0 0 48 48">
        ${buffer.toString()}
        <circle cx="24" cy="24" r="14" fill="#fff"/>
        <text x="24" y="28" text-anchor="middle" font-size="16" fill="#333" font-weight="bold">$total</text>
      </svg>
    ''';
  }
  return '''
    $tooltipStyle
    <div class="pie-cluster-icon-container">
      <div class="pie-cluster-icon">$svg</div>
      $tooltipDiv
    </div>
  ''';
}
