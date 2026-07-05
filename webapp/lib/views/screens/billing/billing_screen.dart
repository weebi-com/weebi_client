// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:auth_weebi/auth_weebi.dart' show PermissionProvider;
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart' hide ConnectionState;
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:auth_weebi/src/extensions/user_permissions_extensions.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/providers/server.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:web_admin/core/services/user_service.dart';
import 'package:web_admin/legal/enterprise_terms_version.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/providers/current_user_provider.dart';

import '../../../core/constants/dimens.dart';
import '../../../core/theme/theme_extensions/app_color_scheme.dart';
import 'billing_plan_label.dart';
import 'billing_plan_theme.dart';

/// Query params from current URL. With hash routing, params may be in the fragment (#/billing?success=...).
Map<String, String> _billingQueryParams() {
  final base = Uri.base;
  final fragment = base.fragment;
  final qIndex = fragment.indexOf('?');
  if (qIndex >= 0) {
    return Uri.splitQueryString(fragment.substring(qIndex + 1));
  }
  return base.queryParameters;
}

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  List<License> _licenses = [];
  List<BillingProduct> _products = [];
  /// User info by userId, loaded when we have licenses (to show attributed users).
  Map<String, UserPublic>? _usersById;
  bool _loading = true;
  String? _errorMessage;
  String? _checkoutProductId;
  bool _acceptedEnterpriseTerms = false;
  bool _licensePurchaseConfirmedLogged = false;
  bool _checkoutCanceledLogged = false;
  bool _dataLoaded = false;

  /// Check if user has billing read permission from either JWT or session (BFF mode)
  bool _hasReadBillingPermission(BuildContext context) {
    // Check JWT-based permissions first
    if (context.read<PermissionProvider>().canReadBilling) {
      return true;
    }
    
    // In BFF mode, also check CurrentUserProvider (session-based permissions)
    if (Config.isBffMode) {
      final currentUser = context.read<CurrentUserProvider>();
      if (currentUser.user != null) {
        return currentUser.permissions.canReadBilling;
      }
    }
    
    return false;
  }

  /// Check if user has billing create permission from either JWT or session (BFF mode)
  bool _hasCreateBillingPermission(BuildContext context) {
    if (context.read<PermissionProvider>().canCreateBilling) {
      return true;
    }
    
    if (Config.isBffMode) {
      final currentUser = context.read<CurrentUserProvider>();
      if (currentUser.user != null) {
        return currentUser.permissions.canCreateBilling;
      }
    }
    
    return false;
  }

  /// Check if user has billing update permission from either JWT or session (BFF mode)
  bool _hasUpdateBillingPermission(BuildContext context) {
    if (context.read<PermissionProvider>().canUpdateBilling) {
      return true;
    }
    
    if (Config.isBffMode) {
      final currentUser = context.read<CurrentUserProvider>();
      if (currentUser.user != null) {
        return currentUser.permissions.canUpdateBilling;
      }
    }
    
    return false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_hasReadBillingPermission(context)) return;

      Aptabase.instance.trackEvent('billing_screen_opened', {});
      _loadData();
      // If returning from Stripe success with session_id, sync license (webhook may have failed)
      final params = _billingQueryParams();
      final sessionId = params['session_id'];
      if (params['success'] == 'true' &&
          sessionId != null &&
          sessionId.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          final provider = context.read<BillingServiceClientProvider>();
          try {
            await provider.billingServiceClient.fulfillFromStripeCheckoutSession(
              FulfillFromStripeCheckoutSessionRequest(
                checkoutSessionId: sessionId,
                legalTermsVersionDate: kEnterpriseTermsVersionId,
              ),
            );
          } catch (_) {
            // Idempotent: already fulfilled or not paid yet; loadData will show current state
          }
          if (mounted) _loadData();
        });
      } else if (params['canceled'] == 'true') {
        if (!_checkoutCanceledLogged) {
          _checkoutCanceledLogged = true;
          Aptabase.instance.trackEvent('billing_license_checkout_failed', {
            'reason': 'checkout_canceled',
          });
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _loadData();
        });
      }
    });
  }

  void _maybeTrackLicensePurchaseConfirmed(List<License> licenses) {
    if (_licensePurchaseConfirmedLogged) return;
    if (_billingQueryParams()['success'] != 'true') return;
    if (licenses.isEmpty) return;
    _licensePurchaseConfirmedLogged = true;
    Aptabase.instance.trackEvent('billing_license_purchase_confirmed', {
      'license_count': licenses.length,
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    if (!_hasReadBillingPermission(context)) return;
    final provider = context.read<BillingServiceClientProvider>();
    setState(() {
      _loading = true;
      _errorMessage = null;
      _dataLoaded = true;
    });

    try {
      final licensesFuture =
          provider.billingServiceClient.readLicenses(Empty());
      final productsFuture =
          provider.billingServiceClient.readBillingProducts(Empty());

      final results = await Future.wait([licensesFuture, productsFuture]);
      final licensesResponse = results[0] as ReadLicensesResponse;
      final productsResponse = results[1] as ReadBillingProductsResponse;
      final licenses = licensesResponse.licenses;
      final products = productsResponse.products;

      Map<String, UserPublic>? usersById;
      if (licenses.isNotEmpty) {
        try {
          final usersResponse = await UserService().readAllUsers();
          usersById = {for (final u in usersResponse.users) u.userId: u};
        } catch (_) {
          // Keep usersById null; cards will show userId only
        }
      }

      if (mounted) {
        setState(() {
          _licenses =
              licenses.where(isBillingCatalogLicense).toList();
          _products =
              products.where((p) => isBillingCatalogProduct(p.productId)).toList();
          _usersById = usersById;
          _loading = false;
          _errorMessage = null;
        });
        _maybeTrackLicensePurchaseConfirmed(licenses);
      }
    } on GrpcError catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = e.message ?? 'An error occurred';
          _dataLoaded = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = e.toString();
          _dataLoaded = false;
        });
      }
    }
  }

  void _openLegalDocumentInNewTab() {
    Aptabase.instance.trackEvent('billing_terms_full_document_opened', {});
    final locale = Localizations.localeOf(context);
    final path = locale.languageCode == 'fr'
        ? RouteUri.legalCgvFr
        : RouteUri.legalTermsEn;
    final url = '${html.window.location.origin}/#$path';
    html.window.open(url, '_blank');
  }

  void _setEnterpriseTermsAccepted(bool value) {
    if (value == _acceptedEnterpriseTerms) return;
    setState(() => _acceptedEnterpriseTerms = value);
    Aptabase.instance.trackEvent('billing_enterprise_terms_toggled', {
      'accepted': value ? 1 : 0,
    });
  }

  Widget _enterpriseTermsAcceptanceBlock(ThemeData theme, Lang lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: _openLegalDocumentInNewTab,
          child: Text(lang.billingViewFullTerms, 
          style: TextStyle(color: theme.colorScheme.primary, 
          fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.underline)),
        ),
                const SizedBox(height: kDefaultPadding),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _acceptedEnterpriseTerms,
              onChanged: (v) => _setEnterpriseTermsAccepted(v ?? false),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _setEnterpriseTermsAccepted(
                  !_acceptedEnterpriseTerms,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    lang.billingAcceptEnterpriseTerms,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ],
        ),

      ],
    );
  }

  void _onLicensePurchaseTapped(BillingProduct product) {
    Aptabase.instance.trackEvent('billing_license_purchase_clicked', {
      'product_id': product.productId,
    });
    _purchaseProduct(product);
  }

  Future<void> _purchaseProduct(BillingProduct product) async {
    if (!mounted) return;
    if (!_hasCreateBillingPermission(context)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Lang.of(context).billingActionNotPermitted)),
      );
      return;
    }
    if (!_acceptedEnterpriseTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Lang.of(context).billingAcceptTermsToContinue)),
      );
      return;
    }
    final provider = context.read<BillingServiceClientProvider>();
    final stripePriceId = product.stripePriceId;
    if (stripePriceId.isEmpty) return;

    setState(() => _checkoutProductId = product.productId);

    try {
      // Use hash-based return URL so the app router (e.g. #/billing) shows Billing after redirect
      final origin = html.window.location.origin;
      const billingPath = RouteUri.billing;
      final successUrl = '$origin/#$billingPath?success=true&session_id={CHECKOUT_SESSION_ID}';
      final cancelUrl = '$origin/#$billingPath?canceled=true';
      final request = CreateCheckoutSessionRequest(
        priceId: stripePriceId,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
        legalTermsVersionDate: kEnterpriseTermsVersionId,
      );

      final response = await provider.billingServiceClient
          .createCheckoutSession(request);

      if (!mounted) return;
      if (response.checkoutUrl.isEmpty) {
        Aptabase.instance.trackEvent('billing_license_checkout_failed', {
          'reason': 'empty_checkout_url',
          'product_id': product.productId,
        });
        setState(() {
          _checkoutProductId = null;
          _errorMessage = 'Checkout failed';
        });
        return;
      }
      html.window.location.href = response.checkoutUrl;
    } on GrpcError catch (e) {
      Aptabase.instance.trackEvent('billing_license_checkout_failed', {
        'reason': 'checkout_session_grpc',
        'product_id': product.productId,
        'code': e.code,
        'detail': e.message ?? '',
      });
      if (mounted) {
        setState(() {
          _checkoutProductId = null;
          _errorMessage = e.message ?? 'Checkout failed';
        });
      }
    } catch (e) {
      Aptabase.instance.trackEvent('billing_license_checkout_failed', {
        'reason': 'checkout_session_error',
        'product_id': product.productId,
        'detail': e.toString(),
      });
      if (mounted) {
        setState(() {
          _checkoutProductId = null;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _showAssignSeatDialog(BuildContext context, License license) {
    if (!_hasUpdateBillingPermission(context)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Lang.of(context).billingActionNotPermitted)),
      );
      return;
    }
    final attributed = license.seats.where((s) => s.userId.isNotEmpty).length;
    if (attributed >= license.maxUsers) return;

    // Users who already have any license attributed (across all licenses)
    final allAttributedUserIds = <String>{
      for (final lic in _licenses)
        for (final seat in lic.seats)
          if (seat.userId.isNotEmpty) seat.userId,
    };

    showDialog<void>(
      context: context,
      builder: (ctx) => _AssignSeatDialog(
        license: license,
        allAttributedUserIds: allAttributedUserIds,
        onAssigned: () {
          Navigator.of(ctx).pop();
          _loadData();
        },
      ),
    );
  }

  void _showReassignSeatDialog(
    BuildContext context,
    License license,
    String previousUserId,
  ) {
    if (!_hasUpdateBillingPermission(context)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Lang.of(context).billingActionNotPermitted)),
      );
      return;
    }
    if (previousUserId.isEmpty) return;
    final allAttributedUserIds = <String>{
      for (final lic in _licenses)
        for (final seat in lic.seats)
          if (seat.userId.isNotEmpty) seat.userId,
    };

    showDialog<void>(
      context: context,
      builder: (ctx) => _AssignSeatDialog(
        license: license,
        allAttributedUserIds: allAttributedUserIds,
        replaceSeatUserId: previousUserId,
        onAssigned: () {
          Navigator.of(ctx).pop();
          _loadData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final appColorScheme = themeData.extension<AppColorScheme>()!;
    final lang = Lang.of(context);

    final permissionProvider = context.watch<PermissionProvider>();
    final currentUser = context.watch<CurrentUserProvider>();
    final billingProvider = context.watch<BillingServiceClientProvider>();

    // Check permissions from both JWT and session (BFF mode)
    final hasPermission = _hasReadBillingPermission(context);

    if (hasPermission && !_dataLoaded && !_loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    }

    // In BFF mode, if user is loaded but has no permission, show error.
    // If user is still loading, show spinner to avoid false "no access" message.
    if (!hasPermission) {
      if (Config.isBffMode) {
        if (currentUser.isLoading ||
            (currentUser.user == null && currentUser.error == null)) {
          // User data still loading; show spinner instead of "no access"
          return PortalMasterLayout(
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (currentUser.error != null) {
          return PortalMasterLayout(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${lang.firmErrorUnexpected}: ${currentUser.error}'),
                  const SizedBox(height: kDefaultPadding),
                  ElevatedButton(
                    onPressed: () => currentUser.load(force: true),
                    child: Text(lang.billingRetry),
                  ),
                ],
              ),
            ),
          );
        }
      }
      
      return PortalMasterLayout(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding * 2),
              child: Text(
                lang.billingNoAccess,
                style: themeData.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }
    final canPurchase = _hasCreateBillingPermission(context);
    final canManageSeats = _hasUpdateBillingPermission(context);
    final totalSeats = _licenses.fold<int>(0, (sum, l) => sum + l.maxUsers);
    final returnedFromSuccess =
        _billingQueryParams()['success'] == 'true' && !_loading;

    return PortalMasterLayout(
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            lang.menuBilling,
            style: themeData.textTheme.headlineMedium,
          ),
          if (returnedFromSuccess) ...[
            Padding(
              padding: const EdgeInsets.only(top: kDefaultPadding),
              child: Material(
                color: _licenses.isNotEmpty
                    ? themeData.colorScheme.primaryContainer
                    : themeData.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kDefaultPadding,
                    vertical: kDefaultPadding * 0.75,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _licenses.isNotEmpty
                                ? Icons.check_circle_outline_rounded
                                : Icons.schedule_rounded,
                            color: _licenses.isNotEmpty
                                ? themeData.colorScheme.onPrimaryContainer
                                : themeData.colorScheme.onSecondaryContainer,
                            size: 24,
                          ),
                          const SizedBox(width: kDefaultPadding),
                          Expanded(
                            child: Text(
                              _licenses.isNotEmpty
                                  ? lang.billingPaymentSuccess
                                  : lang.billingPaymentProcessing,
                              style: themeData.textTheme.bodyMedium!.copyWith(
                                color: _licenses.isNotEmpty
                                    ? themeData.colorScheme.onPrimaryContainer
                                    : themeData.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_licenses.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            lang.billingAssignSeatsCta,
                            style: themeData.textTheme.bodySmall!.copyWith(
                              color: themeData.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_loading)
                    const CardBody(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(kDefaultPadding * 2),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                  else if (_errorMessage != null)
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Chip(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                              vertical: 6.0,
                            ),
                            backgroundColor: appColorScheme.error,
                            label: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: themeData.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: kDefaultPadding),
                            child: TextButton.icon(
                              onPressed: _loadData,
                              icon: const Icon(Icons.refresh_rounded),
                              label: Text(lang.billingRetry),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_licenses.isEmpty) ...[
                    CardHeader(title: lang.billingPurchaseLicense),
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.billingPurchaseLicenseDescription,
                            style: themeData.textTheme.bodyMedium,
                          ),
                          if (_products.isNotEmpty) ...[
                            const SizedBox(height: kDefaultPadding * 2),
                            _enterpriseTermsAcceptanceBlock(themeData, lang),
                          ],
                          const SizedBox(height: kDefaultPadding * 2),
                          Wrap(
                            spacing: kDefaultPadding,
                            runSpacing: kDefaultPadding,
                            children: _products
                                .map((p) => _ProductOfferCard(
                                      product: p,
                                      onPurchase: () => _onLicensePurchaseTapped(p),
                                      isLoading: _checkoutProductId == p.productId,
                                      purchaseEnabled:
                                          canPurchase && _acceptedEnterpriseTerms,
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Purchase / get more on top so it stays visible when many licenses
                          if (_products.isNotEmpty) ...[
                            Text(
                              lang.billingPurchaseLicense,
                              style: themeData.textTheme.titleMedium,
                            ),
                            const SizedBox(height: kDefaultPadding * 0.75),
                            Text(
                              lang.billingPurchaseLicenseDescription,
                              style: themeData.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: kDefaultPadding),
                            _enterpriseTermsAcceptanceBlock(themeData, lang),
                            const SizedBox(height: kDefaultPadding),
                            Wrap(
                              spacing: kDefaultPadding,
                              runSpacing: kDefaultPadding,
                              children: _products
                                  .map((p) => _ProductOfferCard(
                                        product: p,
                                        onPurchase: () =>
                                            _onLicensePurchaseTapped(p),
                                        isLoading: _checkoutProductId == p.productId,
                                        purchaseEnabled: canPurchase &&
                                            _acceptedEnterpriseTerms,
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: kDefaultPadding * 2),
                            const Divider(),
                            const SizedBox(height: kDefaultPadding * 2),
                          ],
                          // My licenses header below the purchase section
                          Text(
                            '${lang.billingMyLicenses} ($totalSeats ${lang.billingLicenses})',
                            style: themeData.textTheme.titleMedium,
                          ),
                          const SizedBox(height: kDefaultPadding),
                          ..._licenses.map(
                            (license) => _LicenseCard(
                              license: license,
                              usersById: _usersById,
                              canManageSeats: canManageSeats,
                              onAssignSeats: () =>
                                  _showAssignSeatDialog(context, license),
                              onReassignSeat: (userId) =>
                                  _showReassignSeatDialog(
                                      context, license, userId),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductOfferCard extends StatelessWidget {
  final BillingProduct product;
  final VoidCallback onPurchase;
  final bool isLoading;
  final bool purchaseEnabled;

  const _ProductOfferCard({
    required this.product,
    required this.onPurchase,
    required this.isLoading,
    required this.purchaseEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final lang = Lang.of(context);
    final priceStr = (product.amountCents / 100).toStringAsFixed(2);
    final currency =
        product.currency.isNotEmpty ? product.currency.toUpperCase() : 'EUR';
    final planName = billingPlanLabel(lang, productId: product.productId);
    final style = BillingPlanVisual.fromProductId(product.productId);

    return SizedBox(
      width: 240,
      child: Card(
        elevation: style.elevation,
        color: style.background,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding * 1.25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                planName,
                style: themeData.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: style.onBackground,
                  letterSpacing: product.productId.toLowerCase() == 'premium'
                      ? 0.4
                      : 0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$priceStr $currency',
                style: themeData.textTheme.headlineSmall!.copyWith(
                  color: style.priceColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                lang.billingPerUser,
                style: themeData.textTheme.titleSmall?.copyWith(
                  color: style.mutedOnBackground,
                ),
              ),
              const SizedBox(height: kDefaultPadding * 1.25),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: style.buttonBackground,
                    foregroundColor: style.buttonForeground,
                    disabledBackgroundColor:
                        style.buttonBackground.withValues(alpha: 0.45),
                    disabledForegroundColor:
                        style.buttonForeground.withValues(alpha: 0.6),
                  ),
                  onPressed:
                      (isLoading || !purchaseEnabled) ? null : onPurchase,
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: style.buttonForeground,
                          ),
                        )
                      : Text(lang.billingPurchase),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LicenseCard extends StatelessWidget {
  final License license;
  final Map<String, UserPublic>? usersById;
  final bool canManageSeats;
  final VoidCallback onAssignSeats;
  /// Called with the current [LicenseSeat.userId] to open reassignment.
  final void Function(String seatUserId) onReassignSeat;

  const _LicenseCard({
    required this.license,
    this.usersById,
    this.canManageSeats = true,
    required this.onAssignSeats,
    required this.onReassignSeat,
  });

  int get _attributedCount =>
      license.seats.where((s) => s.userId.isNotEmpty).length;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final lang = Lang.of(context);
    final planName = billingPlanLabel(lang, licensePlan: license.licensePlan);
    final style = BillingPlanVisual.fromLicensePlan(license.licensePlan);
    final validUntil = license.hasValidUntil()
        ? _formatTimestamp(license.validUntil)
        : lang.billingLifetime;
    final purchasedOn =
        license.hasValidFrom() ? _formatTimestamp(license.validFrom) : null;
    final attributed = _attributedCount;
    final total = license.maxUsers;
    final notYetAttributed = attributed == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: kDefaultPadding),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding,
              vertical: kDefaultPadding * 0.85,
            ),
            color: style.background,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    planName,
                    style: themeData.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: style.onBackground,
                      letterSpacing:
                          license.licensePlan == LicensePlan.PREMIUM ? 0.35 : 0,
                    ),
                  ),
                ),
                Chip(
                  backgroundColor:
                      style.onBackground.withValues(alpha: 0.18),
                  side: BorderSide(
                    color: style.onBackground.withValues(alpha: 0.35),
                  ),
                  label: Text(
                    '${license.maxUsers} ${lang.billingLicenses}',
                    style: themeData.textTheme.bodyMedium!.copyWith(
                      color: style.onBackground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Attribution status: plain text for state; primary button is the only CTA
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  if (notYetAttributed)
                    Text(
                      lang.billingNotYetAttributed,
                      style: themeData.textTheme.bodyMedium,
                    )
                  else
                    Text(
                      '$attributed / $total ${lang.billingSeatsAttributed}',
                      style: themeData.textTheme.bodyMedium,
                    ),
                  if (canManageSeats && attributed < total) ...[
                    const SizedBox(width: kDefaultPadding),
                    FilledButton(
                      onPressed: onAssignSeats,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(lang.billingAssignSeats),
                    ),
                  ],
                ],
              ),
            ),
            // Show to which user(s) the license has been attributed (bigger, clearer)
            ...license.seats
                .where((s) => s.userId.isNotEmpty)
                .map((seat) {
                  final u = usersById?[seat.userId];
                  final label = u != null
                      ? ('${u.firstname} ${u.lastname}'.trim().isNotEmpty
                            ? '${u.firstname} ${u.lastname}'.trim()
                            : u.mail.isNotEmpty
                                ? u.mail
                                : seat.userId)
                      : seat.userId;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.billingAttributedTo,
                                style: themeData.textTheme.bodyMedium?.copyWith(
                                  color: themeData
                                      .colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                label,
                                style: themeData.textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (canManageSeats)
                          TextButton(
                            onPressed: () => onReassignSeat(seat.userId),
                            child: Text(lang.billingReassignSeat),
                          ),
                      ],
                    ),
                  );
                }),
            if (license.licenseId.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'ID: ${license.licenseId}',
                  style: themeData.textTheme.bodySmall,
                ),
              ),
            if (purchasedOn != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Purchased on: $purchasedOn',
                  style: themeData.textTheme.bodySmall,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${lang.billingValidUntil}: $validUntil',
                style: themeData.textTheme.bodySmall,
              ),
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(
      ts.seconds.toInt() * 1000,
      isUtc: true,
    );
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

/// Dialog to pick a user and assign one seat of [license] to them.
/// Only users who do not yet have any license attributed are shown.
///
/// When [replaceSeatUserId] is set, that user is treated as no longer holding
/// their seat for occupancy purposes, and the picker excludes them so the
/// owner can choose another user; the selected seat row is updated in place.
class _AssignSeatDialog extends StatefulWidget {
  final License license;
  /// User IDs that already have a license (any plan). Excluded from the list.
  final Set<String> allAttributedUserIds;
  /// If non-empty, reassign this seat ([LicenseSeat.userId]) instead of adding a seat.
  final String? replaceSeatUserId;
  final VoidCallback onAssigned;

  const _AssignSeatDialog({
    required this.license,
    required this.allAttributedUserIds,
    this.replaceSeatUserId,
    required this.onAssigned,
  });

  @override
  State<_AssignSeatDialog> createState() => _AssignSeatDialogState();
}

class _AssignSeatDialogState extends State<_AssignSeatDialog> {
  bool _assigning = false;
  String? _error;

  Future<void> _assignSeatToUser(UserPublic user) async {
    if (!mounted) return;
    setState(() {
      _assigning = true;
      _error = null;
    });

    try {
      // Persist attribution in the backend via BillingService.updateLicense (gRPC).
      // The license's seats (with userId) are stored in the firm document (e.g. MongoDB).
      final billingClient = context.read<BillingServiceClientProvider>().billingServiceClient;
      final updated = License()..mergeFromMessage(widget.license);
      final previous = widget.replaceSeatUserId?.trim() ?? '';
      if (previous.isNotEmpty) {
        final idx = updated.seats.indexWhere((s) => s.userId == previous);
        if (idx < 0) {
          if (mounted) {
            setState(() {
              _assigning = false;
              _error = 'Seat not found; refresh the page and try again.';
            });
          }
          return;
        }
        if (updated.seats[idx].userId == user.userId) {
          if (mounted) Navigator.of(context).pop();
          return;
        }
        updated.seats[idx].userId = user.userId;
      } else {
        updated.seats.add(LicenseSeat()..userId = user.userId);
      }

      await billingClient.updateLicense(
        UpdateLicenseRequest(
          licenseId: widget.license.licenseId,
          license: updated,
        ),
      );
      if (mounted) widget.onAssigned();
    } on GrpcError catch (e) {
      if (mounted) {
        setState(() {
          _assigning = false;
          _error = e.message ?? 'Failed to assign seat';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _assigning = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final lang = Lang.of(context);

    final isReassign =
        widget.replaceSeatUserId != null &&
            widget.replaceSeatUserId!.trim().isNotEmpty;

    return AlertDialog(
      title: Text(
        isReassign
            ? lang.billingReassignSeatDialogTitle
            : lang.billingAssignSeatDialogTitle,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<UsersPublic>(
          future: UserService().readAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: kDefaultPadding * 2),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Text(
                snapshot.error.toString(),
                style: themeData.textTheme.bodySmall?.copyWith(
                  color: themeData.colorScheme.error,
                ),
              );
            }
            final response = snapshot.data;
            if (response == null || response.users.isEmpty) {
              return Text(lang.billingNoUsersAvailable);
            }
            final blocked = Set<String>.from(widget.allAttributedUserIds);
            final releasing = widget.replaceSeatUserId?.trim() ?? '';
            if (releasing.isNotEmpty) {
              blocked.remove(releasing);
            }
            // Assign: users without any seat. Reassign: same, but not the current holder.
            final available = response.users
                .where((u) => !blocked.contains(u.userId))
                .where((u) => !isReassign || u.userId != releasing)
                .toList();
            if (available.isEmpty) {
              return Text(
                isReassign
                    ? lang.billingReassignNoOtherUser
                    : lang.billingAllUsersAlreadyAssigned,
                style: themeData.textTheme.bodyMedium,
              );
            }
            if (_error != null) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _error!,
                    style: themeData.textTheme.bodySmall?.copyWith(
                      color: themeData.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: kDefaultPadding),
                  _UserListView(
                    users: available,
                    onTap: _assigning ? null : _assignSeatToUser,
                  ),
                ],
              );
            }
            return _UserListView(
              users: available,
              onTap: _assigning ? null : _assignSeatToUser,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _assigning ? null : () => Navigator.of(context).pop(),
          child: Text(lang.cancel),
        ),
      ],
    );
  }
}

/// User list rows: avatar + name + email, same pattern as users_weebi list UI.
class _UserListView extends StatelessWidget {
  final List<UserPublic> users;
  final void Function(UserPublic)? onTap;

  const _UserListView({required this.users, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 320),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: users.length,
        itemBuilder: (context, index) {
          final u = users[index];
          final name = '${u.firstname} ${u.lastname}'.trim();
          final initial = name.isNotEmpty
              ? name.substring(0, 1).toUpperCase()
              : (u.mail.isNotEmpty ? u.mail.substring(0, 1).toUpperCase() : '?');

          return ListTile(
            leading: CircleAvatar(
              child: Text(initial),
            ),
            title: Text(name.isNotEmpty ? name : u.userId),
            subtitle: u.mail.isNotEmpty ? Text(u.mail) : null,
            onTap: onTap != null ? () => onTap!(u) : null,
          );
        },
      ),
    );
  }
}
