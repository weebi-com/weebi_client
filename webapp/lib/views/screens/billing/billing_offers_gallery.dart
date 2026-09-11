import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/views/screens/billing/billing_plan_label.dart';
import 'package:web_admin/views/screens/billing/billing_plan_theme.dart';
import 'package:web_admin/views/screens/billing/billing_referral_section.dart';

/// Offres teaser grid (Parrainage, SYSCOHADA, Premium).
///
/// Kept independent of gRPC/web so widget tests can run on the VM.
class BillingOffersGallery extends StatelessWidget {
  const BillingOffersGallery({
    super.key,
    required this.ownReferralCode,
    required this.syscohadaProduct,
    required this.premiumProduct,
    required this.pawapayCurrency,
    required this.onOpenReferral,
    required this.onOpenSyscohada,
    required this.onOpenPremium,
  });

  final String? ownReferralCode;
  final BillingProduct? syscohadaProduct;
  final BillingProduct? premiumProduct;
  final String pawapayCurrency;
  final VoidCallback onOpenReferral;
  final VoidCallback onOpenSyscohada;
  final VoidCallback onOpenPremium;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final lang = Lang.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final hasOwnCode =
        ownReferralCode != null && ownReferralCode!.isNotEmpty;
    final syscohadaPrice = syscohadaProduct == null
        ? lang.billingSyscohadaPrice
        : formatBillingOfferPrice(
            amountCents: syscohadaProduct!.amountCents,
            currency: syscohadaProduct!.currency,
            productId: syscohadaProduct!.productId,
            languageCode: languageCode,
            pawapayCurrency: pawapayCurrency,
            product: syscohadaProduct,
          );
    final premiumPrice = premiumProduct == null
        ? null
        : formatBillingOfferPrice(
            amountCents: premiumProduct!.amountCents,
            currency: premiumProduct!.currency,
            productId: premiumProduct!.productId,
            languageCode: languageCode,
            pawapayCurrency: pawapayCurrency,
            product: premiumProduct,
          );

    final tiles = <Widget>[
      BillingOfferTeaserCard(
        key: const Key('billingOfferTeaserReferral'),
        title: lang.billingReferralTitle,
        lead: lang.billingGalleryReferralLead,
        cta: lang.billingGalleryLearnMore,
        onTap: onOpenReferral,
        extra: hasOwnCode
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.billingReferralYourCode,
                    style: themeData.textTheme.bodySmall?.copyWith(
                      color: themeData.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  BillingOwnReferralCodeCopy(code: ownReferralCode!),
                ],
              )
            : null,
      ),
      BillingOfferTeaserCard(
        key: const Key('billingOfferTeaserSyscohada'),
        title: lang.billingSyscohadaTitle,
        lead: lang.billingGallerySyscohadaLead,
        cta: lang.billingGalleryOpen,
        price: syscohadaPrice,
        onTap: onOpenSyscohada,
      ),
      if (premiumProduct != null)
        BillingOfferTeaserCard(
          key: const Key('billingOfferTeaserPremium'),
          title: lang.billingPlanPremium,
          lead: lang.billingGalleryPremiumLead,
          cta: lang.billingGalleryOpen,
          price: premiumPrice,
          priceCaption: lang.billingPerUser,
          onTap: onOpenPremium,
          visual: BillingPlanVisual.premium,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            equalHeightOfferTiles(
              tiles: tiles,
              maxWidth: width,
            ),
          ],
        );
      },
    );
  }
}

/// Visible for tests: same-height offer row layout used by [BillingOffersGallery].
Widget equalHeightOfferTiles({
  required List<Widget> tiles,
  required double maxWidth,
}) {
  const minTileWidth = 280.0;
  final spacing = kDefaultPadding;
  var columns = 1;
  if (maxWidth >= minTileWidth * 3 + spacing * 2) {
    columns = 3;
  } else if (maxWidth >= minTileWidth * 2 + spacing) {
    columns = 2;
  }

  if (columns == 1) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) SizedBox(height: spacing),
          tiles[i],
        ],
      ],
    );
  }

  Widget row(List<Widget> slice) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var j = 0; j < columns; j++) ...[
            if (j > 0) SizedBox(width: spacing),
            Expanded(
              child: j < slice.length ? slice[j] : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < tiles.length; i += columns) ...[
        if (i > 0) SizedBox(height: spacing),
        row(
          tiles.sublist(
            i,
            i + columns > tiles.length ? tiles.length : i + columns,
          ),
        ),
      ],
    ],
  );
}

class BillingOfferTeaserCard extends StatelessWidget {
  const BillingOfferTeaserCard({
    super.key,
    required this.title,
    required this.lead,
    required this.cta,
    required this.onTap,
    this.visual,
    this.price,
    this.priceCaption,
    this.extra,
  });

  final String title;
  final String lead;
  final String cta;
  final VoidCallback onTap;
  final BillingPlanVisual? visual;
  final String? price;
  final String? priceCaption;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final style = visual;
    final muted =
        style?.mutedOnBackground ?? themeData.colorScheme.onSurfaceVariant;
    final onBg = style?.onBackground;

    return SizedBox(
      height: 292,
      width: double.infinity,
      child: Material(
        color: style?.background ??
            themeData.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(kDefaultPadding * 1.25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: themeData.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: onBg,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lead,
                  style: themeData.textTheme.bodyMedium?.copyWith(
                    color: muted,
                    height: 1.35,
                  ),
                ),
                if (price != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    price!,
                    style: themeData.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: style?.priceColor ?? onBg,
                    ),
                  ),
                  if (priceCaption != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        priceCaption!,
                        style: themeData.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ),
                ],
                if (extra != null) ...[
                  const SizedBox(height: 12),
                  extra!,
                ],
                const Spacer(),
                Text(
                  cta,
                  style: themeData.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: style?.priceColor ?? themeData.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
