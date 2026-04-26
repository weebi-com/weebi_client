import 'package:flutter/material.dart';

class AppDataTableTheme extends ThemeExtension<AppDataTableTheme> {
  final CardThemeData cardTheme;
  final DataTableThemeData dataTableThemeData;

  const AppDataTableTheme({
    required this.cardTheme,
    required this.dataTableThemeData,
  });

  factory AppDataTableTheme.fromTheme(ThemeData themeData) {
    return AppDataTableTheme(
      cardTheme: CardThemeData(
        color: Colors.transparent,
        elevation: 0.0,
        clipBehavior: themeData.cardTheme.clipBehavior,
        shadowColor: themeData.cardTheme.shadowColor,
        shape: themeData.cardTheme.shape,
        margin: themeData.cardTheme.margin,
        surfaceTintColor: themeData.cardTheme.surfaceTintColor,
      ),
      dataTableThemeData: themeData.dataTableTheme.copyWith(
        headingRowColor: WidgetStateProperty.all(themeData.colorScheme.primary),
        headingTextStyle: TextStyle(color: themeData.colorScheme.onPrimary),
      ),
    );
  }

  @override
  ThemeExtension<AppDataTableTheme> copyWith({
    CardThemeData? cardTheme,
    DataTableThemeData? dataTableThemeData,
  }) {
    return AppDataTableTheme(
      cardTheme: cardTheme ?? this.cardTheme,
      dataTableThemeData: dataTableThemeData ?? this.dataTableThemeData,
    );
  }

  @override
  ThemeExtension<AppDataTableTheme> lerp(
      ThemeExtension<AppDataTableTheme>? other, double t) {
    if (other is! AppDataTableTheme) {
      return this;
    }

    return AppDataTableTheme(
      cardTheme: other.cardTheme,
      dataTableThemeData: other.dataTableThemeData,
    );
  }

// final ThemeData dataTable;
//
// const AppDataTableTheme({
//   required this.dataTable,
// });
//
// factory AppDataTableTheme.fromTheme(ThemeData themeData) {
//   return AppDataTableTheme(
//     dataTable: themeData.copyWith(
//       cardTheme: themeData.cardTheme.copyWith(
//         color: Colors.transparent,
//         elevation: 0.0,
//       ),
//       dataTableTheme: DataTableThemeData(
//         headingRowColor: MaterialStateProperty.all(themeData.colorScheme.primary),
//         headingTextStyle: TextStyle(color: themeData.colorScheme.onPrimary),
//       ),
//     ),
//   );
// }
//
// @override
// ThemeExtension<AppDataTableTheme> copyWith({
//   ThemeData? dataTable,
// }) {
//   return AppDataTableTheme(
//     dataTable: dataTable ?? this.dataTable,
//   );
// }
//
// @override
// ThemeExtension<AppDataTableTheme> lerp(ThemeExtension<AppDataTableTheme>? other, double t) {
//   if (other is! AppDataTableTheme) {
//     return this;
//   }
//
//   return AppDataTableTheme(
//     dataTable: other.dataTable,
//   );
// }
}
