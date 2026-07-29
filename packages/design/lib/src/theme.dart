// Flutter imports:
import 'package:flutter/material.dart';

import 'colors.dart';

const paddingVerticalLine = EdgeInsets.symmetric(vertical: 8);

final weebiTheme = ThemeData(
  colorScheme: ColorScheme.light(),
  useMaterial3: true,
  floatingActionButtonTheme:
      FloatingActionButtonThemeData(backgroundColor: Colors.grey),
  cardTheme: CardThemeData(
    color: Colors.white,
    surfaceTintColor: Colors.white,
  ),
  visualDensity: VisualDensity.comfortable,
  fontFamily: 'NotoSans',
  inputDecorationTheme: InputDecorationTheme(
    errorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: ColorsWeebi.redSpend),
    ),
    focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: ColorsWeebi.buttonColor)),
  ),
  appBarTheme: const AppBarTheme(
    foregroundColor: Colors.white,
    backgroundColor: ColorsWeebi.blackAppBar,
  ),
  primaryColor: ColorsWeebi.blackAppBar,
  buttonTheme: const ButtonThemeData(
    buttonColor: ColorsWeebi.buttonColor,
    textTheme: ButtonTextTheme.normal,
  ),
  tabBarTheme: const TabBarThemeData(
    indicatorColor: ColorsWeebi.yellowIndicator,
    indicator: BoxDecoration(
      border: Border(
        bottom:
            BorderSide(color: Colors.teal, width: 8, style: BorderStyle.solid),
      ),
      color: ColorsWeebi.greyLight,
    ),
  ),
);
