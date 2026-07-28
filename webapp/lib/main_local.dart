import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/root_app.dart';
import 'package:web_admin/shared_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Aptabase.init('A-EU-6900117896');
  Config.init(apiUrl: 'http://localhost:8080', locale: 'fr', isDev: true);

  runApp(const SharedPrefsFetchWidget(child: RootApp()));
}
