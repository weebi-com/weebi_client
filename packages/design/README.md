# design_weebi

Weebi design system – shared icons, colors, text styles, and theme for Flutter apps.

Used by both **weebi_app** (mobile/desktop) and **weebi_webapp** (web admin).

## Contents

- **ColorsWeebi** – semantic colors (articles, boutiques, contacts, tickets, etc.)
- **IconsWeebi** – semantic icons for Weebi objects
- **TextStyleWeebi** – shared text styles
- **weebiTheme** – base `ThemeData` for Weebi apps
- **ColorUtils** – `Color.toInt()` extension

## Usage

```dart
import 'package:design_weebi/design_weebi.dart';

// Icons
IconsWeebi.articles
IconsWeebi.boutique
IconsWeebi.deviceIcon  // platform-aware (mobile vs desktop)

// Colors
ColorsWeebi.orangeArticle
ColorsWeebi.blueContact

// Text styles
TextStyleWeebi.bold
TextStyleWeebi.whiteBoldBig

// Theme
MaterialApp(theme: weebiTheme, ...)
```

## Publishing

This package is intended for pub.dev. When publishing, switch from `path` to version:

```yaml
design_weebi: ^0.1.0
```
