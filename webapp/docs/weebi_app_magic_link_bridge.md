# weebi_app follow-up: App → Web magic-link bridge

Server + webapp now support a short-lived magic link that opens the portal
already logged in (BFF cookie via Envoy) on the right billing product.

This document is what remains to do in the **mobile PoS** (`weebi` / `weebi_app`).

## Prerequisites

1. Publish `protos_weebi` containing:
   - `FenceService.createWebBridgeLink`
   - `FenceService.exchangeWebBridgeToken`
2. Bump the app dependency to that published version.
3. **Do not** ship the app with a `path:` override for `protos_weebi`.
4. Deployed server must set `WEBAPP_BASE_URL` (portal origin, e.g. `https://…`).
5. User must already be authenticated with the **mobile JWT** and have
   **billing create** rights.

## Supported products

| `productId` | When to open | Request fields |
|---|---|---|
| `premium` | Upsell / license gate for Weebi Premium | `productId: "premium"` |
| `syscohada` | SMT / SYSCOHADA clôture when fiscal year unpaid | `productId: "syscohada"`, `fiscalYear: <year>` |

## Client steps (both products)

```dart
final resp = await fenceClient.createWebBridgeLink(
  CreateWebBridgeLinkRequest(
    productId: 'premium', // or 'syscohada'
    fiscalYear: year,     // required for syscohada only
    // returnDeepLink: 'weebi://billing/success', // later
  ),
  options: CallOptions(metadata: {'authorization': mobileJwt}),
);

await launchUrl(
  Uri.parse(resp.url),
  mode: LaunchMode.externalApplication, // system browser, not WebView
);
```

Reuse existing helpers such as `launchUrlAndBeCool` / `url_launcher` in weebi_app.

## Suggested UI entry points

1. **Premium** — license / access / entitlement screens that today tell the
   merchant to buy Premium on the web.
2. **SYSCOHADA** — SMT report / clôture flow (`SmtReportView` and related)
   when export/clôture requires a paid fiscal year.

While the browser is open, keep a calm “waiting for payment” state and let the
user pull-to-refresh (or auto-poll) licenses /
`readAccountingYearPurchases` after they return.

## What the webapp already does

1. Opens `/?t=…&product=premium#/bridge` (or with `year=Y` for syscohada).
   Query params are **before** the hash so OS/`url_launcher` handoff keeps the
   token; the webapp also still accepts the older `/#/bridge?t=…` shape.
2. Calls `exchangeWebBridgeToken` → Envoy sets `weebi_session_id`.
3. Redirects to `/#/billing?product=…` (and `year` for syscohada).
4. Highlights the matching card; **terms still required** before Stripe checkout.
5. Existing Stripe success path remains `#/billing?success=true&session_id=…`.

## Future: deep-link return (not v1)

- Pass `returnDeepLink` from the app (e.g. `weebi://billing/success`).
- After successful payment, web success page should open that link so the
  browser closes and the app resumes on the paid PDF / license state.
- Requires Android App Links / iOS custom URL scheme work; manifests today only
  expose generic `https` / `tel` / `sms`.

## Acceptance checks

- [ ] Premium: system browser opens portal logged in with Premium card highlighted.
- [ ] SYSCOHADA: same with year preselected.
- [ ] Expired / replayed link shows an error on `/bridge` (no session).
- [ ] Closing the browser without paying leaves mobile entitlements unchanged.
- [ ] Shipped app uses published `protos_weebi` only (no path override).
