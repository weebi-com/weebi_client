import 'package:flutter/material.dart';
import 'package:web_admin/core/theme/theme_extensions/app_button_theme.dart';
import 'package:web_admin/core/theme/theme_extensions/app_color_scheme.dart';
import 'package:web_admin/core/theme/theme_extensions/app_data_table_theme.dart';
import 'package:web_admin/core/theme/theme_extensions/app_sidebar_theme.dart';

import '../constants/dimens.dart';

const Color kPrimaryColor = Color(0xFF347BDE);
const Color kSecondaryColor = Color(0xFF6C757D);
const Color kErrorColor = Color(0xFFDC3545);
const Color kSuccessColor = Color(0xFF08A158);
const Color kInfoColor = Color(0xFF17A2B8);
const Color kWarningColor = Color(0xFFFFc107);

const Color kTextColor = Color(0xFF2A2B2D);

const Color kScreenBackgroundColor = Color(0xFFF4F6F9);

const Color kDarkScaffoldColor = Color(0xFF121418);
const Color kDarkSurfaceColor = Color(0xFF1E2228);
const Color kDarkOnSurfaceColor = Color(0xFFF2F4F7);
const Color kDarkOnSurfaceVariantColor = Color(0xFFC2C7D0);
const Color kDarkOutlineColor = Color(0xFF6C757D);
const Color kDarkPrimaryContainerColor = Color(0xFF1E4A8A);
const Color kDarkSurfaceContainerHighestColor = Color(0xFF32383F);

class AppThemeData {
  AppThemeData._();

  static final AppThemeData _instance = AppThemeData._();

  static AppThemeData get instance => _instance;

