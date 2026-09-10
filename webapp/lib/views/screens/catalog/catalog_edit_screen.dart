import 'package:boutiques_weebi/boutiques_weebi.dart' show BoutiqueProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/catalog/article_label.dart';
import 'package:web_admin/catalog/catalog_api.dart';
import 'package:web_admin/catalog/catalog_form_validator.dart';
import 'package:web_admin/catalog/catalog_notifier.dart';
import 'package:web_admin/core/chain/resolve_chain_id.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/core/routing/routes.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/providers/server.dart';
import 'package:web_admin/views/screens/catalog/catalog_edit_form.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

class CatalogEditScreen extends StatefulWidget {
  const CatalogEditScreen({super.key, this.calibreId});

  final int? calibreId;

  bool get isNew => calibreId == null;

  @override
  State<CatalogEditScreen> createState() => _CatalogEditScreenState();
}

class _CatalogEditScreenState extends State<CatalogEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _designation = TextEditingController();
  final _price = TextEditingController();
  final _cost = TextEditingController();
  final _barcode = TextEditingController();
  final _units = TextEditingController(text: '1');
  CalibrePb_StockUnit _stockUnit = CalibrePb_StockUnit.unit;
  CalibrePb? _draft;
  late final CatalogNotifier _notifier;
  CatalogFormValidator? _formValidator;
  bool _loading = true;
  String? _loadError;
  String _currencyCode = '';

  @override
  void initState() {
    super.initState();
    _notifier = CatalogNotifier(
      api: GrpcCatalogApi(
        context.read<ArticleServiceClientProvider>().articleServiceClient,
      ),
      chainId: '',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final boutiqueProvider = context.read<BoutiqueProvider>();
    _currencyCode = resolveSelectedCurrency(boutiqueProvider);
    final chainId = await resolveSelectedChainId(boutiqueProvider);
    if (!mounted) return;
    if (chainId != null) {
      await _notifier.setChainId(chainId);
    }
    _formValidator = CatalogFormValidator(
      messages: CatalogFormMessages.fromLang(Lang.of(context)),
      isTitleTaken: (title) => _notifier.isCalibreTitleTaken(
        title,
        excludeId: widget.calibreId,
      ),
      isDesignationTaken: (name) async {
        final draft = _draft;
        if (draft != null &&
            draft.articlesRetail.any(
              (a) =>
                  a.id != 1 &&
                  a.designation.asArticleKey == name.asArticleKey,
            )) {
          return true;
        }
        return _notifier.isArticleDesignationTaken(
          name,
          excludeCalibreId: widget.calibreId,
          excludeArticleId: widget.isNew ? null : 1,
        );
      },
    );
    if (widget.isNew) {
      final id = await _notifier.nextCalibreId();
      _draft = newRetailCalibre(
        id: id,
        title: '',
        designation: '',
        price: 0,
        cost: 0,
        barcode: '',
        unitsInOnePiece: 1,
      );
      _bindDraft();
    } else {
      try {
        final calibre = await _notifier.readOne(widget.calibreId!);
        _draft = calibre;
        _bindDraft();
      } catch (e) {
        _loadError = e.toString();
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  void _bindDraft() {
    final draft = _draft!;
    _title.text = draft.title;
    _stockUnit = draft.stockUnit;
    final retail = firstRetailOrNew(draft);
    _designation.text = retail.designation;
    _price.text = retail.price == 0 ? '' : retail.price.toString();
    _cost.text = retail.cost == 0 ? '' : retail.cost.toString();
    _barcode.text = retail.barcodeEAN;
    _units.text = retail.unitsInOnePiece == 0
        ? '1'
        : retail.unitsInOnePiece.toString();
    _formValidator?.setInitialLabels(
      title: draft.title,
      designation: retail.designation,
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _designation.dispose();
    _price.dispose();
    _cost.dispose();
    _barcode.dispose();
    _units.dispose();
    _formValidator?.dispose();
    _notifier.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final validator = _formValidator;
    if (validator == null) return;
    final ok = await validator.validateCalibreCreate(
      title: _title.text.trim(),
      price: _price.text.trim(),
      cost: _cost.text.trim(),
      units: _units.text.trim(),
    );
    if (!ok) return;
    final isSingle = (_draft?.articlesRetail.length ?? 0) <= 1;
    if (!isSingle) {
      await validator.validateArticleDesignation(_designation.text.trim());
      if (validator.hasErrors) return;
    }
    var draft = _draft!;
    final designation = isSingle
        ? _title.text.trim()
        : (_designation.text.trim().isEmpty
            ? _title.text.trim()
            : _designation.text.trim());
    final retail = firstRetailOrNew(draft)
      ..designation = designation
      ..price = num.parse(_price.text.trim()).toDouble()
      ..cost = _cost.text.trim().isEmpty
          ? 0
          : num.parse(_cost.text.trim()).toDouble()
      ..barcodeEAN = _barcode.text.trim()
      ..unitsInOnePiece = _units.text.trim().isEmpty
          ? 1
          : double.parse(_units.text.trim())
      ..calibreId = draft.id
      ..kind = ArticleKindPb.retail
      ..status = true;
    if (draft.articlesRetail.isEmpty) {
      draft.articlesRetail.add(retail);
    } else {
      draft.articlesRetail[0] = retail;
    }
    draft
      ..title = _title.text.trim()
      ..stockUnit = _stockUnit
      ..kind = ArticleKindPb.retail
      ..status = true
      ..updateDate = DateTime.now().toUtc().toIso8601String();
    final saved = await _notifier.save(draft, isNew: widget.isNew);
    if (!mounted) return;
    if (!saved) return;
    final viewPath = RouteUri.catalogViewFor(draft.id);
    if (widget.isNew) {
      context.pushReplacement(viewPath);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(viewPath);
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteUri.catalog);
    }
  }

  Future<void> _addSubArticle() async {
    final draft = _draft!;
    final nextId = draft.articlesRetail.isEmpty
        ? 1
        : draft.articlesRetail.map((a) => a.id).reduce((a, b) => a > b ? a : b) +
            1;
    final sku = await showDialog<ArticleRetailPb>(
      context: context,
      builder: (context) => _SubArticleDialog(
        calibreId: draft.id,
        skuId: nextId,
        currencyCode: _currencyCode,
        isDesignationTaken: (name) async {
          if (draft.articlesRetail.any(
            (a) => a.designation.asArticleKey == name.asArticleKey,
          )) {
            return true;
          }
          return _notifier.isArticleDesignationTaken(name);
        },
      ),
    );
    if (sku == null || !mounted) return;
    setState(() {
      draft.articlesRetail.add(sku);
    });
  }

  @override
  Widget build(BuildContext context) {
    final validator = _formValidator;
    return ListenableBuilder(
      listenable: _notifier,
      builder: (context, _) {
        return PortalMasterLayout(
          selectedMenuUri: RouteUri.catalog,
          body: Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _loadError != null
                    ? Text(_loadError!)
                    : validator == null
                        ? const SizedBox.shrink()
                        : ChangeNotifierProvider<CatalogFormValidator>.value(
                            value: validator,
                            child: CatalogEditForm(
                              formKey: _formKey,
                              isNew: widget.isNew,
                              titleController: _title,
                              designationController: _designation,
                              priceController: _price,
                              costController: _cost,
                              barcodeController: _barcode,
                              unitsController: _units,
                              stockUnit: _stockUnit,
                              onStockUnitChanged: (v) =>
                                  setState(() => _stockUnit = v),
                              skus: [...?_draft?.articlesRetail],
                              onAddSubArticle: _addSubArticle,
                              onSave: _save,
                              onCancel: _goBack,
                              isSaving: _notifier.isLoading,
                              error: _notifier.error,
                              currencyCode: _currencyCode,
                              onFieldsChanged: () => setState(() {}),
                            ),
                          ),
          ),
        );
      },
    );
  }
}

class _SubArticleDialog extends StatefulWidget {
  const _SubArticleDialog({
    required this.calibreId,
    required this.skuId,
    required this.currencyCode,
    required this.isDesignationTaken,
  });

  final int calibreId;
  final int skuId;
  final String currencyCode;
  final Future<bool> Function(String designation) isDesignationTaken;

  @override
  State<_SubArticleDialog> createState() => _SubArticleDialogState();
}

class _SubArticleDialogState extends State<_SubArticleDialog> {
  final _units = TextEditingController();
  final _designation = TextEditingController();
  final _price = TextEditingController();
  final _cost = TextEditingController();
  final _barcode = TextEditingController();
  late final CatalogFormValidator _validator;
  var _didInitValidator = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitValidator) return;
    _didInitValidator = true;
    _validator = CatalogFormValidator(
      messages: CatalogFormMessages.fromLang(Lang.of(context)),
      isDesignationTaken: widget.isDesignationTaken,
    );
  }

  @override
  void dispose() {
    _units.dispose();
    _designation.dispose();
    _price.dispose();
    _cost.dispose();
    _barcode.dispose();
    _validator.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await _validator.validateSubArticle(
      designation: _designation.text.trim(),
      price: _price.text.trim(),
      cost: _cost.text.trim(),
      units: _units.text.trim(),
    );
    if (!ok || !mounted) return;
    final sku = ArticleRetailPb.create()
      ..id = widget.skuId
      ..calibreId = widget.calibreId
      ..designation = _designation.text.trim()
      ..price = num.parse(_price.text.trim()).toDouble()
      ..cost = _cost.text.trim().isEmpty
          ? 0
          : num.parse(_cost.text.trim()).toDouble()
      ..barcodeEAN = _barcode.text.trim()
      ..kind = ArticleKindPb.retail
      ..status = true
      ..unitsInOnePiece = _units.text.trim().isEmpty
          ? 1
          : double.parse(_units.text.trim());
    Navigator.pop(context, sku);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final currency = widget.currencyCode.trim().isEmpty
        ? null
        : widget.currencyCode.trim().toUpperCase();
    return ChangeNotifierProvider<CatalogFormValidator>.value(
      value: _validator,
      child: ListenableBuilder(
        listenable: _validator,
        builder: (context, _) {
          return AlertDialog(
            title: Text(lang.entityAddSku),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _units,
                    autofocus: true,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: lang.catalogUnitsInOnePiece,
                      errorText: _validator.unitsError,
                    ),
                    onChanged: _validator.validateUnitsPerPiece,
                  ),
                  TextField(
                    controller: _designation,
                    decoration: InputDecoration(
                      labelText: lang.catalogColumnDesignation,
                      errorText: _validator.designationError,
                    ),
                    onChanged: _validator.validateArticleDesignation,
                  ),
                  TextField(
                    controller: _price,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: lang.catalogColumnPrice,
                      suffixText: currency,
                      errorText: _validator.priceError,
                    ),
                    onChanged: _validator.validatePrice,
                  ),
                  TextField(
                    controller: _cost,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: lang.catalogCost,
                      suffixText: currency,
                      errorText: _validator.costError,
                    ),
                    onChanged: _validator.validateCost,
                  ),
                  TextField(
                    controller: _barcode,
                    decoration: InputDecoration(
                      labelText: lang.catalogColumnBarcode,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(lang.cancel),
              ),
              FilledButton(
                onPressed: _submit,
                child: Text(lang.save),
              ),
            ],
          );
        },
      ),
    );
  }
}
