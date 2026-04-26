import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:web_admin/config_loader.dart';
import 'package:web_admin/root_app.dart';
import 'package:web_admin/shared_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await loadConfig();

  await Aptabase.init('A-EU-6900117896');

  runApp(const SharedPrefsFetchWidget(child: RootApp()));
}