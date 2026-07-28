import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:web_admin/config/api_url.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/root_app.dart';
import 'package:web_admin/shared_prefs.dart';

/// Run against **dev** Envoy even when [kApiUrl] in api_url.dart points elsewhere.
///
/// ```sh
/// flutter run -t lib/main_dev.dart
/// flutter run -d web-server -t lib/main_dev.dart
/// ```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Aptabase.init('A-EU-6900117896');
  Config.init(apiUrl: kApiUrlDev, locale: 'fr', isDev: true);
  runApp(const SharedPrefsFetchWidget(child: RootApp()));
}
