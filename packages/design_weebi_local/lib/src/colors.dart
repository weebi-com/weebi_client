// Flutter imports:
import 'package:flutter/material.dart' show Color, Colors;

import 'color_utils.dart';

class ColorsWeebi {
  /// yellow colors removed because hard to see on white background
  static final List<int> primariesNoYellowInts = Colors.primaries
      .where((p) => p != Colors.yellow)
      .map((c) => c.toInt())
      .toList();

  //static const appBarInit = Color.fromRGBO(69, 90, 100, 1);

  static const buttonColor = Color(0xFF0097A7);
  static const orangeArticle = Color(0xFFEF6C00);
  static const orangeSpendCover = Colors.orangeAccent;
  static const tealSell = Colors.teal;

  static const users = Colors.indigo;
  static const billing = Colors.amber;

  static const whatsapp = Color(0xFF25D366);

  static const blueCloudSync = Color(0xFF0277BD);
  static const blueWeebi = Color(0xFF135397);
  static const firm = Color(0xFF263238);
  static const chain = Colors.green;
  static const specialRights = Colors.purple;

  static const boutique = Colors.blueGrey;

  static const redSpend = Color(0xFFC62828);
  static const white = Colors.white;

  static const greyChart = Color(0xff7589a2);
  static const greyLight = Color(0xFFE0E0E0);
  static const greyTicket = Color(0xFF424242);
  static const blueInventory = Colors.blueAccent;
  static const blueSellCovered = Colors.lightBlue;
  static const blueContact = Color(0xFF1565C0);
  static const green = Color(0xFF2E7D32);
  static const yellowIndicator = Color(0xfffffe9d);
  static const blackAppBar = Color(0xFF20272B);
  static const pinkStockExit = Color(0xFFF06292);
  static const pinkStockEntry = Color(0xFFAD1457);

  static const Color expTablePrimaryColor = Color(0xFF1e2f36); // corner
  static const Color expTableAccentColor = Color(0xFF0d2026); // background
}
