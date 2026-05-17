# entitlements_weebi

Licence validity, portal capabilities, and shared licence UI for Weebi client packages.

**Commercial model (read first):** [../../docs/commercial-model.md](../../docs/commercial-model.md) — lifetime licences, **no subscriptions**, credits for consumption only.

This package is **not** billing: it does not call `BillingService`, Stripe, checkout, or credit balances. Host apps (e.g. `webapp`) load firm licences via gRPC and pass `Iterable<License>?` into feature screens.

## Concepts

| Concept | Meaning |
|--------|---------|
| **Licence** | Lifetime firm entitlement; attributed to a user via `LicenseSeat` in protos (code may say “seat”; UI says “licence”). |
| **Valid window** | `validFrom` / `validUntil` enforce server state; **not** subscription expiry — see commercial model doc. |
| **Firm-creator joker** | Narrow operational preview without a licence — not a subscription. |
| **SeatCapability** | Portal UI features that require an attributed licence (no joker), e.g. ticket boutique filters, business rules edit. |

## Usage

```dart
import 'package:entitlements_weebi/entitlements_weebi.dart';

final canFilterTickets = SeatCapability.ticketsBoutiqueViewsUnlocked(userId, licenses);
final canEditRules = SeatCapability.businessRulesEditable(userId, licenses);
```

## Dependencies

- `protos_weebi` — `License`, `LicenseSeat`, `UserPermissions`
