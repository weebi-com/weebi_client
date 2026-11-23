/// Normalize a city name for capital-table lookup: trim, lowercase, strip accents.
String normalizeCityName(String city) {
  final trimmed = city.trim().toLowerCase();
  if (trimmed.isEmpty) return '';
  return _stripAccents(trimmed);
}

String _stripAccents(String input) {
  const from = 'àáâãäåāăąèéêëēĕėęěìíîïĩīįòóôõöøōőùúûüũūŭůýÿñçśźżďťłřčž';
  const to = 'aaaaaaaaaeeeeeeeeeeiiiiiiiooooooooouuuuuuuuyyncszzdtrlcz';
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    final idx = from.indexOf(ch);
    if (idx >= 0) {
      buffer.write(to[idx]);
    } else {
      buffer.write(ch);
    }
  }
  return buffer.toString();
}

/// Normalize an ISO 3166-1 alpha-2 country code.
String normalizeCountryCode(String code) => code.trim().toUpperCase();
