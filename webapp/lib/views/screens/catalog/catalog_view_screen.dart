import 'package:boutiques_weebi/boutiques_weebi.dart' show BoutiqueProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/catalog/catalog_api.dart';
import 'package:web_admin/core/chain/resolve_chain_id.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/core/money/money_formatting.dart';
import 'package:web_admin/core/routing/routes.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/providers/server.dart';
import 'package:web_admin/views/widgets/entity/entity_chrome.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:web_admin/views/widgets/protobuf/protobuf_dynamic_body.dart';

class CatalogViewScreen extends StatefulWidget {
  const CatalogViewScreen({super.key, required this.calibreId});

  final int calibreId;

  @override
  State<CatalogViewScreen> createState() => _CatalogViewScreenState();
}

class _CatalogViewScreenState extends State<CatalogViewScreen> {
  CalibrePb? _calibre;
  String? _error;
  bool _loading = true;
  String _currencyCode = MoneyFormatting.fallbackIso;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final boutiqueProvider = context.read<BoutiqueProvider>();
    final articleProvider = context.read<ArticleServiceClientProvider>();
    try {
      _currencyCode = resolveSelectedCurrency(boutiqueProvider);
      final chainId = await resolveSelectedChainId(boutiqueProvider);
      if (!mounted) return;
      final api = GrpcCatalogApi(articleProvider.articleServiceClient);
      final calibre = await api.readOne(
        ReadCalibreRequest(chainId: chainId ?? '', calibreId: widget.calibreId),
      );
      if (!mounted) return;
      setState(() {
        _calibre = calibre;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _delete() async {
    final lang = Lang.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(lang.entityConfirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(lang.entityDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || _calibre == null) return;
    final boutiqueProvider = context.read<BoutiqueProvider>();
    final articleProvider = context.read<ArticleServiceClientProvider>();
    final chainId = await resolveSelectedChainId(boutiqueProvider);
    if (!mounted) return;
    final api = GrpcCatalogApi(articleProvider.articleServiceClient);
    await api.deleteOne(
      CalibreRequest(chainId: chainId ?? '', calibre: _calibre),
    );
    if (!mounted) return;
    context.go(RouteUri.catalog);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final calibre = _calibre;
    final retail =
        calibre != null && calibre.articlesRetail.isNotEmpty
            ? calibre.articlesRetail.first
            : null;

    return PortalMasterLayout(
      selectedMenuUri: RouteUri.catalog,
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Text(_error!)
                : ListView(
                    children: [
                      EntityViewHeader(
                        title: calibre?.title ?? lang.menuCatalog,
                        editLabel: lang.entityEdit,
                        deleteLabel: lang.entityDelete,
                        onEdit: () => context.push(
                          RouteUri.catalogEditFor(widget.calibreId),
                        ),
                        onDelete: _delete,
                      ),
                      if (retail != null) ...[
                        const SizedBox(height: kDefaultPadding),
                        Text(
                          '${lang.catalogColumnPrice}: ${MoneyFormatting.formatAmount(retail.price, _currencyCode, Localizations.localeOf(context))}  ·  ${lang.catalogCost}: ${MoneyFormatting.formatAmount(retail.cost, _currencyCode, Localizations.localeOf(context))}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                      const SizedBox(height: kDefaultPadding),
                      if (calibre != null)
                        ProtobufDynamicBody(
                          pbObject: calibre,
                          skipFieldNames: const ['codeShortcut'],
                        ),
                    ],
                  ),
      ),
    );
  }
}
