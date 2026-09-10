import 'package:auth_weebi/auth_weebi.dart' show PermissionProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:web_admin/core/routing/routes.dart';
import 'package:web_admin/providers/freemium_dump_quota_gate.dart';

/// Non-blocking MaterialBanner when a freemium full-dump quota error is seen.
class FreemiumDumpQuotaBannerHost extends StatelessWidget {
  const FreemiumDumpQuotaBannerHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<FreemiumDumpQuotaNotifier>(
      builder: (context, gate, _) {
        final err = gate.lastError;
        if (err == null) return child;

        final locale = Localizations.localeOf(context).languageCode;
        final isFr = locale == 'fr';
        final canOpenBilling =
            context.watch<PermissionProvider>().canReadBilling;
        final title = isFr
            ? 'Téléchargement complet limité (sans licence)'
            : 'Full download limited (no license)';
        final body = err.userFacingMessageFr();
        final enBody =
            'Full download (${err.resource}) is limited without a license. '
            'Retry after ${err.retryAfterUtc.toLocal().day}/'
            '${err.retryAfterUtc.toLocal().month}/'
            '${err.retryAfterUtc.toLocal().year}, or assign a license.';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MaterialBanner(
              content: Text('$title — ${isFr ? body : enBody}'),
              leading: const Icon(Icons.hourglass_top),
              actions: [
                if (canOpenBilling)
                  TextButton(
                    onPressed: () {
                      gate.clear();
                      GoRouter.of(context).go(RouteUri.billing);
                    },
                    child: Text(isFr ? 'Facturation' : 'Billing'),
                  ),
                TextButton(
                  onPressed: gate.clear,
                  child: Text(isFr ? 'Fermer' : 'Dismiss'),
                ),
              ],
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
