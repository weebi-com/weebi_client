import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// nginx / Flutter WASM contract.
///
/// Widget tests cannot load Chrome, skwasm workers, or SharedArrayBuffer.
/// A white screen on mobile Chrome is caused by missing COOP/COEP on the
/// document or on .js/.wasm workers, or by immutable caching of unhashed
/// Flutter binaries. This test locks that server contract so CI catches
/// regressions. Confirm on-device with remote debugging if this test is green
/// but a phone still shows a blank page.
void main() {
  late String conf;
  late List<_Location> locations;

  setUpAll(() {
    conf = File('nginx.conf').readAsStringSync();
    locations = _parseLocations(conf);
  });

  test('nginx.conf is present and has location blocks', () {
    expect(locations, isNotEmpty);
  });

  test('Wasm files are served with application/wasm', () {
    expect(
      conf,
      contains(RegExp(r'types\s*\{[^}]*application/wasm\s+wasm;')),
    );
  });

  test('every location sends COOP+COEP (nginx does not inherit add_header)',
      () {
    expect(locations, isNotEmpty);
    for (final location in locations) {
      expect(
        location.body,
        contains('Cross-Origin-Opener-Policy "same-origin" always'),
        reason: '${location.selector} dropped COOP — skwasm workers fail on '
            'mobile Chrome (white screen)',
      );
      expect(
        location.body,
        contains('Cross-Origin-Embedder-Policy "credentialless" always'),
        reason: '${location.selector} dropped COEP — skwasm workers fail on '
            'mobile Chrome (white screen)',
      );
    }
  });

  test('js and wasm are not cached as immutable', () {
    final jsWasm = locations.where((l) => l.servesJsOrWasm);
    expect(jsWasm, isNotEmpty);
    for (final location in jsWasm) {
      expect(
        location.body.toLowerCase(),
        isNot(contains('immutable')),
        reason: '${location.selector} marks unhashed Flutter/WASM as immutable '
            '— mobile Chrome keeps a stale binary after deploy',
      );
    }
  });

  test('entry points disable caching', () {
    final entry = locations.where((l) =>
        l.selector.contains('index.html') ||
        l.selector.contains('flutter_bootstrap'));
    expect(entry, isNotEmpty);
    for (final location in entry) {
      expect(
        location.body,
        anyOf(contains('no-store'), contains('no-cache')),
      );
    }
  });
}

class _Location {
  _Location(this.selector, this.body);

  final String selector;
  final String body;

  bool get servesJsOrWasm {
    final s = selector.toLowerCase();
    return s.contains('.js') ||
        s.contains('.wasm') ||
        s.contains('flutter_bootstrap');
  }
}

List<_Location> _parseLocations(String conf) {
  final locations = <_Location>[];
  final pattern = RegExp(r'^\s*location\s+([^{]+)\{', multiLine: true);
  for (final match in pattern.allMatches(conf)) {
    final start = match.end - 1;
    final end = _closingBrace(conf, start);
    locations.add(
      _Location(match.group(1)!.trim(), conf.substring(start, end + 1)),
    );
  }
  return locations;
}

int _closingBrace(String source, int openIndex) {
  var depth = 0;
  for (var i = openIndex; i < source.length; i++) {
    final c = source[i];
    if (c == '{') depth++;
    if (c == '}') {
      depth--;
      if (depth == 0) return i;
    }
  }
  throw StateError('Unbalanced braces in nginx.conf');
}
