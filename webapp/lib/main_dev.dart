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
  Config.init(apiUrl: kApiUrlDev, locale: 'fr');
  runApp(const SharedPrefsFetchWidget(child: RootApp()));
}
