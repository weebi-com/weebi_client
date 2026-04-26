import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/values.dart';

class FxRateSnapshot {
  final String base;
  final String quote;
  final double rate;
  final DateTime fetchedAtUtc;

  const FxRateSnapshot({
    required this.base,
    required this.quote,
    required this.rate,
    required this.fetchedAtUtc,
  });

  Map<String, dynamic> toJson() {
    return {
      'base': base,
      'quote': quote,
      'rate': rate,
      'fetchedAtUtc': fetchedAtUtc.toIso8601String(),
    };
  }

  static FxRateSnapshot? fromJson(Map<String, dynamic> json) {
    final base = (json['base'] as String?)?.trim().toUpperCase();
    final quote = (json['quote'] as String?)?.trim().toUpperCase();
    final rateNum = json['rate'];
    final fetched = json['fetchedAtUtc'] as String?;
    if (base == null || base.isEmpty || quote == null || quote.isEmpty) {
      return null;
    }
    if (rateNum is! num || fetched == null || fetched.isEmpty) {
      return null;
    }
    final parsedTs = DateTime.tryParse(fetched);
    if (parsedTs == null) return null;
    return FxRateSnapshot(
      base: base,
      quote: quote,
      rate: rateNum.toDouble(),
      fetchedAtUtc: parsedTs.toUtc(),
    );
  }
}

/// Result of a single rate resolution applied to many primary-currency amounts.
class FxBatchConversion {
  final FxRateSnapshot snapshot;

  /// Same length and order as the input amounts; each value is `primary * rate`.
  final List<double> secondaryAmounts;

  const FxBatchConversion({
    required this.snapshot,
    required this.secondaryAmounts,
  });
}

/// Hybrid cache strategy:
/// 1) In-memory cache for this process
/// 2) Persistent backup from SharedPreferences (survives restarts)
/// 3) Online: [Frankfurter](https://api.frankfurter.app/latest) when the pair is supported,
///    else [open.er-api.com](https://www.exchangerate-api.com/docs/free) (broader ISO list, e.g. CDF).
class FxRateService {
  FxRateService._();
  static final FxRateService _instance = FxRateService._();
  factory FxRateService() => _instance;

  final Map<String, FxRateSnapshot> _memoryCache = {};

  static const String _frankfurterLatestUrl =
      'https://api.frankfurter.app/latest';
  static const String _openErLatestUrl = 'https://open.er-api.com/v6/latest';

  /// ISO codes listed at https://api.frankfurter.app/currencies (ECB set).
  /// Both legs must be in this set or Frankfurter will not serve the pair.
  static const Set<String> frankfurterSupportedIso = {
    'AUD',
    'BRL',
    'CAD',
    'CHF',
    'CNY',
    'CZK',
    'DKK',
    'EUR',
    'GBP',
    'HKD',
    'HUF',
    'IDR',
    'ILS',
    'INR',
    'ISK',
    'JPY',
    'KRW',
    'MXN',
    'MYR',
    'NOK',
    'NZD',
    'PHP',
    'PLN',
    'RON',
    'SEK',
    'SGD',
    'THB',
    'TRY',
    'USD',
    'ZAR',
  };

  static bool frankfurterSupportsPair(String base, String quote) {
    final b = base.trim().toUpperCase();
    final q = quote.trim().toUpperCase();
    return frankfurterSupportedIso.contains(b) &&
        frankfurterSupportedIso.contains(q);
  }

  String _pairKey(String base, String quote) =>
      '${base.trim().toUpperCase()}_${quote.trim().toUpperCase()}';

  String _storageKeyForPair(String pairKey) =>
      '${SharePrefKeys.fxRateBackupPrefix}$pairKey';

