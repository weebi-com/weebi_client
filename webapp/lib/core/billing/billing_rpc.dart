import 'package:protos_weebi/protos_weebi_io.dart';

/// Thin billing API used by the webapp UI (production = gRPC, tests = fake).
abstract class BillingRpc {
  Future<ReadLicensesResponse> readLicenses(Empty request);
  Future<ReadBillingProductsResponse> readBillingProducts(Empty request);
  Future<ReadAccountingYearPurchasesResponse> readAccountingYearPurchases(
    Empty request,
  );
  Future<GetReferralInfoResponse> getReferralInfo(Empty request);
  Future<CreateCheckoutSessionResponse> createCheckoutSession(
    CreateCheckoutSessionRequest request,
  );
  Future<CreatePawapayCheckoutResponse> createPawapayCheckout(
    CreatePawapayCheckoutRequest request,
  );
  Future<CreateLicenseResponse> fulfillFromStripeCheckoutSession(
    FulfillFromStripeCheckoutSessionRequest request,
  );
  Future<CreateLicenseResponse> fulfillFromPawapayCheckout(
    FulfillFromPawapayCheckoutRequest request,
  );
  Future<StatusResponse> updateLicense(UpdateLicenseRequest request);
}

/// Production adapter over generated [BillingServiceClient].
class GrpcBillingRpc implements BillingRpc {
  GrpcBillingRpc(this._client);

  final BillingServiceClient _client;

  @override
  Future<ReadLicensesResponse> readLicenses(Empty request) =>
      _client.readLicenses(request);

  @override
  Future<ReadBillingProductsResponse> readBillingProducts(Empty request) =>
      _client.readBillingProducts(request);

  @override
  Future<ReadAccountingYearPurchasesResponse> readAccountingYearPurchases(
    Empty request,
  ) =>
      _client.readAccountingYearPurchases(request);

  @override
  Future<GetReferralInfoResponse> getReferralInfo(Empty request) =>
      _client.getReferralInfo(request);

  @override
  Future<CreateCheckoutSessionResponse> createCheckoutSession(
    CreateCheckoutSessionRequest request,
  ) =>
      _client.createCheckoutSession(request);

  @override
  Future<CreatePawapayCheckoutResponse> createPawapayCheckout(
    CreatePawapayCheckoutRequest request,
  ) =>
      _client.createPawapayCheckout(request);

  @override
  Future<CreateLicenseResponse> fulfillFromStripeCheckoutSession(
    FulfillFromStripeCheckoutSessionRequest request,
  ) =>
      _client.fulfillFromStripeCheckoutSession(request);

  @override
  Future<CreateLicenseResponse> fulfillFromPawapayCheckout(
    FulfillFromPawapayCheckoutRequest request,
  ) =>
      _client.fulfillFromPawapayCheckout(request);

  @override
  Future<StatusResponse> updateLicense(UpdateLicenseRequest request) =>
      _client.updateLicense(request);
}
