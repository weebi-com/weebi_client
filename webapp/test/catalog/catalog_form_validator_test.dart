import 'package:flutter_test/flutter_test.dart';
import 'package:web_admin/catalog/article_label.dart';
import 'package:web_admin/catalog/catalog_form_validator.dart';

CatalogFormMessages get _messages => const CatalogFormMessages(
      enterTitle: 'Saisir le libellé',
      titleTaken: 'Un article avec ce libellé existe déjà',
      enterPrice: 'Saisir le prix de vente',
      invalidNumber: 'erreur',
      invalidUnits: 'exemple : 1.5 et non pas 1,5',
    );

void main() {
  test('empty title is required', () async {
    final validator = CatalogFormValidator(messages: _messages);
    await validator.validateCalibreTitle('');
    expect(validator.titleError, 'Saisir le libellé');
    expect(validator.hasErrors, isTrue);
  });

  test('duplicate title is rejected ignoring accents', () async {
    final validator = CatalogFormValidator(
      messages: _messages,
      isTitleTaken: (title) async => title.asArticleKey == 'cafe',
    );
    await validator.validateCalibreTitle('Café');
    expect(
      validator.titleError,
      'Un article avec ce libellé existe déjà',
    );
  });

  test('same title as initial is allowed on update', () async {
    final validator = CatalogFormValidator(
      messages: _messages,
      initialTitle: 'Café',
      isTitleTaken: (_) async => true,
    );
    await validator.validateCalibreTitle('Cafe');
    expect(validator.titleError, isNull);
  });

  test('price is required and must be numeric', () {
    final validator = CatalogFormValidator(messages: _messages);
    validator.validatePrice('');
    expect(validator.priceError, 'Saisir le prix de vente');
    validator.validatePrice('1,5');
    expect(validator.priceError, 'erreur 1,5');
    validator.validatePrice('1.5');
    expect(validator.priceError, isNull);
  });

  test('cost and units are optional but must be numeric when set', () {
    final validator = CatalogFormValidator(messages: _messages);
    validator.validateCost('');
    validator.validateUnitsPerPiece('');
    expect(validator.hasErrors, isFalse);
    validator.validateCost('abc');
    expect(validator.costError, 'erreur abc');
    validator.validateUnitsPerPiece('1,5');
    expect(
      validator.unitsError,
      'erreur 1,5, exemple : 1.5 et non pas 1,5',
    );
  });

  test('validateCalibreCreate matches mixin validateAll', () async {
    final validator = CatalogFormValidator(messages: _messages);
    final ok = await validator.validateCalibreCreate(
      title: 'Cola',
      price: '500',
      cost: '0',
      units: '1.0',
    );
    expect(ok, isTrue);
  });
}
