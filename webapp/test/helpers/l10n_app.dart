import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:web_admin/generated/l10n.dart';

Widget l10nApp({
  required Widget home,
  Locale locale = const Locale('fr'),
}) {
  return MaterialApp(
    localizationsDelegates: const [
      Lang.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: Lang.delegate.supportedLocales,
    locale: locale,
    home: home,
  );
}
