import 'package:flutter/material.dart';
import 'package:web_admin/config/api_url.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/root_app.dart';
import 'package:web_admin/shared_prefs.dart';

/// Entry point for Patrol integration tests against the dev backend.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Config.init(apiUrl: kApiUrlDev, locale: 'fr', isBffMode: true);
  runApp(const SharedPrefsFetchWidget(child: RootApp()));
}
