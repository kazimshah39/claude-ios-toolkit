---
name: ios-iap-review-information
description: Generate copy-ready App Store Connect Review Notes for monthly, yearly, and lifetime iOS in-app purchases
trigger: /ios-iap-review-information
---

# /ios-iap-review-information

Generate copy-ready App Store Connect **Review Notes** for in-app purchases.

Use this when the user needs text for the App Store Connect field:

```text
Review Notes
Additional information about your in-app purchase that could help us with our review.
```

This skill must output the notes directly in chat so the user can copy and paste them. Do not give screenshot advice. Do not implement StoreKit code; use `/ios-subscription-system` for purchase-system implementation or audit.

## Required behavior

Always provide separate Review Notes blocks for the common product set:

1. Monthly auto-renewable subscription.
2. Yearly auto-renewable subscription.
3. Lifetime non-consumable purchase.

Each block must be independently copy-pasteable because App Store Connect may ask for Review Notes per IAP item.

Use clear visual boundaries so the user can immediately identify exactly where to start and stop copying.

Use this format:

```text
========== COPY START: MONTHLY REVIEW NOTES ==========
{monthly review notes}
========== COPY END: MONTHLY REVIEW NOTES ==========
```

Repeat the same boundary style for yearly and lifetime.

Do not wrap the copy blocks in Markdown code fences unless the user explicitly asks. The boundary lines themselves are enough and easier to select in chat.

## Infer first

Follow the shared infer-first rules in `CLAUDE.md`. Inspect trusted project files before asking the user.

Infer when available:

- App name.
- Bundle identifier.
- Monthly product ID.
- Yearly product ID.
- Lifetime product ID.
- Product display names.
- Subscription group name.
- Paywall path or the most likely steps to open it.
- Restore Purchases location.
- Pro features or benefits shown on the paywall.
- Trial behavior, if any.
- Whether login, onboarding, demo data, permissions, network access, or AI setup is needed before review can reach the paywall.

Ask only when required values cannot be derived. Do not invent app-specific facts, product IDs, credentials, legal URLs, prices, or feature claims.

If a value is missing but the user wants a draft anyway, use obvious placeholders like `{MONTHLY_PRODUCT_ID}` and add a short warning before the copy blocks listing what must be replaced. Never leave placeholders silently.

## What to include in each Review Notes block

Each product-specific block should include:

- Where the reviewer can find the purchase screen.
- The exact product ID for that IAP.
- The product type:
  - monthly auto-renewable subscription
  - yearly auto-renewable subscription
  - non-consumable lifetime purchase
- What the purchase unlocks.
- Restore Purchases location.
- Trial behavior, if relevant.
- Demo account or setup instructions, only if needed.
- A short note if no login or special setup is required.

Keep the notes factual and concise. The goal is to help Apple Review test the IAP, not to market the product.

## Standard wording rules

Use clear App Store-safe wording:

- Monthly: `monthly auto-renewable subscription`.
- Yearly: `yearly auto-renewable subscription`.
- Lifetime: `non-consumable lifetime purchase`.
- Lifetime may also say: `one-time purchase and does not renew`.

Do not call lifetime a subscription.

Do not say monthly or yearly are lifetime access.

Do not claim anything is an Apple introductory offer unless that is verified in App Store Connect.

If the app uses the toolkit’s 60-day no-card trial and it is verified in the current project, use:

```text
New users receive a 60-day no-card trial. This trial is managed by the app and does not start an Apple billing period. After the trial expires, the paywall is shown before continued Pro access.
```

If there is no verified trial, omit trial language.

## Default output template

When verified values are available, produce output like this:

========== COPY START: MONTHLY REVIEW NOTES ==========
The monthly in-app purchase can be reviewed from {PAYWALL_LOCATION}. To open it, {PAYWALL_STEPS}.

Product ID: {MONTHLY_PRODUCT_ID}
Product type: Monthly auto-renewable subscription.

This purchase unlocks {VERIFIED_PRO_BENEFITS}. Restore Purchases is available from {RESTORE_LOCATION}.

{TRIAL_SENTENCE_IF_VERIFIED}
{SETUP_SENTENCE}
========== COPY END: MONTHLY REVIEW NOTES ==========

========== COPY START: YEARLY REVIEW NOTES ==========
The yearly in-app purchase can be reviewed from {PAYWALL_LOCATION}. To open it, {PAYWALL_STEPS}.

Product ID: {YEARLY_PRODUCT_ID}
Product type: Yearly auto-renewable subscription.

This purchase unlocks {VERIFIED_PRO_BENEFITS}. Restore Purchases is available from {RESTORE_LOCATION}.

{TRIAL_SENTENCE_IF_VERIFIED}
{SETUP_SENTENCE}
========== COPY END: YEARLY REVIEW NOTES ==========

========== COPY START: LIFETIME REVIEW NOTES ==========
The lifetime in-app purchase can be reviewed from {PAYWALL_LOCATION}. To open it, {PAYWALL_STEPS}.

Product ID: {LIFETIME_PRODUCT_ID}
Product type: Non-consumable lifetime purchase.

This purchase unlocks {VERIFIED_PRO_BENEFITS}. The lifetime product is a one-time purchase and does not renew. Restore Purchases is available from {RESTORE_LOCATION}.

{TRIAL_SENTENCE_IF_VERIFIED}
{SETUP_SENTENCE}
========== COPY END: LIFETIME REVIEW NOTES ==========

Before sending final output, replace placeholders with verified app-specific values when possible.

## Setup sentence options

Use one of these depending on what is verified:

```text
No login or special setup is required to access the purchase screen.
```

```text
Complete onboarding first, then open the purchase screen from {LOCATION}.
```

```text
Use this review-safe demo account if needed: {DEMO_ACCOUNT}. No real payment or production user data is required.
```

Only include credentials if the user provides review-safe credentials.

## If values are missing

If product IDs or important review paths cannot be inferred, ask the user for only the missing values.

If the user wants text immediately despite missing values, output the three copy blocks with placeholders and put this warning above them:

```text
Replace these placeholders before pasting into App Store Connect: {PLACEHOLDER_LIST}
```

Do not put warnings inside the copy blocks unless the warning is intended to be pasted to Apple.

## Audit mode

When auditing existing Review Notes, report only:

1. Whether each note is copy-paste ready.
2. Whether monthly, yearly, and lifetime are clearly separated.
3. Whether the product type wording is correct.
4. Whether any placeholders, wrong product IDs, or misleading statements remain.
5. Corrected copy-ready notes using the boundary format.

Do not discuss screenshots in audit mode.

## Common pitfalls

Avoid:

- Giving one combined note when the user needs separate notes for each product.
- Making the user edit prose heavily before pasting.
- Hiding copy boundaries inside Markdown formatting that is hard to select.
- Mentioning screenshots.
- Calling lifetime a subscription.
- Omitting product IDs.
- Omitting how Apple Review can reach the paywall.
- Leaving placeholders without a warning.
- Including marketing claims instead of testing instructions.
- Providing demo credentials unless the user gave review-safe credentials.
