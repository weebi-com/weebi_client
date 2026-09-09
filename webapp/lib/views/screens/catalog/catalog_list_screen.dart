import 'package:auth_weebi/auth_weebi.dart' show PermissionProvider;
import 'package:boutiques_weebi/boutiques_weebi.dart' show BoutiqueProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:web_admin/catalog/catalog_api.dart';
import 'package:web_admin/catalog/catalog_notifier.dart';
import 'package:web_admin/core/chain/resolve_chain_id.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/core/routing/routes.dart';
import 'package:web_admin/providers/server.dart';
import 'package:web_admin/views/screens/catalog/catalog_list_content.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

class CatalogListScreen extends StatelessWidget {
  const CatalogListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final api = GrpcCatalogApi(
          context.read<ArticleServiceClientProvider>().articleServiceClient,
        );
        final notifier = CatalogNotifier(api: api, chainId: '');
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final chainId = await resolveSelectedChainId(
            context.read<BoutiqueProvider>(),
            firmIdFallback:
                context.read<PermissionProvider>().userPermissions.firmId,
          );
          if (!context.mounted) return;
          if (chainId != null) {
            await notifier.setChainId(chainId);
          } else {
            await notifier.load();
          }
        });
        return notifier;
      },
      child: Builder(
        builder: (context) {
          return PortalMasterLayout(
            selectedMenuUri: RouteUri.catalog,
            body: Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: CatalogListContent(
                onCreate: () => context.push(RouteUri.catalogNew),
                onOpen: (calibre) =>
                    context.push(RouteUri.catalogViewFor(calibre.id)),
              ),
            ),
          );
        },
      ),
    );
  }
}
