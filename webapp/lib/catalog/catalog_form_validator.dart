import 'package:flutter/foundation.dart';
import 'package:web_admin/catalog/article_label.dart';
import 'package:web_admin/generated/l10n.dart';

/// Localized copies of the mixin article form messages.
class CatalogFormMessages {
  const CatalogFormMessages({
    required this.enterTitle,
    required this.titleTaken,
    required this.enterPrice,
    required this.invalidNumber,
    required this.invalidUnits,
  });

  factory CatalogFormMessages.fromLang(Lang lang) {
    return CatalogFormMessages(
      enterTitle: lang.catalogEnterTitle,
      titleTaken: lang.catalogTitleTaken,
      enterPrice: lang.catalogEnterPrice,
      invalidNumber: lang.catalogInvalidNumber,
      invalidUnits: lang.catalogInvalidUnits,
    );
  }

  final String enterTitle;
  final String titleTaken;
  final String enterPrice;
  final String invalidNumber;
  final String invalidUnits;

  String numberError(String value) => '$invalidNumber $value';

  String unitsError(String value) => '$invalidNumber $value, $invalidUnits';
}

/// Provider-based port of the MobX article/calibre retail validators.
class CatalogFormValidator extends ChangeNotifier {
  CatalogFormValidator({
    required this.messages,
    Future<bool> Function(String title)? isTitleTaken,
    Future<bool> Function(String designation)? isDesignationTaken,
    String initialTitle = '',
    String initialDesignation = '',
  })  : _isTitleTaken = isTitleTaken ?? ((_) async => false),
        _isDesignationTaken = isDesignationTaken ?? ((_) async => false),
        _initialTitle = initialTitle,
        _initialDesignation = initialDesignation;

  final CatalogFormMessages messages;
  final Future<bool> Function(String title) _isTitleTaken;
  final Future<bool> Function(String designation) _isDesignationTaken;

  String _initialTitle;
  String _initialDesignation;
  int _titleGen = 0;
  int _designationGen = 0;

  String? titleError;
  String? designationError;
  String? priceError;
  String? costError;
  String? unitsError;

  bool get hasErrors =>
      titleError != null ||
      designationError != null ||
      priceError != null ||
      costError != null ||
      unitsError != null;

  void setInitialLabels({String? title, String? designation}) {
    if (title != null) _initialTitle = title;
    if (designation != null) _initialDesignation = designation;
  }

  Future<void> validateCalibreTitle(String value) async {
    final gen = ++_titleGen;
    if (value.isEmpty) {
      titleError = messages.enterTitle;
      notifyListeners();
      return;
    }
    final key = value.asArticleKey;
    if (key == _initialTitle.asArticleKey) {
      titleError = null;
      notifyListeners();
      return;
    }
    final taken = await _isTitleTaken(value);
    if (gen != _titleGen) return;
    titleError = taken ? messages.titleTaken : null;
    notifyListeners();
  }

  Future<void> validateArticleDesignation(String value) async {
    final gen = ++_designationGen;
    if (value.isEmpty) {
      designationError = messages.enterTitle;
      notifyListeners();
      return;
    }
    final key = value.asArticleKey;
    if (key == _initialDesignation.asArticleKey) {
      designationError = null;
      notifyListeners();
      return;
    }
    final taken = await _isDesignationTaken(value);
    if (gen != _designationGen) return;
    designationError = taken ? messages.titleTaken : null;
    notifyListeners();
  }

  void validatePrice(String value) {
    if (value.isEmpty) {
      priceError = messages.enterPrice;
    } else if (num.tryParse(value) == null) {
      priceError = messages.numberError(value);
    } else {
      priceError = null;
    }
    notifyListeners();
  }

  void validateCost(String value) {
    if (value.isNotEmpty && num.tryParse(value) == null) {
      costError = messages.numberError(value);
    } else {
      costError = null;
    }
    notifyListeners();
  }

  void validateUnitsPerPiece(String value) {
    if (value.isNotEmpty && num.tryParse(value) == null) {
      unitsError = messages.unitsError(value);
    } else {
      unitsError = null;
    }
    notifyListeners();
  }

  Future<bool> validateCalibreCreate({
    required String title,
    required String price,
    required String cost,
    required String units,
  }) async {
    validatePrice(price);
    validateCost(cost);
    validateUnitsPerPiece(units);
    await validateCalibreTitle(title);
    return !hasErrors;
  }

  Future<bool> validateSubArticle({
    required String designation,
    required String price,
    required String cost,
    required String units,
  }) async {
    validatePrice(price);
    validateCost(cost);
    validateUnitsPerPiece(units);
    await validateArticleDesignation(designation);
    return !hasErrors;
  }
}
