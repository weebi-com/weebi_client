import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/core/billing/billing_rpc.dart';

/// In-memory billing RPC for widget / unit tests.
class FakeBillingRpc implements BillingRpc {
  FakeBillingRpc({
    this.licenses = const [],
    this.products = const [],
    this.accountingPurchases = const [],
    this.referralCode = 'firm-buyer-001',
    this.creditBalanceCents = 0,
    this.checkoutUrl = 'https://checkout.stripe.test/session',
    this.pawapayRedirectUrl = 'https://pay.pawapay.test/c/1',
  });

  List<License> licenses;
  List<BillingProduct> products;
  List<AccountingYearPurchase> accountingPurchases;
  String referralCode;
  int creditBalanceCents;
  String checkoutUrl;
  String pawapayRedirectUrl;

  final List<CreateCheckoutSessionRequest> createCheckoutCalls = [];
  final List<CreatePawapayCheckoutRequest> createPawapayCalls = [];

  @override
  Future<ReadLicensesResponse> readLicenses(Empty request) async =>
      ReadLicensesResponse()..licenses.addAll(licenses);

  @override
  Future<ReadBillingProductsResponse> readBillingProducts(Empty request) async =>
      ReadBillingProductsResponse()..products.addAll(products);

  @override
  Future<ReadAccountingYearPurchasesResponse> readAccountingYearPurchases(
    Empty request,
  ) async =>
      ReadAccountingYearPurchasesResponse()
        ..purchases.addAll(accountingPurchases);

  @override
  Future<GetReferralInfoResponse> getReferralInfo(Empty request) async =>
      GetReferralInfoResponse()
        ..referralCode = referralCode
        ..creditBalanceCents = creditBalanceCents
        ..minPayoutCents = 1500;

  @override
  Future<CreateCheckoutSessionResponse> createCheckoutSession(
    CreateCheckoutSessionRequest request,
  ) async {
    createCheckoutCalls.add(request);
    return CreateCheckoutSessionResponse()..checkoutUrl = checkoutUrl;
  }

  @override
  Future<CreatePawapayCheckoutResponse> createPawapayCheckout(
    CreatePawapayCheckoutRequest request,
  ) async {
    createPawapayCalls.add(request);
    return CreatePawapayCheckoutResponse()
      ..checkoutId = 'chk-fake-1'
      ..redirectUrl = pawapayRedirectUrl;
  }

  @override
  Future<CreateLicenseResponse> fulfillFromStripeCheckoutSession(
    FulfillFromStripeCheckoutSessionRequest request,
  ) async =>
      CreateLicenseResponse();

  @override
  Future<CreateLicenseResponse> fulfillFromPawapayCheckout(
    FulfillFromPawapayCheckoutRequest request,
  ) async =>
      CreateLicenseResponse();

  @override
  Future<StatusResponse> updateLicense(UpdateLicenseRequest request) async =>
      StatusResponse();
}
