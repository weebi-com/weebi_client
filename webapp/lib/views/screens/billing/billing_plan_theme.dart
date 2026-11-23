import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

/// Visual identity for license plans on billing screens (Premium + legacy Entreprise).
class BillingPlanVisual {
  const BillingPlanVisual({
    required this.background,
    required this.onBackground,
    required this.priceColor,
    required this.mutedOnBackground,
    required this.buttonBackground,
    required this.buttonForeground,
    this.elevation = 4,
  });

  final Color background;
  final Color onBackground;
  final Color priceColor;
  final Color mutedOnBackground;
  final Color buttonBackground;
  final Color buttonForeground;
  final double elevation;

  /// Indigo — Weebi Entreprise.
  static const entreprise = BillingPlanVisual(
    background: Color(0xFF3F51B5),
    onBackground: Colors.white,
    priceColor: Color(0xFFE8EAF6),
    mutedOnBackground: Color(0xFFC5CAE9),
    buttonBackground: Colors.white,
    buttonForeground: Color(0xFF303F9F),
    elevation: 3,
  );

  /// Deep navy with gold typography — Weebi Premium.
  static const premium = BillingPlanVisual(
    background: Color(0xFF0A1628),
    onBackground: Color(0xFFD4AF37),
    priceColor: Color(0xFFF0D78C),
    mutedOnBackground: Color(0xFFB8A066),
    buttonBackground: Color(0xFFD4AF37),
    buttonForeground: Color(0xFF0A1628),
    elevation: 6,
  );

  static BillingPlanVisual fromProductId(String productId) {
    if (productId.toLowerCase() == 'premium') return premium;
    return entreprise;
  }

  static BillingPlanVisual fromLicensePlan(LicensePlan plan) {
    if (plan == LicensePlan.PREMIUM) return premium;
    return entreprise;
  }
}

/// Opaque count pill for plan headers. Avoids [Chip]: its Material canvas is
/// the theme surface, so translucent gold/white ink reads as yellow-on-white.
class BillingPlanCountBadge extends StatelessWidget {
  const BillingPlanCountBadge({
    super.key,
    required this.label,
    required this.style,
  });

  final String label;
  final BillingPlanVisual style;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.buttonBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: style.buttonForeground,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
