// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
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
import 'package:web_admin/core/billing/billing_bridge_destination.dart';

import 'billing_plan_label.dart';
import 'billing_plan_theme.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen>
    with SingleTickerProviderStateMixin {
  List<License> _licenses = [];
  List<BillingProduct> _products = [];
  BillingProduct? _syscohadaProduct;
  List<AccountingYearPurchase> _accountingPurchases = [];
  late int _syscohadaFiscalYear;
  late final TabController _tabController;
  /// User info by userId, loaded when we have licenses (to show attributed users).
  Map<String, UserPublic>? _usersById;
  bool _loading = false;
  String? _errorMessage;
  String? _checkoutProductId;
  /// Product highlighted from App->Web magic-link / deep-link (`premium` or `syscohada`).
  String? _bridgeHighlightProductId;
  bool _acceptedEnterpriseTerms = false;
  bool _acceptedSyscohadaTerms = false;
  bool _licensePurchaseConfirmedLogged = false;
  bool _checkoutCanceledLogged = false;
  bool _dataLoaded = false;
  bool _checkoutReturnHandled = false;
  bool _bootstrapStarted = false;

  void _applyBridgeDeepLink(Map<String, String> params) {
    final dest = parseBillingBridgeDestination(query: params);
    if (dest == null) return;
    _bridgeHighlightProductId = dest.productId;
    if (dest.fiscalYear != null) {
      _syscohadaFiscalYear = dest.fiscalYear!;
    }
  }

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
    _tabController = TabController(length: 2, vsync: this);
    _syscohadaFiscalYear = DateTime.now().year;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final params = billingQueryParamsFromLocation();
      _applyBridgeDeepLink(params);
      if (!_hasReadBillingPermission(context)) return;

      Aptabase.instance.trackEvent('billing_screen_opened', {});
      _bootstrapBilling(params);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _switchToHistoryTab() {
    if (!mounted || _tabController.index == 1) return;
    _tabController.animateTo(1);
  }

  Future<void> _bootstrapBilling(Map<String, String> params) async {
    if (_bootstrapStarted) return;
    _bootstrapStarted = true;
    await _loadData();
    if (!mounted) return;
    if (params['success'] == 'true') {
      await _syncFulfillAfterCheckoutReturn(params);
      if (!mounted) return;
      await _loadData(silent: true);
      _maybeClearCheckoutReturnQuery();
      if (_licenses.isNotEmpty || _accountingPurchases.isNotEmpty) {
        _switchToHistoryTab();
      }
    } else if (params['canceled'] == 'true') {
      if (!_checkoutCanceledLogged) {
        _checkoutCanceledLogged = true;
        Aptabase.instance.trackEvent('billing_license_checkout_failed', {
          'reason': 'checkout_canceled',
        });
      }
    }
  }

  /// Drop `success` / provider / session ids from the hash so a rebuild does not
  /// re-enter the return flow or keep a perpetual "processing" banner.
  void _maybeClearCheckoutReturnQuery() {
    if (_checkoutReturnHandled) return;
    final params = billingQueryParamsFromLocation();
    if (params['success'] != 'true') return;
    final purchaseVisible =
        _licenses.isNotEmpty || _accountingPurchases.isNotEmpty;
    if (!purchaseVisible) return;
    _checkoutReturnHandled = true;
    final uri = Uri.parse(html.window.location.href);
    final fragment = uri.fragment;
    final qIndex = fragment.indexOf('?');
    if (qIndex < 0) return;
    final path = fragment.substring(0, qIndex);
    final cleaned = Map<String, String>.from(
      Uri.splitQueryString(fragment.substring(qIndex + 1)),
    );
    cleaned.remove('success');
    cleaned.remove('provider');
    cleaned.remove('checkout_id');
    cleaned.remove('session_id');
    final newFragment = cleaned.isEmpty
        ? path
        : '$path?${Uri(queryParameters: cleaned).query}';
    html.window.history.replaceState(
      null,
      '',
      '${uri.origin}${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}#$newFragment',
    );
  }

  void _maybeTrackLicensePurchaseConfirmed(List<License> licenses) {
    if (_licensePurchaseConfirmedLogged) return;
    if (billingQueryParamsFromLocation()['success'] != 'true' &&
        !_checkoutReturnHandled) {
      return;
    }
    if (licenses.isEmpty && _accountingPurchases.isEmpty) return;
    _licensePurchaseConfirmedLogged = true;
    Aptabase.instance.trackEvent('billing_license_purchase_confirmed', {
      'license_count': licenses.length,
      'accounting_purchase_count': _accountingPurchases.length,
    });
  }

  Future<void> _loadData({bool silent = false}) async {
    if (!mounted) return;
    if (!_hasReadBillingPermission(context)) return;
    final provider = context.read<BillingServiceClientProvider>();
    if (!silent || !_dataLoaded) {
      setState(() {
        _loading = true;
        _errorMessage = null;
        _dataLoaded = true;
      });
    }

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

      BillingProduct? syscohada;
      for (final p in products) {
        if (isSyscohadaBillingProduct(p.productId)) {
          syscohada = p;
          break;
        }
      }

      List<AccountingYearPurchase> accountingPurchases = const [];
      try {
        final accountingResponse = await provider.billingServiceClient
            .readAccountingYearPurchases(Empty());
        accountingPurchases = accountingResponse.purchases;
      } catch (_) {
        // Older servers may not expose this RPC yet.
      }

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
          _syscohadaProduct = syscohada;
          _accountingPurchases = accountingPurchases;
          _usersById = usersById;
          _loading = false;
          _errorMessage = null;
          _checkoutProductId = null;
        });
        _maybeTrackLicensePurchaseConfirmed(licenses);
      }
    } on GrpcError catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = e.message ?? 'An error occurred';
          _dataLoaded = false;
          _checkoutProductId = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = e.toString();
          _dataLoaded = false;
          _checkoutProductId = null;
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

  void _openSyscohadaTermsInNewTab() {
    Aptabase.instance.trackEvent('billing_syscohada_terms_opened', {});
    final path = RouteUri.legalCgvAccountingReportFr;
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

  void _onLicensePurchaseTapped(BillingProduct product) {
    Aptabase.instance.trackEvent('billing_license_purchase_clicked', {
      'product_id': product.productId,
    });
    _startPurchase(product, accepted: _acceptedEnterpriseTerms);
  }

  void _onSyscohadaPurchaseTapped() {
    final product = _syscohadaProduct;
    if (product == null) return;
    Aptabase.instance.trackEvent('billing_syscohada_purchase_clicked', {
      'product_id': product.productId,
      'fiscal_year': _syscohadaFiscalYear,
    });
    _startPurchase(product,
        fiscalYear: _syscohadaFiscalYear, accepted: _acceptedSyscohadaTerms);
  }

  Future<void> _syncFulfillAfterCheckoutReturn(Map<String, String> params) async {
    final provider = context.read<BillingServiceClientProvider>();
    final checkoutId = params['checkout_id'] ??
        html.window.sessionStorage['pawapay_checkout_id'];
    final isPawapay = params['provider'] == 'pawapay' ||
        (checkoutId != null &&
            checkoutId.isNotEmpty &&
            params['session_id'] == null);
    try {
      if (isPawapay && checkoutId != null && checkoutId.isNotEmpty) {
        await provider.billingServiceClient
            .fulfillFromPawapayCheckout(
          FulfillFromPawapayCheckoutRequest(
            checkoutId: checkoutId,
            legalTermsVersionDate: kEnterpriseTermsVersionId,
          ),
        )
            .timeout(const Duration(seconds: 20));
        html.window.sessionStorage.remove('pawapay_checkout_id');
        return;
      }
      final sessionId = params['session_id'];
      if (sessionId != null && sessionId.isNotEmpty) {
        await provider.billingServiceClient
            .fulfillFromStripeCheckoutSession(
          FulfillFromStripeCheckoutSessionRequest(
            checkoutSessionId: sessionId,
            legalTermsVersionDate: kEnterpriseTermsVersionId,
          ),
        )
            .timeout(const Duration(seconds: 20));
      }
    } catch (_) {
      // Idempotent: already fulfilled, not paid yet, or provider status lag.
      // loadData shows current state either way.
    }
  }

  Future<_BillingPaymentMethod?> _askPaymentMethod() {
    final lang = Lang.of(context);
    return showDialog<_BillingPaymentMethod>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang.billingChoosePaymentMethod),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: Text(lang.billingPayWithCard),
              onTap: () => Navigator.of(ctx).pop(_BillingPaymentMethod.stripe),
            ),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: Text(lang.billingPayWithMobileMoney),
              onTap: () => Navigator.of(ctx).pop(_BillingPaymentMethod.pawapay),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(lang.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _startPurchase(
    BillingProduct product, {
    int? fiscalYear,
    required bool accepted,
  }) async {
    if (!mounted) return;
    if (!_hasCreateBillingPermission(context)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Lang.of(context).billingActionNotPermitted)),
      );
      return;
    }
    if (!accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Lang.of(context).billingAcceptTermsToContinue)),
      );
      return;
    }
    final method = await _askPaymentMethod();
    if (method == null || !mounted) return;
    if (method == _BillingPaymentMethod.stripe) {
      await _purchaseWithStripe(product, fiscalYear: fiscalYear);
    } else {
      await _purchaseWithPawapay(product, fiscalYear: fiscalYear);
    }
  }

  Future<void> _purchaseWithStripe(
    BillingProduct product, {
    int? fiscalYear,
  }) async {
    final provider = context.read<BillingServiceClientProvider>();
    final stripePriceId = product.stripePriceId;
    if (stripePriceId.isEmpty) return;

    setState(() => _checkoutProductId = product.productId);

    try {
      final origin = html.window.location.origin;
      const billingPath = RouteUri.billing;
      final successUrl =
          '$origin/#$billingPath?success=true&session_id={CHECKOUT_SESSION_ID}';
      final cancelUrl = '$origin/#$billingPath?canceled=true';
      final request = CreateCheckoutSessionRequest(
        priceId: stripePriceId,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
        legalTermsVersionDate: kEnterpriseTermsVersionId,
        fiscalYear: fiscalYear,
      );

      final response =
          await provider.billingServiceClient.createCheckoutSession(request);

      if (!mounted) return;
      if (response.checkoutUrl.isEmpty) {
        Aptabase.instance.trackEvent('billing_license_checkout_failed', {
          'reason': 'empty_checkout_url',
          'product_id': product.productId,
          'provider': 'stripe',
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
        'provider': 'stripe',
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
        'provider': 'stripe',
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

  Future<void> _purchaseWithPawapay(
    BillingProduct product, {
    int? fiscalYear,
  }) async {
    final provider = context.read<BillingServiceClientProvider>();
    setState(() => _checkoutProductId = product.productId);

    try {
      final origin = html.window.location.origin;
      const billingPath = RouteUri.billing;
      final returnUrl =
          '$origin/#$billingPath?success=true&provider=pawapay';
      final request = CreatePawapayCheckoutRequest(
        productId: product.productId,
        returnUrl: returnUrl,
        legalTermsVersionDate: kEnterpriseTermsVersionId,
        fiscalYear: fiscalYear,
      );

      final response =
          await provider.billingServiceClient.createPawapayCheckout(request);

      if (!mounted) return;
      if (response.redirectUrl.isEmpty) {
        Aptabase.instance.trackEvent('billing_license_checkout_failed', {
          'reason': 'empty_redirect_url',
          'product_id': product.productId,
          'provider': 'pawapay',
        });
        setState(() {
          _checkoutProductId = null;
          _errorMessage = 'Checkout failed';
        });
        return;
      }
      if (response.checkoutId.isNotEmpty) {
        html.window.sessionStorage['pawapay_checkout_id'] = response.checkoutId;
      }
      html.window.location.href = response.redirectUrl;
    } on GrpcError catch (e) {
      Aptabase.instance.trackEvent('billing_license_checkout_failed', {
        'reason': 'pawapay_checkout_grpc',
        'product_id': product.productId,
        'provider': 'pawapay',
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
        'reason': 'pawapay_checkout_error',
        'product_id': product.productId,
        'provider': 'pawapay',
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

  Widget _buildOffersTab({
    required ThemeData themeData,
    required Lang lang,
    required bool canPurchase,
  }) {
    return ListView(
      padding: const EdgeInsets.all(kDefaultPadding),
      children: [
        if (_products.isNotEmpty)
          Wrap(
            spacing: kDefaultPadding,
            runSpacing: kDefaultPadding,
            children: _products
                .map((p) => _ProductOfferCard(
                      product: p,
                      onPurchase: () => _onLicensePurchaseTapped(p),
                      isLoading: _checkoutProductId == p.productId,
                      purchaseEnabled: canPurchase,
                      accepted: _acceptedEnterpriseTerms,
                      onAcceptedChanged: (v) =>
                          _setEnterpriseTermsAccepted(v ?? false),
                      onViewTerms: _openLegalDocumentInNewTab,
                      highlighted:
                          _bridgeHighlightProductId == p.productId.toLowerCase(),
                    ))
                .toList(),
          ),
        if (_products.isNotEmpty) const SizedBox(height: kDefaultPadding * 2),
        _SyscohadaAddonCard(
          product: _syscohadaProduct,
          purchasedYears: _accountingPurchases,
          selectedYear: _syscohadaFiscalYear,
          onYearChanged: (y) => setState(() => _syscohadaFiscalYear = y),
          onPurchase: _onSyscohadaPurchaseTapped,
          isLoading: _checkoutProductId == kSyscohadaProductId,
          purchaseEnabled: canPurchase,
          accepted: _acceptedSyscohadaTerms,
          onAcceptedChanged: (v) =>
              setState(() => _acceptedSyscohadaTerms = v ?? false),
          onViewTerms: _openSyscohadaTermsInNewTab,
          highlighted: _bridgeHighlightProductId == kSyscohadaProductId,
          showPurchasedYearsSummary: false,
        ),
      ],
    );
  }

  Widget _buildHistoryTab({
    required ThemeData themeData,
    required Lang lang,
    required bool canManageSeats,
    required int totalSeats,
  }) {
    final paidYears = _accountingPurchases.map((p) => p.year).toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(kDefaultPadding),
      children: [
        Text(
          '${lang.billingMyLicenses} ($totalSeats ${lang.billingLicenses})',
          style: themeData.textTheme.titleMedium,
        ),
        const SizedBox(height: kDefaultPadding),
        if (_licenses.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2),
            child: Text(
              lang.billingHistoryNoLicenses,
              style: themeData.textTheme.bodyMedium?.copyWith(
                color: themeData.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ..._licenses.map(
            (license) => _LicenseCard(
              license: license,
              usersById: _usersById,
              canManageSeats: canManageSeats,
              onAssignSeats: () => _showAssignSeatDialog(context, license),
              onReassignSeat: (userId) =>
                  _showReassignSeatDialog(context, license, userId),
            ),
          ),
        const SizedBox(height: kDefaultPadding * 2),
        const Divider(),
        const SizedBox(height: kDefaultPadding),
        Text(
          lang.billingSyscohadaPurchasedYears,
          style: themeData.textTheme.titleMedium,
        ),
        const SizedBox(height: kDefaultPadding),
        if (paidYears.isEmpty)
          Text(
            lang.billingHistoryNoSyscohadaYears,
            style: themeData.textTheme.bodyMedium?.copyWith(
              color: themeData.colorScheme.onSurfaceVariant,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: paidYears
                .map(
                  (y) => Chip(
                    label: Text('$y'),
                    avatar: const Icon(Icons.check_circle_outline, size: 18),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final appColorScheme = themeData.extension<AppColorScheme>()!;
    final lang = Lang.of(context);

    final currentUser = context.watch<CurrentUserProvider>();

    // Check permissions from both JWT and session (BFF mode)
    final hasPermission = _hasReadBillingPermission(context);

    if (hasPermission && !_dataLoaded && !_loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final params = billingQueryParamsFromLocation();
        _applyBridgeDeepLink(params);
        Aptabase.instance.trackEvent('billing_screen_opened', {});
        _bootstrapBilling(params);
      });
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
    final purchaseConfirmed =
        _licenses.isNotEmpty || _accountingPurchases.isNotEmpty;
    final returnedFromSuccess = !_loading &&
        (billingQueryParamsFromLocation()['success'] == 'true' ||
            _checkoutReturnHandled) &&
        purchaseConfirmed;
    final returnedStillProcessing = !_loading &&
        billingQueryParamsFromLocation()['success'] == 'true' &&
        !purchaseConfirmed;

    return PortalMasterLayout(
      key: const Key('billingScreen'),
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              lang.menuBilling,
              style: themeData.textTheme.headlineMedium,
            ),
            if (returnedFromSuccess || returnedStillProcessing) ...[
              Padding(
                padding: const EdgeInsets.only(top: kDefaultPadding),
                child: Material(
                  color: returnedFromSuccess
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
                              returnedFromSuccess
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.schedule_rounded,
                              color: returnedFromSuccess
                                  ? themeData.colorScheme.onPrimaryContainer
                                  : themeData.colorScheme.onSecondaryContainer,
                              size: 24,
                            ),
                            const SizedBox(width: kDefaultPadding),
                            Expanded(
                              child: Text(
                                returnedFromSuccess
                                    ? lang.billingPaymentSuccess
                                    : lang.billingPaymentProcessing,
                                style:
                                    themeData.textTheme.bodyMedium!.copyWith(
                                  color: returnedFromSuccess
                                      ? themeData.colorScheme.onPrimaryContainer
                                      : themeData
                                          .colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (returnedFromSuccess && _licenses.isNotEmpty)
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
              padding: const EdgeInsets.only(top: kDefaultPadding),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: themeData.colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: themeData.colorScheme.surface,
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: themeData.colorScheme.onSurface,
                  unselectedLabelColor: themeData.colorScheme.onSurfaceVariant,
                  labelStyle: themeData.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: themeData.textTheme.titleSmall,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: themeData.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: themeData.colorScheme.primary,
                    ),
                  ),
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: lang.billingTabOffers),
                    Tab(text: lang.billingTabHistory),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: kDefaultPadding),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: _loading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(kDefaultPadding * 2),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _errorMessage != null
                          ? CardBody(
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
                                    padding: const EdgeInsets.only(
                                        top: kDefaultPadding),
                                    child: TextButton.icon(
                                      onPressed: _loadData,
                                      icon: const Icon(Icons.refresh_rounded),
                                      label: Text(lang.billingRetry),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : TabBarView(
                              controller: _tabController,
                              children: [
                                _buildOffersTab(
                                  themeData: themeData,
                                  lang: lang,
                                  canPurchase: canPurchase,
                                ),
                                _buildHistoryTab(
                                  themeData: themeData,
                                  lang: lang,
                                  canManageSeats: canManageSeats,
                                  totalSeats: totalSeats,
                                ),
                              ],
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyscohadaAddonCard extends StatelessWidget {
  const _SyscohadaAddonCard({
    required this.product,
    required this.purchasedYears,
    required this.selectedYear,
    required this.onYearChanged,
    required this.onPurchase,
    required this.isLoading,
    required this.purchaseEnabled,
    required this.accepted,
    required this.onAcceptedChanged,
    required this.onViewTerms,
    this.highlighted = false,
    this.showPurchasedYearsSummary = true,
  });

  final BillingProduct? product;
  final List<AccountingYearPurchase> purchasedYears;
  final int selectedYear;
  final ValueChanged<int> onYearChanged;
  final VoidCallback onPurchase;
  final bool isLoading;
  final bool purchaseEnabled;
  final bool highlighted;
  final bool accepted;
  final ValueChanged<bool?> onAcceptedChanged;
  final VoidCallback onViewTerms;
  final bool showPurchasedYearsSummary;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final lang = Lang.of(context);
    final nowYear = DateTime.now().year;
    final yearOptions =
        List<int>.generate(nowYear - 2020 + 1, (i) => 2020 + i);
    final paidYears = purchasedYears.map((p) => p.year).toSet();
    final priceLabel = product == null
        ? lang.billingSyscohadaPrice
        : '${(product!.amountCents / 100).toStringAsFixed(2)} ${product!.currency.isNotEmpty ? product!.currency.toUpperCase() : 'EUR'}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(kDefaultPadding * 1.25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted
              ? themeData.colorScheme.primary
              : themeData.dividerColor.withValues(alpha: 0.6),
          width: highlighted ? 2 : 1,
        ),
        color: themeData.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.billingSyscohadaTitle,
            style: themeData.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lang.billingSyscohadaSubtitle,
            style: themeData.textTheme.bodyMedium,
          ),
          const SizedBox(height: kDefaultPadding),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                priceLabel,
                style: themeData.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                lang.billingSyscohadaPerReport,
                style: themeData.textTheme.bodyMedium?.copyWith(
                  color: themeData.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (showPurchasedYearsSummary && paidYears.isNotEmpty) ...[
            const SizedBox(height: kDefaultPadding),
            Text(
              '${lang.billingSyscohadaPurchasedYears}: ${paidYears.toList()..sort()}',
              style: themeData.textTheme.bodySmall,
            ),
          ],
          if (product != null) ...[
            const SizedBox(height: kDefaultPadding),
            Text(lang.billingSyscohadaSelectYear),
            const SizedBox(height: 8),
            DropdownButton<int>(
              value: selectedYear,
              items: yearOptions
                  .map(
                    (y) => DropdownMenuItem(
                      value: y,
                      child: Text(
                        paidYears.contains(y) ? '$y ✓' : '$y',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: isLoading
                  ? null
                  : (y) {
                      if (y != null) onYearChanged(y);
                    },
            ),
            if (selectedYear == nowYear) ...[
              const SizedBox(height: 8),
              Text(
                lang.billingSyscohadaCurrentYearDisclaimer,
                style: themeData.textTheme.bodySmall?.copyWith(
                  color: themeData.colorScheme.error,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: kDefaultPadding),
            // CGV Block for SYSCOHADA
            TextButton(
              onPressed: onViewTerms,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                lang.billingViewFullTerms, // Placeholder or specific label if exists
                style: TextStyle(
                  color: themeData.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: accepted,
                    onChanged: onAcceptedChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onAcceptedChanged(!accepted),
                    child: Text(
                      lang.billingAcceptAccountingReportTerms,
                      style: themeData.textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: kDefaultPadding),
            FilledButton(
              onPressed: (!purchaseEnabled ||
                      isLoading ||
                      !accepted ||
                      paidYears.contains(selectedYear))
                  ? null
                  : onPurchase,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(lang.billingSyscohadaPurchase),
            ),
          ],
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
  final bool highlighted;
  final bool accepted;
  final ValueChanged<bool?> onAcceptedChanged;
  final VoidCallback onViewTerms;

  const _ProductOfferCard({
    required this.product,
    required this.onPurchase,
    required this.isLoading,
    required this.purchaseEnabled,
    required this.accepted,
    required this.onAcceptedChanged,
    required this.onViewTerms,
    this.highlighted = false,
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
      width: double.infinity,
      child: Card(
        elevation: highlighted ? style.elevation + 2 : style.elevation,
        color: style.background,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: highlighted
              ? BorderSide(color: themeData.colorScheme.primary, width: 2)
              : BorderSide.none,
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
              if (product.productId.toLowerCase() == 'premium') ...[
                const SizedBox(height: 12),
                Text(
                  lang.billingPurchaseLicenseDescription,
                  style: themeData.textTheme.bodyMedium?.copyWith(
                    color: style.onBackground.withValues(alpha: 0.85),
                  ),
                ),
              ],
              const SizedBox(height: kDefaultPadding),
              // CGV Block
              TextButton(
                onPressed: onViewTerms,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  lang.billingViewFullTerms,
                  style: TextStyle(
                    color: style.onBackground,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: accepted,
                      onChanged: onAcceptedChanged,
                      side: BorderSide(color: style.onBackground),
                      checkColor: style.background,
                      activeColor: style.onBackground,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onAcceptedChanged(!accepted),
                      child: Text(
                        lang.billingAcceptEnterpriseTerms,
                        style: themeData.textTheme.bodySmall?.copyWith(
                          color: style.onBackground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kDefaultPadding * 1.25),
              SizedBox(
                width: 200, // Keep button at reasonable width even if card is full width
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
                      (isLoading || !purchaseEnabled || !accepted) ? null : onPurchase,
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

enum _BillingPaymentMethod { stripe, pawapay }
