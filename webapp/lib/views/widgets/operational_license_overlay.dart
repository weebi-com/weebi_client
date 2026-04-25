import 'package:auth_weebi/auth_weebi.dart' show PermissionProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/core/grpc/firm_product_access.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/providers/operational_license_gate.dart';

/// Dimming full-screen layer when [OperationalLicenseGateNotifier] reports a block
/// after a gRPC error carrying [kOperationalLicenseRequired] (see
/// [OperationalLicenseGrpcInterceptor]).
class OperationalLicenseOverlay extends StatelessWidget {
  const OperationalLicenseOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<OperationalLicenseGateNotifier>(
      builder: (context, gate, _) {
        if (!gate.isBlocked) return child;

        final lang = Lang.of(context);
        final theme = Theme.of(context);

        final canOpenBilling =
            context.watch<PermissionProvider>().canReadBilling;

        return Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(child: Opacity(opacity: 0.45, child: child)),
            ModalBarrier(color: Colors.black.withValues(alpha: 0.35), dismissible: false),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  elevation: 6,
                  margin: const EdgeInsets.all(kDefaultPadding),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          lang.operationalLicenseBlockedTitle,
                          style: theme.textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          lang.operationalLicenseBlockedBody,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (canOpenBilling)
                          FilledButton(
                            onPressed: () =>
                                GoRouter.of(context).go(RouteUri.billing),
                            child: Text(lang.operationalLicenseOpenBilling),
                          )
                        else
                          Text(
                            lang.billingNoAccess,
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () =>
                              context.read<OperationalLicenseGateNotifier>().clear(),
                          child: Text(lang.operationalLicenseRetry),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