  Future<FxRateSnapshot?> getRate({
    required String base,
    required String quote,
  }) async {
    final normalizedBase = base.trim().toUpperCase();
    final normalizedQuote = quote.trim().toUpperCase();
    if (normalizedBase.isEmpty || normalizedQuote.isEmpty) return null;

    if (normalizedBase == normalizedQuote) {
      return FxRateSnapshot(
        base: normalizedBase,
        quote: normalizedQuote,
        rate: 1,
        fetchedAtUtc: DateTime.now().toUtc(),
      );
    }

    final pairKey = _pairKey(normalizedBase, normalizedQuote);

    final inMemory = _memoryCache[pairKey];
    if (inMemory != null) {
      return inMemory;
    }

    final persisted = await _readBackup(pairKey);
    if (persisted != null &&
        persisted.fetchedAtUtc
            .isAfter(DateTime.now().subtract(const Duration(hours: 12)))) {
      _memoryCache[pairKey] = persisted;
      return persisted;
    }

    final online = await _fetchOnline(
      base: normalizedBase,
      quote: normalizedQuote,
    );
    if (online != null) {
      _memoryCache[pairKey] = online;
      await _persistBackup(pairKey, online);
      return online;
    }
    return null;
  }

  /// Clears in-memory pair cache (for tests).
  void resetCachesForTest() {
    _memoryCache.clear();
  }

  /// Pure multiply: use when you already have a [rate] (e.g. from [getRate]).
  static List<double> applyRateToAmounts(
    double rate,
    List<double> primaryAmounts,
  ) {
    return primaryAmounts.map((p) => p * rate).toList(growable: false);
  }

  /// Single [getRate] call, then batch conversion for the whole screen/list.
  /// Returns `null` if no rate is available (same as [getRate]); caller shows primary only.
  Future<FxBatchConversion?> convertPrimaryAmountsToSecondary({
    required String primaryIso,
    required String secondaryIso,
    required List<double> primaryAmounts,
  }) async {
    final snapshot = await getRate(
      base: primaryIso,
      quote: secondaryIso,
    );
    if (snapshot == null) return null;
    final secondary = applyRateToAmounts(snapshot.rate, primaryAmounts);
    return FxBatchConversion(
      snapshot: snapshot,
      secondaryAmounts: secondary,
    );
  }

  Future<FxRateSnapshot?> _fetchOnline({
    required String base,
    required String quote,
  }) async {
    if (frankfurterSupportsPair(base, quote)) {
      final frankfurter = await _fetchFrankfurter(base: base, quote: quote);
      if (frankfurter != null) return frankfurter;
    }
    return _fetchOpenEr(base: base, quote: quote);
  }

  Future<FxRateSnapshot?> _fetchFrankfurter({
    required String base,
    required String quote,
  }) async {
    try {
      final uri = Uri.parse('$_frankfurterLatestUrl?from=$base&to=$quote');
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) return null;
      final rates = body['rates'];
      if (rates is! Map<String, dynamic>) return null;
      final rateNum = rates[quote];
      if (rateNum is! num) return null;

      return FxRateSnapshot(
        base: base,
        quote: quote,
        rate: rateNum.toDouble(),
        fetchedAtUtc: DateTime.now().toUtc(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Wider currency coverage than Frankfurter (e.g. CDF); see provider terms.
  Future<FxRateSnapshot?> _fetchOpenEr({
    required String base,
    required String quote,
  }) async {
    try {
      final uri = Uri.parse('$_openErLatestUrl/$base');
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) return null;
      if (body['result'] != 'success') return null;
      final rates = body['rates'];
      if (rates is! Map<String, dynamic>) return null;
      final rateNum = rates[quote];
      if (rateNum is! num || rateNum == 0) return null;

      return FxRateSnapshot(
        base: base,
        quote: quote,
        rate: rateNum.toDouble(),
        fetchedAtUtc: DateTime.now().toUtc(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistBackup(String pairKey, FxRateSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKeyForPair(pairKey),
      jsonEncode(snapshot.toJson()),
    );
  }

  Future<FxRateSnapshot?> _readBackup(String pairKey) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKeyForPair(pairKey));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return FxRateSnapshot.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
