// Flutter imports:
// ignore_for_file: file_names

// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_admin/views/widgets/futurebuild2.dart';

class ColoredBoxWeebi {
  static const greyWithCircularProgressIndic = ColoredBox(
    color: Colors.grey,
    child: Center(child: CircularProgressIndicator()),
  );
}

class SharedPrefsFetchWidget extends StatelessWidget {
  final Widget child;
  const SharedPrefsFetchWidget({required this.child, super.key});

  Future<SharedPreferences> getThemPrefs() async =>
      await SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder2<SharedPreferences>(
        future: getThemPrefs(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return ColoredBoxWeebi.greyWithCircularProgressIndic;
          } else if (snap.hasError ||
              (snap.connectionState != ConnectionState.waiting &&
                  !snap.hasData) ||
              snap.data == null) {
            return ColoredBox(
                color: const Color.fromRGBO(92, 107, 192, 1),
                child: Text('getSharedPrefs error ${snap.error}'));
          } else {
            // print('sharedprefs found');
            return Provider<SharedPreferences>(
              create: (_) => snap.data!,
              child: child,
            );
          }
        });
  }
}
