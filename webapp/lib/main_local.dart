import 'package:flutter/material.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/root_app.dart';
import 'package:web_admin/shared_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
      Config.init(apiUrl: 'http://localhost:8080', locale: 'fr');

  runApp(const SharedPrefsFetchWidget(child: RootApp()));
}
