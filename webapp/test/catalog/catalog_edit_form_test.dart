import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/catalog/catalog_form_validator.dart';
import 'package:web_admin/views/screens/catalog/catalog_edit_form.dart';

import '../helpers/l10n_app.dart';

CatalogFormValidator _validator({
  Future<bool> Function(String title)? isTitleTaken,
}) {
  return CatalogFormValidator(
    messages: const CatalogFormMessages(
      enterTitle: 'Saisir le libellé',
      titleTaken: 'Un article avec ce libellé existe déjà',
      enterPrice: 'Saisir le prix de vente',
      invalidNumber: 'erreur',
      invalidUnits: 'exemple : 1.5 et non pas 1,5',
    ),
    isTitleTaken: isTitleTaken,
  );
}

CatalogEditForm _form({
  required TextEditingController title,
  TextEditingController? price,
  VoidCallback? onSave,
  List<ArticleRetailPb> skus = const [],
}) {
  return CatalogEditForm(
    formKey: GlobalKey<FormState>(),
    isNew: true,
    titleController: title,
    designationController: TextEditingController(),
    priceController: price ?? TextEditingController(text: '500'),
    costController: TextEditingController(),
    barcodeController: TextEditingController(),
    unitsController: TextEditingController(text: '1'),
    stockUnit: CalibrePb_StockUnit.unit,
    onStockUnitChanged: (_) {},
    skus: skus,
    onAddSubArticle: () {},
    onSave: onSave ?? () {},
    onCancel: () {},
    currencyCode: 'XOF',
  );
}

Widget _app(Widget child, {CatalogFormValidator? validator}) {
  return l10nApp(
    home: ChangeNotifierProvider.value(
      value: validator ?? _validator(),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('save is disabled when title is empty', (tester) async {
    await tester.pumpWidget(
      _app(_form(title: TextEditingController())),
    );

    final save =
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Sauvegarder'));
    expect(save.onPressed, isNull);
  });

  testWidgets('save is disabled when price is empty', (tester) async {
    await tester.pumpWidget(
      _app(
        _form(
          title: TextEditingController(text: 'Cola'),
          price: TextEditingController(),
        ),
      ),
    );

    final save =
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Sauvegarder'));
    expect(save.onPressed, isNull);
  });

  testWidgets('save is enabled when title and price are filled', (tester) async {
    var saved = false;
    await tester.pumpWidget(
      _app(
        _form(
          title: TextEditingController(text: 'Cola'),
          onSave: () => saved = true,
        ),
      ),
    );

    final save =
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Sauvegarder'));
    expect(save.onPressed, isNotNull);
    await tester.tap(find.text('Sauvegarder'));
    expect(saved, isTrue);
  });

  testWidgets('single article does not split designation from title',
      (tester) async {
    await tester.pumpWidget(
      _app(_form(title: TextEditingController(text: 'Cola'))),
    );

    expect(find.text('Désignation'), findsNothing);
  });

  testWidgets('uses characteristics, currency suffixes, and sub-article CTA',
      (tester) async {
    await tester.pumpWidget(
      _app(_form(title: TextEditingController(text: 'Cola'))),
    );

    expect(find.text('Caractéristiques'), findsOneWidget);
    expect(find.text('Identity'), findsNothing);
    expect(find.text('Unités/article'), findsOneWidget);
    expect(find.text('XOF'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Ajouter un sous-article'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Add SKU'), findsNothing);
    expect(find.text('Ajouter un sous-article'), findsOneWidget);
  });
}