  ThemeData light() {
    final themeData = ThemeData(
      useMaterial3: false,
      appBarTheme: const AppBarTheme(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: kScreenBackgroundColor,
      drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF343A40)),
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: kPrimaryColor,
        onPrimary: Colors.white,
        secondary: kSecondaryColor,
        onSecondary: Colors.white,
        error: kErrorColor,
        onError: Colors.white,
        surface: Colors.white,
        onSurface: kTextColor,
        onSurfaceVariant: Color(0xFF5C6570),
        outline: Color(0xFFCED4DA),
        primaryContainer: Color(0xFFD6E6FA),
        onPrimaryContainer: Color(0xFF0D3B73),
        secondaryContainer: Color(0xFFE9ECEF),
        onSecondaryContainer: kTextColor,
        surfaceContainerHighest: Color(0xFFE9ECEF),
      ),
      cardTheme: const CardThemeData(
        margin: EdgeInsets.zero,
      ),
    );

    final appColorScheme = AppColorScheme(
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      error: kErrorColor,
      success: kSuccessColor,
      info: kInfoColor,
      warning: kWarningColor,
      hyperlink: const Color(0xFF0074CC),
      buttonTextBlack: kTextColor,
      buttonTextDisabled: kTextColor.withOpacity(0.38),
    );

    final appSidebarTheme = AppSidebarTheme(
      backgroundColor: themeData.drawerTheme.backgroundColor!,
      foregroundColor: const Color(0xFFC2C7D0),
      sidebarWidth: 304.0,
      sidebarLeftPadding: kDefaultPadding,
      sidebarTopPadding: kDefaultPadding,
      sidebarRightPadding: kDefaultPadding,
      sidebarBottomPadding: kDefaultPadding,
      headerUserProfileRadius: 20.0,
      headerUsernameFontSize: 14.0,
      headerTextButtonFontSize: 14.0,
      menuFontSize: 14.0,
      menuBorderRadius: 5.0,
      menuLeftPadding: 0.0,
      menuTopPadding: 2.0,
      menuRightPadding: 0.0,
      menuBottomPadding: 2.0,
      menuHoverColor: Colors.white.withOpacity(0.2),
      menuSelectedFontColor: Colors.white,
      menuSelectedBackgroundColor: appColorScheme.primary,
      menuExpandedBackgroundColor: Colors.white.withOpacity(0.1),
      menuExpandedHoverColor: Colors.white.withOpacity(0.1),
      menuExpandedChildLeftPadding: 4.0,
      menuExpandedChildTopPadding: 2.0,
      menuExpandedChildRightPadding: 4.0,
      menuExpandedChildBottomPadding: 2.0,
    );

    return themeData.copyWith(
      textTheme: themeData.textTheme.apply(
        bodyColor: kTextColor,
        displayColor: kTextColor,
      ),
      extensions: [
        AppButtonTheme.fromAppColorScheme(appColorScheme),
        appColorScheme,
        AppDataTableTheme.fromTheme(themeData),
        appSidebarTheme,
      ],
    );
  }

  ThemeData dark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: kPrimaryColor,
      onPrimary: Colors.white,
      secondary: Color(0xFFADB5BD),
      onSecondary: kDarkScaffoldColor,
      error: kErrorColor,
      onError: Colors.white,
      surface: kDarkSurfaceColor,
      onSurface: kDarkOnSurfaceColor,
      onSurfaceVariant: kDarkOnSurfaceVariantColor,
      outline: kDarkOutlineColor,
      primaryContainer: kDarkPrimaryContainerColor,
      onPrimaryContainer: Colors.white,
      secondaryContainer: kDarkSurfaceContainerHighestColor,
      onSecondaryContainer: kDarkOnSurfaceColor,
      surfaceContainerHighest: kDarkSurfaceContainerHighestColor,
    );

    final themeData = ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: kDarkScaffoldColor,
      canvasColor: kDarkSurfaceColor,
      cardColor: kDarkSurfaceColor,
      dividerColor: kDarkOutlineColor.withOpacity(0.45),
      dialogBackgroundColor: kDarkSurfaceColor,
      drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF343A40)),
      appBarTheme: const AppBarTheme(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: const CardThemeData(
        margin: EdgeInsets.zero,
        color: kDarkSurfaceColor,
      ),
    );

    final appColorScheme = AppColorScheme(
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      error: kErrorColor,
      success: kSuccessColor,
      info: kInfoColor,
      warning: kWarningColor,
      hyperlink: const Color(0xFF6BBBF7),
      buttonTextBlack: kTextColor,
      buttonTextDisabled: Colors.white.withOpacity(0.38),
    );

    final appSidebarTheme = AppSidebarTheme(
      backgroundColor: themeData.drawerTheme.backgroundColor!,
      foregroundColor: const Color(0xFFC2C7D0),
      sidebarWidth: 304.0,
      sidebarLeftPadding: kDefaultPadding,
      sidebarTopPadding: kDefaultPadding,
      sidebarRightPadding: kDefaultPadding,
      sidebarBottomPadding: kDefaultPadding,
      headerUserProfileRadius: 20.0,
      headerUsernameFontSize: 14.0,
      headerTextButtonFontSize: 14.0,
      menuFontSize: 14.0,
      menuBorderRadius: 5.0,
      menuLeftPadding: 0.0,
      menuTopPadding: 2.0,
      menuRightPadding: 0.0,
      menuBottomPadding: 2.0,
      menuHoverColor: Colors.white.withOpacity(0.2),
      menuSelectedFontColor: Colors.white,
      menuSelectedBackgroundColor: appColorScheme.primary,
      menuExpandedBackgroundColor: Colors.white.withOpacity(0.1),
      menuExpandedHoverColor: Colors.white.withOpacity(0.1),
      menuExpandedChildLeftPadding: 4.0,
      menuExpandedChildTopPadding: 2.0,
      menuExpandedChildRightPadding: 4.0,
      menuExpandedChildBottomPadding: 2.0,
    );

    return themeData.copyWith(
      textTheme: themeData.textTheme.apply(
        bodyColor: kDarkOnSurfaceColor,
        displayColor: kDarkOnSurfaceColor,
      ),
      extensions: [
        AppButtonTheme.fromAppColorScheme(appColorScheme),
        appColorScheme,
        AppDataTableTheme.fromTheme(themeData),
        appSidebarTheme,
      ],
    );
  }
}
