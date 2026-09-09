import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:provider/provider.dart';
import 'package:web_admin/core/billing/billing_rpc.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/views/screens/billing/billing_referral_section.dart';

import '../helpers/fake_billing_rpc.dart';
import '../helpers/l10n_app.dart';

/// Minimal purchase surface sharing production referral helpers + [BillingRpc].
class _ReferralCheckoutHarness extends StatefulWidget {
  const _ReferralCheckoutHarness({
    required this.ownReferralCode,
    required this.product,
  });

  final String ownReferralCode;
  final BillingProduct product;

  @override
  State<_ReferralCheckoutHarness> createState() =>
      _ReferralCheckoutHarnessState();
}

class _ReferralCheckoutHarnessState extends State<_ReferralCheckoutHarness> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pay(bool stripe) async {
    final lang = Lang.of(context);
    final entered = _controller.text;
    if (isSelfReferralCode(
      entered: entered,
      ownReferralCode: widget.ownReferralCode,
    )) {
      setState(() => _error = lang.billingReferralSelfError);
      return;
    }
    setState(() => _error = null);
    final code = referralCodeForCheckout(
      entered: entered,
      ownReferralCode: widget.ownReferralCode,
    );
    final rpc = context.read<BillingRpc>();
    if (stripe) {
      await rpc.createCheckoutSession(
        CreateCheckoutSessionRequest(
          priceId: widget.product.stripePriceId,
          successUrl: 'https://ok',
          cancelUrl: 'https://cancel',
          legalTermsVersionDate: '2026-05-01',
          referralCode: code ?? '',
        ),
      );
    } else {
      await rpc.createPawapayCheckout(
        CreatePawapayCheckoutRequest(
          productId: widget.product.productId,
          returnUrl: 'https://ok',
          legalTermsVersionDate: '2026-05-01',
          referralCode: code ?? '',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showDiscount = referralCodeForCheckout(
          entered: _controller.text,
          ownReferralCode: widget.ownReferralCode,
        ) !=
        null;

    return Scaffold(
      key: const Key('billingScreen'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BillingReferralSection(
            controller: _controller,
            ownReferralCode: widget.ownReferralCode,
            creditBalanceCents: 250,
            errorText: _error,
            onChanged: (value) {
              final lang = Lang.of(context);
              setState(() {
                _error = isSelfReferralCode(
                  entered: value,
                  ownReferralCode: widget.ownReferralCode,
                )
                    ? lang.billingReferralSelfError
                    : null;
              });
            },
          ),
          if (showDiscount)
            Text(
              Lang.of(context).billingReferralDiscountedPrice(
                '€${(referralBuyerChargeCents(widget.product.amountCents) / 100).toStringAsFixed(2)}',
              ),
            ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('billingPayStripe'),
            onPressed: () => _pay(true),
            child: Text(Lang.of(context).billingPayWithCard),
          ),
          FilledButton(
            key: const Key('billingPayPawapay'),
            onPressed: () => _pay(false),
            child: Text(Lang.of(context).billingPayWithMobileMoney),
          ),
        ],
      ),
    );
  }
}

BillingProduct _premium() => BillingProduct(
      productId: 'premium',
      stripePriceId: 'price_premium',
      amountCents: 1400,
      currency: 'eur',
      maxUsers: 1,
      licensePlan: LicensePlan.PREMIUM,
    );

void main() {
  const ownFirmId = 'firm-buyer-001';
  const referrerFirmId = 'referrer-firm-999';

  testWidgets('referral section shows own code and copy control', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      l10nApp(
        home: Scaffold(
          body: BillingReferralSection(
            controller: controller,
            ownReferralCode: ownFirmId,
            creditBalanceCents: 250,
            errorText: null,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('billingReferralTextField')), findsOneWidget);
    expect(find.byKey(const Key('billingOwnReferralCode')), findsOneWidget);
    expect(find.byKey(const Key('billingCopyReferralCode')), findsOneWidget);
    expect(find.textContaining(ownFirmId), findsOneWidget);
    expect(find.textContaining('2.50'), findsOneWidget);
  });

  testWidgets('self-referral blocks checkout; valid code is sent to Stripe/Pawapay',
      (tester) async {
    final rpc = FakeBillingRpc(referralCode: ownFirmId);

    await tester.pumpWidget(
      l10nApp(
        home: Provider<BillingRpc>.value(
          value: rpc,
          child: _ReferralCheckoutHarness(
            ownReferralCode: ownFirmId,
            product: _premium(),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('billingReferralTextField')),
      ownFirmId,
    );
    await tester.pumpAndSettle();
    expect(find.text(Lang.current.billingReferralSelfError), findsOneWidget);

    await tester.tap(find.byKey(const Key('billingPayStripe')));
    await tester.pumpAndSettle();
    expect(rpc.createCheckoutCalls, isEmpty);

    await tester.enterText(
      find.byKey(const Key('billingReferralTextField')),
      referrerFirmId,
    );
    await tester.pumpAndSettle();
    expect(find.text(Lang.current.billingReferralSelfError), findsNothing);
    expect(find.textContaining('Avec parrainage :'), findsOneWidget);

    await tester.tap(find.byKey(const Key('billingPayStripe')));
    await tester.pumpAndSettle();
    expect(rpc.createCheckoutCalls, hasLength(1));
    expect(rpc.createCheckoutCalls.single.referralCode, referrerFirmId);
    expect(rpc.createCheckoutCalls.single.priceId, 'price_premium');

    await tester.tap(find.byKey(const Key('billingPayPawapay')));
    await tester.pumpAndSettle();
    expect(rpc.createPawapayCalls, hasLength(1));
    expect(rpc.createPawapayCalls.single.referralCode, referrerFirmId);
  });

  test('referralCodeForCheckout helpers', () {
    expect(
      referralCodeForCheckout(entered: '', ownReferralCode: ownFirmId),
      isNull,
    );
    expect(
      referralCodeForCheckout(entered: ownFirmId, ownReferralCode: ownFirmId),
      isNull,
    );
    expect(
      referralCodeForCheckout(
        entered: referrerFirmId,
        ownReferralCode: ownFirmId,
      ),
      referrerFirmId,
    );
    expect(referralBuyerChargeCents(1400), 1260);
  });
}
