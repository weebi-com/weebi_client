import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/views/screens/billing/billing_offers_gallery.dart';
import 'package:web_admin/views/screens/billing/billing_referral_section.dart';

import '../helpers/l10n_app.dart';

BillingProduct _premiumProduct() => BillingProduct(
      productId: 'premium',
      stripePriceId: 'price_premium',
      amountCents: 1400,
      currency: 'eur',
      maxUsers: 1,
      licensePlan: LicensePlan.PREMIUM,
    );

BillingProduct _syscohadaProduct() => BillingProduct(
      productId: 'syscohada',
      stripePriceId: 'price_syscohada',
      amountCents: 290,
      currency: 'eur',
    );

/// Mirrors Offres tab navigation (gallery vs dedicated view + Retour).
class _OffersFlow extends StatefulWidget {
  const _OffersFlow({
    required this.ownReferralCode,
    required this.premium,
    required this.syscohada,
  });

  final String ownReferralCode;
  final BillingProduct premium;
  final BillingProduct syscohada;

  @override
  State<_OffersFlow> createState() => _OffersFlowState();
}

class _OffersFlowState extends State<_OffersFlow> {
  String? _offerDetail;
  final _premiumReferralController = TextEditingController();

  @override
  void dispose() {
    _premiumReferralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    if (_offerDetail == 'referral') {
      return ListView(
        children: [
          TextButton.icon(
            key: const Key('billingOffersBack'),
            onPressed: () => setState(() => _offerDetail = null),
            icon: const Icon(Icons.arrow_back),
            label: Text(lang.billingOffersBack),
          ),
          BillingReferralSection(
            ownReferralCode: widget.ownReferralCode,
            creditBalanceCents: 400,
          ),
        ],
      );
    }
    if (_offerDetail == 'premium') {
      return ListView(
        children: [
          TextButton.icon(
            key: const Key('billingOffersBack'),
            onPressed: () {
              _premiumReferralController.clear();
              setState(() => _offerDetail = null);
            },
            icon: const Icon(Icons.arrow_back),
            label: Text(lang.billingOffersBack),
          ),
          BillingReferrerCodeField(
            controller: _premiumReferralController,
            errorText: null,
            onChanged: (_) {},
          ),
        ],
      );
    }
    return BillingOffersGallery(
      ownReferralCode: widget.ownReferralCode,
      syscohadaProduct: widget.syscohada,
      premiumProduct: widget.premium,
      pawapayCurrency: 'XOF',
      onOpenReferral: () => setState(() => _offerDetail = 'referral'),
      onOpenSyscohada: () => setState(() => _offerDetail = 'syscohada'),
      onOpenPremium: () => setState(() => _offerDetail = 'premium'),
    );
  }
}

Future<void> _pumpOffers(
  WidgetTester tester, {
  Size surface = const Size(1200, 900),
  String ownCode = 'firm-buyer-001',
}) async {
  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    l10nApp(
      home: Scaffold(
        body: _OffersFlow(
          ownReferralCode: ownCode,
          premium: _premiumProduct(),
          syscohada: _syscohadaProduct(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Offres gallery shows tiles, prices, and a copyable referral code',
      (tester) async {
    await _pumpOffers(tester);

    expect(find.byKey(const Key('billingOfferTeaserReferral')), findsOneWidget);
    expect(find.byKey(const Key('billingOfferTeaserSyscohada')), findsOneWidget);
    expect(find.byKey(const Key('billingOfferTeaserPremium')), findsOneWidget);

    for (final key in [
      'billingOfferTeaserReferral',
      'billingOfferTeaserSyscohada',
      'billingOfferTeaserPremium',
    ]) {
      final size = tester.getSize(find.byKey(Key(key)));
      expect(size.height, greaterThan(80), reason: '$key must not collapse');
      expect(size.width, greaterThan(80), reason: '$key must not collapse');
    }

    final referralH =
        tester.getSize(find.byKey(const Key('billingOfferTeaserReferral'))).height;
    final syscohadaH =
        tester.getSize(find.byKey(const Key('billingOfferTeaserSyscohada'))).height;
    final premiumH =
        tester.getSize(find.byKey(const Key('billingOfferTeaserPremium'))).height;
    expect(referralH, closeTo(syscohadaH, 1));
    expect(syscohadaH, closeTo(premiumH, 1));

    expect(find.text('En savoir plus'), findsOneWidget);
    expect(find.text('Voir'), findsNWidgets(2));
    expect(find.textContaining('Rapport comptable'), findsOneWidget);
    final ctaBottom = tester.getBottomLeft(find.text('En savoir plus')).dy;
    expect(tester.getBottomLeft(find.text('Voir').at(0)).dy, closeTo(ctaBottom, 2));
    expect(tester.getBottomLeft(find.text('Voir').at(1)).dy, closeTo(ctaBottom, 2));

    expect(find.byKey(const Key('billingOwnReferralCode')), findsOneWidget);
    expect(find.byKey(const Key('billingCopyReferralCode')), findsOneWidget);
    expect(find.textContaining('firm-buyer-001'), findsOneWidget);
    expect(find.textContaining('14.00'), findsOneWidget);
    expect(find.textContaining('2.90'), findsOneWidget);
  });

  testWidgets('Offres tiles stay visible on a narrow viewport', (tester) async {
    await _pumpOffers(tester, surface: const Size(400, 900));

    expect(find.byKey(const Key('billingOfferTeaserReferral')), findsOneWidget);
    expect(find.byKey(const Key('billingOfferTeaserSyscohada')), findsOneWidget);
    expect(find.byKey(const Key('billingOfferTeaserPremium')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('billingOfferTeaserReferral'))).height,
      greaterThan(80),
    );
  });

  testWidgets('opening Premium then Retour restores the gallery', (tester) async {
    await _pumpOffers(tester);

    await tester.tap(find.byKey(const Key('billingOfferTeaserPremium')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('billingOffersBack')), findsOneWidget);
    expect(find.byKey(const Key('billingReferralTextField')), findsOneWidget);
    expect(find.byKey(const Key('billingOfferTeaserPremium')), findsNothing);

    await tester.tap(find.byKey(const Key('billingOffersBack')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('billingOfferTeaserReferral')), findsOneWidget);
    expect(find.byKey(const Key('billingOfferTeaserSyscohada')), findsOneWidget);
    expect(find.byKey(const Key('billingOfferTeaserPremium')), findsOneWidget);
    expect(find.byKey(const Key('billingReferralTextField')), findsNothing);
  });

  testWidgets('opening Parrainage then Retour restores the gallery',
      (tester) async {
    await _pumpOffers(tester);

    await tester.tap(find.text('En savoir plus'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('billingOffersBack')), findsOneWidget);
    expect(find.text('Parrainage'), findsWidgets);

    await tester.tap(find.byKey(const Key('billingOffersBack')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('billingOfferTeaserPremium')), findsOneWidget);
  });
}
