---
name: ios-iap-review-information
description: Prepare App Store Connect in-app purchase review screenshots and review notes for monthly, yearly, and lifetime iOS products
trigger: /ios-iap-review-information
---

# /ios-iap-review-information

Prepare or audit App Store Connect Review Information for iOS subscriptions and in-app purchases, especially apps that offer monthly, yearly, and lifetime Pro access.

Use this when the user needs help deciding which IAP screenshot to upload and what to write in the Review Notes field: `Additional information about your in-app purchase that could help us with our review.`

This skill is for App Store Connect metadata and review readiness. It does not implement StoreKit code; use `/ios-subscription-system` for implementation or audit of the purchase system.

## Check current Apple docs first

When web access is available and the work is release-facing, check Apple’s current docs before making compliance decisions:

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Auto-renewable subscriptions](https://developer.apple.com/app-store/subscriptions/)
- [App Store Connect: in-app purchases](https://developer.apple.com/help/app-store-connect/manage-in-app-purchases/overview-for-configuring-in-app-purchases/)
- [Submit in-app purchases for review](https://developer.apple.com/help/app-store-connect/manage-in-app-purchases/submit-in-app-purchases-for-review/)
- [Required, localizable, and editable properties](https://developer.apple.com/help/app-store-connect/reference/required-localizable-and-editable-properties/)

If Apple’s current docs conflict with this skill, follow Apple’s docs and update this skill.

## Values to infer first

Follow the shared infer-first rules in `CLAUDE.md`. Inspect trusted project files before asking the user.

Infer when available:

- App name and bundle identifier.
- Product IDs for monthly, yearly, and lifetime.
- Product display names, durations, subscription group, and prices from StoreKit config or project constants.
- Paywall location, Settings upgrade row, restore flow, and entitlement-gated features.
- Trial behavior, if any.
- Legal links shown in the paywall.
- Whether the app requires login, onboarding, demo data, network access, AI setup, or permissions before the paywall can be reviewed.

Ask only for values that cannot be safely derived:

- Sandbox account credentials or demo account credentials, if review cannot access the paywall without an account.
- Exact user journey if multiple paywall entry points exist and none is clearly primary.
- Which benefits should be listed when the app does not clearly define Pro features.
- Whether the review screenshot should show a specific localized storefront, language, device class, or subscription offer.
- Any production-only setup needed to exercise a purchase.

Do not invent prices, product IDs, App Store IDs, credentials, legal URLs, or app-specific claims.

## Output the user should receive

Produce a concise, copy-ready package:

1. Recommended screenshot to upload for each IAP product.
2. Review Notes text that can be pasted into App Store Connect.
3. Any missing information Apple reviewers may need.
4. Any release blockers or metadata mismatches found.

Do not edit code unless the user explicitly asks to implement a missing paywall or fix a review blocker.

## Screenshot recommendation

Recommend a screenshot that proves the product is visible, purchasable, and described before purchase.

Default screenshot: the app’s main paywall with all available products visible:

- Monthly subscription card.
- Yearly subscription card.
- Lifetime one-time purchase card.
- Selected product state if relevant.
- Localized price from StoreKit/App Store.
- Billing period or non-renewing lifetime language.
- Included Pro benefits.
- Restore Purchases link or button.
- Privacy Policy and Terms/Subscription Terms access.
- Apple Account charge and auto-renewal disclosure, if visible on the same screen.

If App Store Connect requires one screenshot per IAP, use the same paywall screenshot for monthly, yearly, and lifetime when all three products are visible and readable. Otherwise recommend product-specific screenshots with the relevant product selected.

Good screenshot choices:

- Paywall opened from onboarding or the primary upgrade entry point.
- Paywall opened from Settings → Upgrade to Pro.
- Trial-expired hard paywall, if that is the clearest purchase screen and it includes all required details.

Avoid recommending screenshots that show only:

- A success screen after purchase.
- A Settings subscription status row without prices or purchase options.
- A marketing page outside the app.
- App Store Connect, Xcode, StoreKit config, or backend dashboards.
- Debug purchase controls.
- Placeholder products, placeholder prices, placeholder legal links, or local-only labels.

Screenshot quality requirements:

- Use a real app screen, not a mockup.
- Use a current build matching the submitted binary.
- Make product names and prices legible.
- Avoid cropped product cards or hidden legal/restore links when possible.
- Avoid personal data, API keys, debug overlays, or simulator-only development UI.
- Prefer the same device family as the submitted app screenshots unless there is a reason to show another form factor.

## Review Notes content

Review Notes should help Apple find and test the purchase flow. Keep them factual, short, and app-specific.

Include:

- Where to find the paywall or purchase screen.
- The product IDs submitted for review.
- Which products are auto-renewable subscriptions and which are non-consumable lifetime.
- What the purchase unlocks.
- Trial behavior, if relevant.
- Restore Purchases location.
- Demo account or setup instructions, only if needed.
- Any permissions or network requirements needed to reach the paywall.

Do not include:

- Marketing copy or unsupported claims.
- Instructions to bypass Apple IAP.
- External purchase links.
- Promises that differ from the binary or App Store metadata.
- Sensitive production credentials unless the user explicitly provides review-safe demo credentials.

## Default Review Notes template

Use this as the default structure and fill only with verified app-specific details:

```text
The in-app purchases can be reviewed from {path_to_paywall}, for example: {steps_to_open_paywall}.

Products submitted for review:
- {monthly_product_id}: monthly auto-renewable subscription for {app_or_plan_name} Pro.
- {yearly_product_id}: yearly auto-renewable subscription for {app_or_plan_name} Pro.
- {lifetime_product_id}: non-consumable lifetime purchase for {app_or_plan_name} Pro.

These purchases unlock {short_verified_benefits}. The monthly and yearly products are in the same subscription group. The lifetime product is a one-time purchase and does not renew.

Restore Purchases is available from {restore_location}. {trial_sentence_if_applicable}

{demo_or_setup_sentence_if_needed}
```

If there is no trial, omit the trial sentence.

If no account is needed, use:

```text
No login or special setup is required to access the purchase screen.
```

If an account is needed, use only user-provided review-safe credentials:

```text
Use this demo account if needed: {demo_credentials}. No real payment or production user data is required.
```

## Monthly, yearly, and lifetime wording

Use clear App Store-safe wording:

- Monthly: `monthly auto-renewable subscription`.
- Yearly: `yearly auto-renewable subscription`.
- Lifetime: `non-consumable lifetime purchase` or `one-time lifetime purchase that does not renew`.

Do not call lifetime a subscription.

If the app has a 60-day no-card trial from `/ios-subscription-system`, describe it as:

```text
New users receive a 60-day no-card trial. After the trial expires, the paywall is shown before continued Pro access. The trial is not an introductory subscription offer and does not start an Apple billing period.
```

Only use that sentence when verified in the current app.

## Example Review Notes

Generic example for the common toolkit pattern:

```text
The in-app purchases can be reviewed from the app paywall. Open the app, complete onboarding if shown, then tap Upgrade to Pro from Settings or wait for the trial/paywall screen to appear.

Products submitted for review:
- {bundle}.pro.monthly: monthly auto-renewable subscription for Pro access.
- {bundle}.pro.yearly: yearly auto-renewable subscription for Pro access.
- {bundle}.pro.lifetime: non-consumable lifetime purchase for Pro access.

These purchases unlock the app’s Pro features shown on the paywall. The monthly and yearly products are in the same subscription group. The lifetime product is a one-time purchase and does not renew.

Restore Purchases is available on the paywall and in Settings. No login or special setup is required to access the purchase screen.
```

Replace placeholders with verified app values before giving final text to the user.

## Product metadata cross-check

When auditing App Store Connect text against the app, verify:

- Product IDs match the app code and StoreKit config exactly.
- Monthly/yearly products are in the same subscription group.
- Lifetime product is non-consumable, not auto-renewable.
- Product display names are clear and not misleading.
- Product descriptions accurately describe access and renewal behavior.
- Prices and durations in screenshots match App Store Connect.
- Paywall benefits match what the products actually unlock.
- Restore Purchases is visible.
- Legal links are reachable before purchase.
- The screenshot is from the submitted app build and not debug UI.
- App Review can reach the paywall without hidden setup.

## Recommended App Store Connect product descriptions

If the user asks for product description suggestions, keep them plain and accurate:

- Monthly: `{AppName} Pro monthly access. Renews monthly until canceled.`
- Yearly: `{AppName} Pro yearly access. Renews yearly until canceled.`
- Lifetime: `{AppName} Pro lifetime access with a one-time purchase. Does not renew.`

Customize only with verified product benefits when they are known.

## Audit mode

When auditing existing IAP Review Information, inspect:

- Submitted screenshot choice.
- Review Notes clarity and completeness.
- Product IDs and product types.
- Paywall path and restore path.
- Trial explanation.
- Demo/setup instructions.
- Mismatches between binary, StoreKit config, paywall, and App Store Connect metadata.

Report:

1. Whether the screenshot is acceptable.
2. Better screenshot recommendation, if any.
3. Copy-ready Review Notes.
4. Missing reviewer instructions.
5. Release blockers or App Review risks.

## Common pitfalls

Avoid:

- Uploading a screenshot that does not show the product being sold.
- Using a post-purchase success screen as the IAP screenshot.
- Calling lifetime access a subscription.
- Forgetting to tell reviewers where the paywall is.
- Omitting demo credentials when login is required.
- Mentioning monthly/yearly subscriptions without saying they auto-renew.
- Claiming the trial is an Apple introductory offer when it is only an app-managed no-card trial.
- Providing review notes with placeholders still present.
- Submitting screenshots with debug controls, test product names, or placeholder prices.
- Describing benefits that are not visible in the app or not actually unlocked by the purchase.
