import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/catalog/catalog_form_validator.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/entity/entity_chrome.dart';

/// Curated catalog create/edit form (no portal chrome) so widget tests can
/// assert save gating without gRPC or [PortalMasterLayout].
///
/// Field icons/labels follow the PoS article retail form.
class CatalogEditForm extends StatelessWidget {
  const CatalogEditForm({
    super.key,
    required this.formKey,
    required this.isNew,
    required this.titleController,
    required this.designationController,
    required this.priceController,
    required this.costController,
    required this.barcodeController,
    required this.unitsController,
    required this.stockUnit,
    required this.onStockUnitChanged,
    required this.skus,
    required this.onAddSubArticle,
    required this.onSave,
    required this.onCancel,
    this.currencyCode = '',
    this.isSaving = false,
    this.error,
    this.onFieldsChanged,
  });

  final GlobalKey<FormState> formKey;
  final bool isNew;
  final TextEditingController titleController;
  final TextEditingController designationController;
  final TextEditingController priceController;
  final TextEditingController costController;
  final TextEditingController barcodeController;
  final TextEditingController unitsController;
  final CalibrePb_StockUnit stockUnit;
  final ValueChanged<CalibrePb_StockUnit> onStockUnitChanged;
  final List<ArticleRetailPb> skus;
  final VoidCallback onAddSubArticle;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String currencyCode;
  final bool isSaving;
  final String? error;
  final VoidCallback? onFieldsChanged;

  bool get _isSingle => skus.length <= 1;

  bool _canSave(CatalogFormValidator validator) {
    if (titleController.text.trim().isEmpty) return false;
    if (priceController.text.trim().isEmpty) return false;
    return !validator.hasErrors;
  }

  String? get _currencySuffix =>
      currencyCode.trim().isEmpty ? null : currencyCode.trim().toUpperCase();

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final validator = context.watch<CatalogFormValidator>();
    return Form(
      key: formKey,
      child: ListView(
        children: [
          EntityEditHeader(
            title: isNew ? lang.catalogNewProduct : lang.catalogEditProduct,
            saveLabel: lang.save,
            cancelLabel: lang.cancel,
            isSaving: isSaving,
            onCancel: onCancel,
            onSave: _canSave(validator) ? onSave : null,
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: kDefaultPadding),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(title: lang.catalogIdentity),
                CardBody(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: lang.catalogColumnTitle,
                          icon: const Icon(Icons.short_text),
                          errorText: validator.titleError,
                        ),
                        onChanged: (v) {
                          validator.validateCalibreTitle(v);
                          onFieldsChanged?.call();
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<CalibrePb_StockUnit>(
                        key: ValueKey(stockUnit),
                        initialValue: stockUnit == CalibrePb_StockUnit.unknown
                            ? CalibrePb_StockUnit.unit
                            : stockUnit,
                        decoration: InputDecoration(
                          labelText: lang.catalogStockUnit,
                          icon: const Icon(Icons.filter_frames),
                        ),
                        items: [
                          for (final unit in CalibrePb_StockUnit.values)
                            if (unit != CalibrePb_StockUnit.unknown)
                              DropdownMenuItem(
                                value: unit,
                                child: Text(unit.name),
                              ),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          onStockUnitChanged(v);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: unitsController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: lang.catalogUnitsInOnePiece,
                          icon: const Icon(Icons.style),
                          errorText: validator.unitsError,
                        ),
                        onChanged: validator.validateUnitsPerPiece,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: kDefaultPadding),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(title: lang.catalogSelling),
                CardBody(
                  child: Column(
                    children: [
                      if (!_isSingle) ...[
                        TextFormField(
                          controller: designationController,
                          decoration: InputDecoration(
                            labelText: lang.catalogColumnDesignation,
                            icon: const Icon(Icons.short_text),
                            errorText: validator.designationError,
                          ),
                          onChanged: (v) {
                            validator.validateArticleDesignation(v);
                            onFieldsChanged?.call();
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: lang.catalogColumnPrice,
                          suffixText: _currencySuffix,
                          icon: const Icon(Icons.local_offer, color: Colors.teal),
                          errorText: validator.priceError,
                        ),
                        onChanged: (v) {
                          validator.validatePrice(v);
                          onFieldsChanged?.call();
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: costController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: lang.catalogCost,
                          suffixText: _currencySuffix,
                          icon: const Icon(Icons.local_offer, color: Colors.red),
                          errorText: validator.costError,
                        ),
                        onChanged: validator.validateCost,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: barcodeController,
                        decoration: InputDecoration(
                          labelText: lang.catalogColumnBarcode,
                          icon: const FaIcon(FontAwesomeIcons.barcode),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (skus.length > 1) ...[
            const SizedBox(height: kDefaultPadding),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardHeader(title: lang.catalogVariants),
                  CardBody(
                    child: Column(
                      children: [
                        for (final sku in skus.skip(1))
                          ListTile(
                            title: Text(
                              sku.designation.isEmpty
                                  ? lang.catalogUnitsInOnePiece
                                  : sku.designation,
                            ),
                            subtitle: Text(
                              [
                                '${sku.unitsInOnePiece}',
                                if (_currencySuffix != null)
                                  '${sku.price} $_currencySuffix'
                                else
                                  '${sku.price}',
                              ].join(' · '),
                            ),
                          ),
                        TextButton.icon(
                          onPressed: onAddSubArticle,
                          icon: const Icon(Icons.add),
                          label: Text(lang.entityAddSku),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAddSubArticle,
                icon: const Icon(Icons.add),
                label: Text(lang.entityAddSku),
              ),
            ),
        ],
      ),
    );
  }
}
